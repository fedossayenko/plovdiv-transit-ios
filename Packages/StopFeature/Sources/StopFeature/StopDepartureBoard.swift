import CoreExtensions
import CoreModels
import SharedUI
import SwiftUI
import TransitNetwork

// MARK: - StopDepartureBoard

/// Virtual departure board for a transit stop, showing upcoming departures.
public struct StopDepartureBoard: View {
    @Environment(TransitService.self) private var transitService
    @Environment(FavoritesStore.self) private var favoritesStore
    let stop: Stop
    @State private var departures: [Departure] = []
    @State private var isLoading = true
    @State private var error: Error?
    @State private var selectedDeparture: Departure?

    public init(stop: Stop) {
        self.stop = stop
    }

    public var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView()
                } else if let error {
                    ContentUnavailableView(
                        "Failed to load",
                        systemImage: "exclamationmark.triangle",
                        description: Text(error.localizedDescription),
                    )
                } else if departures.isEmpty {
                    ContentUnavailableView(
                        "No departures",
                        systemImage: "bus",
                        description: Text("No upcoming departures from this stop"),
                    )
                } else {
                    List(departures) { departure in
                        Button {
                            if departure.vehicleId != nil, departure.activeTrip == true {
                                selectedDeparture = departure
                            }
                        } label: {
                            DepartureRow(
                                departure: departure,
                                line: transitService.line(for: departure.lineId),
                                hasVehicle: departure.vehicleId != nil && departure.activeTrip == true,
                            )
                        }
                        .buttonStyle(.plain)
                        .swipeActions(edge: .trailing) {
                            if departure.activeTrip == true {
                                Button {
                                    LiveActivityManager.shared.startTracking(
                                        departure: departure,
                                        line: transitService.line(for: departure.lineId),
                                        stopName: stop.name.localized,
                                        transitService: transitService,
                                    )
                                } label: {
                                    Label("Track", systemImage: "clock.badge")
                                }
                                .tint(.blue)
                            }
                        }
                    }
                    .refreshable {
                        await loadDepartures()
                    }
                }
            }
            .navigationTitle(stop.name.localized)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        favoritesStore.toggleStop(stop.id)
                    } label: {
                        Image(systemName: favoritesStore.isFavorite(stopId: stop.id) ? "star.fill" : "star")
                            .foregroundStyle(favoritesStore.isFavorite(stopId: stop.id) ? .yellow : .secondary)
                    }
                }
            }
            .task {
                await loadDepartures()
            }
            .sheet(item: $selectedDeparture) { departure in
                DepartureVehicleSheet(departure: departure)
                    .environment(transitService)
            }
            .task(id: "refresh") {
                // Auto-refresh every 30 seconds
                while !Task.isCancelled {
                    try? await Task.sleep(for: .seconds(30))
                    await loadDepartures()
                }
            }
        }
    }

    private func loadDepartures() async {
        do {
            departures = try await transitService.fetchDepartures(stopId: stop.id)
            isLoading = false
            error = nil
        } catch {
            self.error = error
            isLoading = false
        }
    }
}

// MARK: - DepartureRow

struct DepartureRow: View {
    let departure: Departure
    let line: TransitLine?
    var hasVehicle = false

    var body: some View {
        HStack {
            if let line {
                LineBadge(line: line)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(departure.destination.localized)
                    .font(TransitTypography.stopName)
                if departure.time.delay != 0 {
                    DelayIndicator(delaySeconds: departure.time.delay)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                let minutes = departure.minutesUntil
                if minutes == 0 {
                    Text("Now")
                        .font(TransitTypography.countdown)
                        .foregroundStyle(.green)
                } else {
                    Text("\(minutes)")
                        .font(TransitTypography.countdown)
                    Text("min")
                        .font(TransitTypography.caption)
                        .foregroundStyle(.secondary)
                }
            }

            if hasVehicle {
                Image(systemName: "chevron.right")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 4)
    }
}
