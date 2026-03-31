import CoreModels
import Foundation

/// High-level transit service that combines REST API and WebSocket data.
/// This is the main entry point for feature modules to access transit data.
@Observable
@MainActor
public final class TransitService {
    public private(set) var lines: [TransitLine] = []
    public private(set) var stops: [Stop] = []
    public private(set) var vehicles: [Vehicle] = []
    public private(set) var isConnected = false
    public private(set) var isLoading = false
    public private(set) var error: Error?

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
    public func start() async {
        isLoading = true
        error = nil

        do {
            let data = try await apiClient.fetchTransitData()
            lines = data.lines
            stops = data.stops
            linesById = Dictionary(uniqueKeysWithValues: data.lines.map { ($0.id, $0) })
            stopsById = Dictionary(uniqueKeysWithValues: data.stops.map { ($0.id, $0) })
            isLoading = false

            connectVehicleStream()
        } catch {
            self.error = error
            isLoading = false
        }
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
                }
            }

            await MainActor.run { self.isConnected = false }
        }
    }
}
