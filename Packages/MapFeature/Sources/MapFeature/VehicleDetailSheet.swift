import SwiftUI
import CoreModels
import TransitNetwork
import SharedUI
import CoreExtensions

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
                do {
                    tripResponse = try await transitService.fetchVehicleTrip(vehicleId: vehicle.id)
                } catch {
                    // Trip not available
                }
            }
        }
    }
}
