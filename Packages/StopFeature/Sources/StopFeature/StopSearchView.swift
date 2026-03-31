import CoreLocation
import CoreModels
import SharedUI
import SwiftUI
import TransitNetwork

// MARK: - StopSearchView

/// Searchable stop list with nearby stops section.
public struct StopSearchView: View {
    @Environment(TransitService.self) private var transitService
    @State private var searchText = ""
    @State private var locationProvider = LocationProvider()

    public init() {}

    private var filteredStops: [Stop] {
        if searchText.isEmpty {
            return []
        }
        let query = searchText.lowercased()
        return transitService.stops.filter { stop in
            stop.name.localized.lowercased().contains(query)
                || stop.name.bg.lowercased().contains(query)
                || stop.name.en.lowercased().contains(query)
                || stop.code.contains(query)
        }
    }

    private var nearbyStops: [Stop] {
        guard let userLocation = locationProvider.userLocation else {
            return []
        }
        return transitService.stops
            .sorted { stopA, stopB in
                let locA = CLLocation(latitude: stopA.geo.coords.latitude, longitude: stopA.geo.coords.longitude)
                let locB = CLLocation(latitude: stopB.geo.coords.latitude, longitude: stopB.geo.coords.longitude)
                return userLocation.distance(from: locA) < userLocation.distance(from: locB)
            }
            .prefix(5)
            .map(\.self)
    }

    public var body: some View {
        NavigationStack {
            List {
                if searchText.isEmpty {
                    // Nearby stops
                    if !nearbyStops.isEmpty {
                        Section("Nearby") {
                            ForEach(nearbyStops) { stop in
                                NavigationLink(value: stop) {
                                    StopRow(stop: stop, userLocation: locationProvider.userLocation)
                                }
                            }
                        }
                    } else if locationProvider.authorizationStatus == .notDetermined {
                        Section {
                            Button("Enable Location for Nearby Stops") {
                                locationProvider.requestWhenInUse()
                            }
                        }
                    }

                    // All stops count
                    Section {
                        Text("\(transitService.stops.count) stops in Plovdiv")
                            .foregroundStyle(.secondary)
                    }
                } else {
                    // Search results
                    Section("Results (\(filteredStops.count))") {
                        ForEach(filteredStops) { stop in
                            NavigationLink(value: stop) {
                                StopRow(stop: stop, userLocation: locationProvider.userLocation)
                            }
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search stops by name or code")
            .navigationTitle("Stops")
            .onAppear {
                if locationProvider.authorizationStatus == .authorizedWhenInUse
                    || locationProvider.authorizationStatus == .authorizedAlways
                {
                    locationProvider.startUpdating()
                }
            }
            .navigationDestination(for: Stop.self) { stop in
                StopDepartureBoard(stop: stop)
            }
        }
    }
}

// MARK: - StopRow

struct StopRow: View {
    let stop: Stop
    let userLocation: CLLocation?

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(stop.name.localized)
                .font(.body)
            HStack {
                Text("Code: \(stop.code)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if let distance = formattedDistance {
                    Text(distance)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private var formattedDistance: String? {
        guard let userLocation else {
            return nil
        }
        let stopLocation = CLLocation(
            latitude: stop.geo.coords.latitude,
            longitude: stop.geo.coords.longitude,
        )
        let meters = userLocation.distance(from: stopLocation)
        if meters < 1000 {
            return "\(Int(meters))m"
        }
        return String(format: "%.1fkm", meters / 1000)
    }
}
