import CoreLocation

// MARK: - LocationProvider

/// Lightweight CLLocationManager wrapper for getting the user's GPS position.
@Observable
@MainActor
public final class LocationProvider: NSObject {
    private(set) public var userLocation: CLLocation?
    private(set) public var authorizationStatus: CLAuthorizationStatus = .notDetermined

    private let manager = CLLocationManager()
    private var delegate: LocationDelegate?

    public override init() {
        super.init()
        let delegate = LocationDelegate { [weak self] location in
            Task { @MainActor in
                self?.userLocation = location
            }
        } onAuthChange: { [weak self] status in
            Task { @MainActor in
                self?.authorizationStatus = status
                if status == .authorizedWhenInUse || status == .authorizedAlways {
                    self?.manager.startUpdatingLocation()
                }
            }
        }
        self.delegate = delegate
        manager.delegate = delegate
        manager.desiredAccuracy = kCLLocationAccuracyBest
        authorizationStatus = manager.authorizationStatus
    }

    public func requestWhenInUse() {
        manager.requestWhenInUseAuthorization()
    }

    public func startUpdating() {
        manager.startUpdatingLocation()
    }
}

// MARK: - LocationDelegate

private final class LocationDelegate: NSObject, CLLocationManagerDelegate, Sendable {
    let onLocation: @Sendable (CLLocation) -> Void
    let onAuthChange: @Sendable (CLAuthorizationStatus) -> Void

    init(
        onLocation: @escaping @Sendable (CLLocation) -> Void,
        onAuthChange: @escaping @Sendable (CLAuthorizationStatus) -> Void,
    ) {
        self.onLocation = onLocation
        self.onAuthChange = onAuthChange
    }

    func locationManager(_: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            return
        }
        onLocation(location)
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        onAuthChange(manager.authorizationStatus)
    }
}
