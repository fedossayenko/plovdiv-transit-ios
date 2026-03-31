import CoreExtensions
import CoreModels
import SharedUI
import StopFeature
import SwiftUI
import TransitNetwork

/// Bottom sheet showing details for a selected vehicle.
struct VehicleDetailSheet: View {
    @Environment(TransitService.self) private var transitService
    let vehicle: Vehicle
    @State private var tripResponse: VehicleTripResponse?
    @State private var selectedStop: Stop?

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
                                Button {
                                    selectedStop = stop
                                } label: {
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
                                        Image(systemName: "chevron.right")
                                            .font(.caption2)
                                            .foregroundStyle(.tertiary)
                                    }
                                }
                                .buttonStyle(.plain)
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
            .sheet(item: $selectedStop) { stop in
                StopDepartureBoard(stop: stop)
            }
        }
    }

    private func loadTrip() async {
        do {
            let response = try await transitService.fetchVehicleTrip(vehicleId: vehicle.id)
            tripResponse = response

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
