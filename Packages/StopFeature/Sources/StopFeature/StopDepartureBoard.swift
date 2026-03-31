import SwiftUI
import CoreModels
import TransitNetwork
import SharedUI
import CoreExtensions

/// Virtual departure board for a transit stop, showing upcoming departures.
public struct StopDepartureBoard: View {
    @Environment(TransitService.self) private var transitService
    let stop: Stop
    @State private var departures: [Departure] = []
    @State private var isLoading = true
    @State private var error: Error?

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
                        description: Text(error.localizedDescription)
                    )
                } else if departures.isEmpty {
                    ContentUnavailableView(
                        "No departures",
                        systemImage: "bus",
                        description: Text("No upcoming departures from this stop")
                    )
                } else {
                    List(departures) { departure in
                        DepartureRow(
                            departure: departure,
                            line: transitService.line(for: departure.lineId)
                        )
                    }
                    .refreshable {
                        await loadDepartures()
                    }
                }
            }
            .navigationTitle(stop.name.localized)
            .navigationBarTitleDisplayMode(.large)
            .task {
                await loadDepartures()
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

struct DepartureRow: View {
    let departure: Departure
    let line: TransitLine?

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
        }
        .padding(.vertical, 4)
    }
}
