import CoreExtensions
import CoreModels
import SharedUI
import SwiftUI
import TransitNetwork

/// Sheet showing a vehicle's current trip with stop list.
struct VehicleTripSheet: View {
    @Environment(TransitService.self) private var transitService
    let vehicle: Vehicle
    @State private var tripResponse: VehicleTripResponse?

    var body: some View {
        NavigationStack {
            Group {
                if let trip = tripResponse?.trip {
                    let nextStopIndex = tripResponse?.nextStop ?? 0
                    List(Array(trip.stops.enumerated()), id: \.offset) { index, tripStop in
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
                } else {
                    ProgressView()
                }
            }
            .navigationTitle(vehicle.destination.localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 8) {
                        if let line = transitService.line(for: vehicle.lineId) {
                            LineBadge(line: line)
                        }
                        DelayIndicator(delaySeconds: vehicle.delay)
                    }
                }
            }
            .presentationDetents([.medium, .large])
            .task {
                tripResponse = try? await transitService.fetchVehicleTrip(vehicleId: vehicle.id)
            }
        }
    }
}
