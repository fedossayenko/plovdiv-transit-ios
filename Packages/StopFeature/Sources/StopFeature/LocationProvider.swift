import CoreLocation

/// Lightweight CLLocationManager wrapper for getting the user's GPS position.
@Observable
@MainActor
public final class LocationProvider: NSObject, CLLocationManagerDelegate {
    private(set) public var userLocation: CLLocation?
    private(set) public var authorizationStatus: CLAuthorizationStatus = .notDetermined

    private let manager = CLLocationManager()

    public override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        authorizationStatus = manager.authorizationStatus
    }

    public func requestWhenInUse() {
        manager.requestWhenInUseAuthorization()
    }

    public func startUpdating() {
        manager.startUpdatingLocation()
    }

    // MARK: - CLLocationManagerDelegate

    nonisolated public func locationManager(_: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            return
        }
        Task { @MainActor in
            self.userLocation = location
        }
    }

    nonisolated public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        Task { @MainActor in
            self.authorizationStatus = status
            if status == .authorizedWhenInUse || status == .authorizedAlways {
                manager.startUpdatingLocation()
            }
        }
    }
}
