import CoreModels
import Foundation

// MARK: - APIClient

/// REST API client for livetransport.eu.
public actor APIClient {
    private let baseURL: URL
    private let session: URLSession
    private let decoder: JSONDecoder

    public init(
        cityId: String = "plovdiv",
        session: URLSession = .shared,
    ) {
        guard let url = URL(string: "https://api.livetransport.eu/\(cityId)") else {
            fatalError("Invalid base URL for city: \(cityId)")
        }
        baseURL = url
        self.session = session
        decoder = JSONDecoder()
    }

    // MARK: - Cache

    private static var cacheURL: URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("transit_data.json")
    }

    /// Loads cached transit data from disk.
    public func loadCachedTransitData() -> TransitData? {
        guard let data = try? Data(contentsOf: Self.cacheURL) else {
            return nil
        }
        return try? JSONDecoder().decode(TransitData.self, from: data)
    }

    // MARK: - Endpoints

    /// Fetches all lines and stops for the city, caching the result.
    public func fetchTransitData() async throws -> TransitData {
        let result: TransitData = try await get("data")
        // Cache in background
        if let encoded = try? JSONEncoder().encode(result) {
            try? encoded.write(to: Self.cacheURL, options: .atomic)
        }
        return result
    }

    /// Fetches the virtual departure board for a stop.
    public func fetchVirtualBoard(stopId: String, limit: Int = 10) async throws -> VirtualBoardResponse {
        try await get("virtual-board/\(stopId)?limit=\(limit)")
    }

    /// Fetches the current trip for a vehicle.
    public func fetchVehicleTrip(vehicleId: String, tripId: String? = nil) async throws -> VehicleTripResponse {
        var path = "vehicle/\(vehicleId.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? vehicleId)/trip"
        if let tripId {
            path += "?trip=\(tripId)"
        }
        return try await get(path)
    }

    /// Fetches brigade schedules for a line.
    public func fetchBrigades(lineId: String, date: String? = nil) async throws -> BrigadesResponse {
        var path = "brigades/\(lineId)"
        if let date {
            path += "?date=\(date)"
        }
        return try await get(path)
    }

    // MARK: - Generic Request

    private func get<T: Decodable>(_ path: String) async throws -> T {
        guard let url = URL(string: "\(baseURL)/\(path)") else {
            throw APIError.invalidResponse
        }
        var request = URLRequest(url: url)
        request.setValue("https://livetransport.eu", forHTTPHeaderField: "Origin")
        request.setValue("https://livetransport.eu/", forHTTPHeaderField: "Referer")

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            if httpResponse.statusCode == 404 {
                throw APIError.notFound
            }
            throw APIError.httpError(statusCode: httpResponse.statusCode)
        }

        return try decoder.decode(T.self, from: data)
    }
}

// MARK: - APIError

public enum APIError: Error, Sendable {
    case invalidResponse
    case notFound
    case httpError(statusCode: Int)
}
