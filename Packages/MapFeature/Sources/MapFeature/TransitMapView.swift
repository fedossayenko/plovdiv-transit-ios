import SwiftUI
import MapKit
import CoreModels
import TransitNetwork
import SharedUI

/// The main map view showing real-time vehicle positions and stops.
public struct TransitMapView: View {
    @Environment(TransitService.self) private var transitService
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 42.14213, longitude: 24.75230),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    )
    @State private var selectedVehicle: Vehicle?

    public init() {}

    public var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Map(position: $cameraPosition) {
                // Vehicle annotations
                ForEach(transitService.vehicles) { vehicle in
                    Annotation(
                        vehicle.destination.localized,
                        coordinate: vehicle.coords.clLocationCoordinate,
                        anchor: .center
                    ) {
                        VehicleAnnotationView(
                            vehicle: vehicle,
                            line: transitService.line(for: vehicle.lineId)
                        )
                        .onTapGesture {
                            selectedVehicle = vehicle
                        }
                    }
                }

                // Stop markers at higher zoom levels
                ForEach(transitService.stops) { stop in
                    Annotation(
                        stop.name.localized,
                        coordinate: stop.geo.coords.clLocationCoordinate,
                        anchor: .center
                    ) {
                        Circle()
                            .fill(.white)
                            .stroke(Color.accentColor, lineWidth: 1.5)
                            .frame(width: 10, height: 10)
                    }
                }

                UserAnnotation()
            }
            .mapStyle(.standard)
            .mapControls {
                MapCompass()
                MapScaleView()
            }

            // Floating controls
            VStack(spacing: 12) {
                GlassButton(systemImage: "location.fill") {
                    cameraPosition = .userLocation(fallback: cameraPosition)
                }
                GlassButton(systemImage: "line.3.horizontal.decrease") {
                    // TODO: Open filter sheet
                }
            }
            .padding()
        }
        .sheet(item: $selectedVehicle) { vehicle in
            VehicleDetailSheet(vehicle: vehicle)
        }
    }
}
