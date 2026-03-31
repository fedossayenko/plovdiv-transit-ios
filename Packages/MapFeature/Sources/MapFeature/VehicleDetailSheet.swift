import CoreExtensions
import CoreModels
import SharedUI
import SwiftUI
import TransitNetwork

/// Bottom sheet showing details for a selected vehicle.
struct VehicleDetailSheet: View {
    @Environment(TransitService.self) private var transitService
    let vehicle: Vehicle
    @State private var tripResponse: VehicleTripResponse?

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                // Header: line + destination
                HStack {
                    if let line = transitService.line(for: vehicle.lineId) {
                        LineBadge(line: line)
                    }
                    VStack(alignment: .leading) {
                        Text(vehicle.destination.localized)
                            .font(TransitTypography.stopName)
                        DelayIndicator(delaySeconds: vehicle.delay)
                    }
                }

                // Trip stops
                if let trip = tripResponse?.trip {
                    let nextStopIndex = tripResponse?.nextStop ?? 0

                    ScrollView {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(Array(trip.stops.enumerated()), id: \.offset) { index, tripStop in
                                let stop = transitService.stop(for: tripStop.id)
                                HStack {
                                    Circle()
                                        .fill(index == nextStopIndex ? Color.accentColor : .secondary)
                                        .frame(width: 8, height: 8)
                                    Text(stop?.name.localized ?? tripStop.id)
                                        .font(index == nextStopIndex ? .body.bold() : .body)
                                        .foregroundStyle(index < nextStopIndex ? .secondary : .primary)
                                    Spacer()
                                    Text(tripStop.scheduled.transitTimeString)
                                        .font(TransitTypography.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                } else {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Vehicle")
            .navigationBarTitleDisplayMode(.inline)
            .presentationDetents([.medium, .large])
            .task {
                await loadTrip()
            }
            .onDisappear {
                transitService.selectedTripShape = nil
            }
        }
    }

    private func loadTrip() async {
        do {
            let response = try await transitService.fetchVehicleTrip(vehicleId: vehicle.id)
            tripResponse = response

            // Decode route polyline and show on map
            if let shape = response.trip?.shape {
                let clCoords = PolylineDecoder.decode(shape)
                transitService.selectedTripShape = clCoords.map {
                    Coordinate(latitude: $0.latitude, longitude: $0.longitude)
                }
            }
        } catch {
            // Trip not available
        }
    }
}
