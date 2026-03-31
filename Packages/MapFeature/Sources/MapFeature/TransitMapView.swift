import CoreExtensions
import CoreLocation
import CoreModels
import MapKit
import SharedUI
import StopFeature
import SwiftUI
import TransitNetwork

/// The main map view showing real-time vehicle positions and stops.
public struct TransitMapView: View {
    @Environment(TransitService.self) private var transitService
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 42.14213, longitude: 24.75230),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05),
        ),
    )
    @State private var selectedVehicle: Vehicle?
    @State private var selectedStop: Stop?
    @State private var visibleSpan = 0.05
    @State private var showFilterSheet = false
    @State private var filterState = MapFilterState()
    @State private var locationAuthorized = false

    public init() {}

    private var showStops: Bool {
        visibleSpan < 0.02
    }

    private var filteredVehicles: [Vehicle] {
        transitService.vehicles.filter { filterState.isVisible($0) }
    }

    public var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Map(position: $cameraPosition) {
                // Route polyline
                if let shape = transitService.selectedTripShape {
                    let coords = shape.map(\.clLocationCoordinate)
                    MapPolyline(coordinates: coords)
                        .stroke(.blue, lineWidth: 4)
                }

                // Vehicle annotations
                ForEach(filteredVehicles) { vehicle in
                    Annotation(
                        vehicle.destination.localized,
                        coordinate: vehicle.coords.clLocationCoordinate,
                        anchor: .center,
                    ) {
                        VehicleAnnotationView(
                            vehicle: vehicle,
                            line: transitService.line(for: vehicle.lineId),
                        )
                        .onTapGesture {
                            selectedVehicle = vehicle
                        }
                    }
                }

                // Stop markers (zoom-dependent)
                if showStops {
                    ForEach(transitService.stops) { stop in
                        Annotation(
                            stop.name.localized,
                            coordinate: stop.geo.coords.clLocationCoordinate,
                            anchor: .center,
                        ) {
                            Circle()
                                .fill(.white)
                                .stroke(Color.accentColor, lineWidth: 1.5)
                                .frame(width: 10, height: 10)
                                .onTapGesture {
                                    selectedStop = stop
                                }
                        }
                    }
                }

                if locationAuthorized {
                    UserAnnotation()
                }
            }
            .mapStyle(.standard)
            .mapControls {
                MapCompass()
                MapScaleView()
            }
            .onMapCameraChange { context in
                visibleSpan = context.region.span.latitudeDelta
            }

            // Floating controls
            VStack(spacing: 12) {
                GlassButton(systemImage: "location.fill") {
                    cameraPosition = .userLocation(fallback: cameraPosition)
                }
                GlassButton(systemImage: "line.3.horizontal.decrease") {
                    showFilterSheet = true
                }
            }
            .padding()
        }
        .sheet(item: $selectedVehicle) { vehicle in
            VehicleDetailSheet(vehicle: vehicle)
        }
        .sheet(item: $selectedStop) { stop in
            StopDepartureBoard(stop: stop)
        }
        .sheet(isPresented: $showFilterSheet) {
            MapFilterSheet(filterState: $filterState)
        }
        .onAppear {
            let status = CLLocationManager().authorizationStatus
            locationAuthorized = status == .authorizedWhenInUse || status == .authorizedAlways
        }
    }
}
