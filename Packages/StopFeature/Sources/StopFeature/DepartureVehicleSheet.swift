import CoreExtensions
import CoreModels
import SharedUI
import SwiftUI
import TransitNetwork

/// Sheet showing vehicle trip info for an active departure.
struct DepartureVehicleSheet: View {
    @Environment(TransitService.self) private var transitService
    let departure: Departure
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
            .navigationTitle(departure.destination.localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 8) {
                        if let line = transitService.line(for: departure.lineId) {
                            LineBadge(line: line)
                        }
                        DelayIndicator(delaySeconds: departure.time.delay)
                    }
                }
            }
            .presentationDetents([.medium, .large])
            .task {
                guard let vehicleId = departure.vehicleId else {
                    return
                }
                tripResponse = try? await transitService.fetchVehicleTrip(vehicleId: vehicleId)
            }
        }
    }
}
