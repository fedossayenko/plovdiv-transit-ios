import CoreModels
import Foundation

/// High-level transit service that combines REST API and WebSocket data.
/// This is the main entry point for feature modules to access transit data.
@Observable
@MainActor
public final class TransitService {
    private(set) public var lines: [TransitLine] = []
    private(set) public var stops: [Stop] = []
    private(set) public var vehicles: [Vehicle] = []
    private(set) public var isConnected = false
    private(set) public var isLoading = false
    private(set) public var error: Error?
    public var selectedTripShape: [Coordinate]?
    private(set) public var vehicleUpdateCounter = 0

    private let apiClient: APIClient
    private let webSocket: VehicleWebSocket
    private var vehicleStreamTask: Task<Void, Never>?

    // Lookup dictionaries for O(1) access
    private var linesById: [String: TransitLine] = [:]
    private var stopsById: [String: Stop] = [:]

    public init(cityId: String = "plovdiv") {
        apiClient = APIClient(cityId: cityId)
        webSocket = VehicleWebSocket(cityId: cityId)
    }

    // MARK: - Lifecycle

    /// Loads initial transit data (lines + stops) and connects WebSocket.
    /// Loads cache first for instant UI, then refreshes from network.
    public func start() async {
        isLoading = true
        error = nil

        // Load cache first for instant UI
        if let cached = await apiClient.loadCachedTransitData() {
            applyTransitData(cached)
            isLoading = false
        }

        // Fetch fresh data from network
        do {
            let data = try await apiClient.fetchTransitData()
            applyTransitData(data)
            isLoading = false
            connectVehicleStream()
        } catch {
            // If we have cached data, still connect WebSocket
            if !lines.isEmpty {
                isLoading = false
                connectVehicleStream()
            } else {
                self.error = error
                isLoading = false
            }
        }
    }

    private func applyTransitData(_ data: TransitData) {
        lines = data.lines
        stops = data.stops
        linesById = Dictionary(uniqueKeysWithValues: data.lines.map { ($0.id, $0) })
        stopsById = Dictionary(uniqueKeysWithValues: data.stops.map { ($0.id, $0) })
    }

    /// Disconnects from the vehicle stream.
    public func stop() {
        vehicleStreamTask?.cancel()
        vehicleStreamTask = nil
        Task { await webSocket.disconnect() }
        isConnected = false
    }

    // MARK: - Lookups

    /// Find a line by its ID.
    public func line(for id: String) -> TransitLine? {
        linesById[id]
    }

    /// Find a stop by its ID.
    public func stop(for id: String) -> Stop? {
        stopsById[id]
    }

    /// Get all vehicles currently on a specific line.
    public func vehicles(onLine lineId: String) -> [Vehicle] {
        vehicles.filter { $0.lineId == lineId }
    }

    // MARK: - Departures

    /// Fetches live departures for a stop.
    public func fetchDepartures(stopId: String, limit: Int = 10) async throws -> [Departure] {
        let response = try await apiClient.fetchVirtualBoard(stopId: stopId, limit: limit)
        return response.departures
    }

    /// Fetches the current trip info for a vehicle.
    public func fetchVehicleTrip(vehicleId: String) async throws -> VehicleTripResponse {
        try await apiClient.fetchVehicleTrip(vehicleId: vehicleId)
    }

    /// Fetches trip info for the first active vehicle on a line.
    public func fetchTripForLine(lineId: String) async throws -> VehicleTripResponse? {
        guard let firstVehicle = vehicles.first(where: { $0.lineId == lineId }) else {
            return nil
        }
        return try await apiClient.fetchVehicleTrip(vehicleId: firstVehicle.id)
    }

    // MARK: - Private

    private func connectVehicleStream() {
        vehicleStreamTask?.cancel()
        vehicleStreamTask = Task { [weak self] in
            guard let self else {
                return
            }
            let stream = await webSocket.connect()
            await MainActor.run { self.isConnected = true }

            for await vehicleBatch in stream {
                guard !Task.isCancelled else {
                    break
                }
                await MainActor.run {
                    self.vehicles = vehicleBatch
                    self.vehicleUpdateCounter += 1
                }
            }

            await MainActor.run { self.isConnected = false }
        }
    }
}
