import CoreExtensions
import CoreModels
import MapKit
import SharedUI
import SwiftUI
import TransitNetwork

/// Detail view for a transit line showing live vehicles, route map, and stops.
public struct LineDetailView: View {
    @Environment(TransitService.self) private var transitService
    let line: TransitLine

    @State private var tripResponse: VehicleTripResponse?
    @State private var isLoading = true

    public init(line: TransitLine) {
        self.line = line
    }

    private var lineVehicles: [Vehicle] {
        transitService.vehicles(onLine: line.id)
    }

    public var body: some View {
        List {
            // Route map
            if let trip = tripResponse?.trip, let shape = trip.shape {
                Section("Route") {
                    let coords = PolylineDecoder.decode(shape)
                    Map {
                        MapPolyline(coordinates: coords)
                            .stroke(Color(hex: line.color), lineWidth: 3)

                        // Show vehicles on this line
                        ForEach(lineVehicles) { vehicle in
                            Annotation(
                                vehicle.destination.localized,
                                coordinate: vehicle.coords.clLocationCoordinate,
                                anchor: .center,
                            ) {
                                Circle()
                                    .fill(Color(hex: line.color))
                                    .frame(width: 10, height: 10)
                            }
                        }
                    }
                    .frame(height: 200)
                    .clipShape(.rect(cornerRadius: 12))
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                }
            }

            // Live vehicles
            Section("Live Vehicles (\(lineVehicles.count))") {
                if lineVehicles.isEmpty {
                    Text("No active vehicles")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(lineVehicles) { vehicle in
                        LineVehicleRow(vehicle: vehicle)
                    }
                }
            }

            // Stops along the route
            if let trip = tripResponse?.trip {
                Section("Stops (\(trip.stops.count))") {
                    let nextStopIndex = tripResponse?.nextStop ?? 0
                    ForEach(Array(trip.stops.enumerated()), id: \.offset) { index, tripStop in
                        let stop = transitService.stop(for: tripStop.id)
                        HStack {
                            Circle()
                                .fill(index == nextStopIndex ? Color(hex: line.color) : .secondary)
                                .frame(width: 8, height: 8)
                            Text(stop?.name.localized ?? tripStop.id)
                                .font(index == nextStopIndex ? .body.bold() : .body)
                            Spacer()
                            Text(tripStop.scheduled.transitTimeString)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            } else if isLoading {
                Section {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .navigationTitle(line.routeName)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .principal) {
                LineBadge(line: line)
            }
        }
        .task {
            await loadTrip()
        }
    }

    private func loadTrip() async {
        do {
            tripResponse = try await transitService.fetchTripForLine(lineId: line.id)
            isLoading = false
        } catch {
            isLoading = false
        }
    }
}
