import Foundation

// MARK: - Trip

/// A scheduled trip along a transit line.
public struct Trip: Identifiable, Codable, Hashable, Sendable {
    public let id: String
    public let lineId: String
    public let shape: String?
    public let destination: LocalizedString
    public let stops: [TripStop]

    public init(id: String, lineId: String, shape: String?, destination: LocalizedString, stops: [TripStop]) {
        self.id = id
        self.lineId = lineId
        self.shape = shape
        self.destination = destination
        self.stops = stops
    }
}

// MARK: - TripStop

/// A stop within a trip, with its scheduled time.
public struct TripStop: Codable, Hashable, Sendable {
    public let id: String
    public let scheduled: Date

    public init(id: String, scheduled: Date) {
        self.id = id
        self.scheduled = scheduled
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        let ms = try container.decode(Double.self, forKey: .scheduled)
        scheduled = Date(timeIntervalSince1970: ms / 1000.0)
    }

    private enum CodingKeys: String, CodingKey {
        case id, scheduled
    }
}

// MARK: - VehicleTripResponse

/// Response from the vehicle trip endpoint.
public struct VehicleTripResponse: Codable, Sendable {
    public let nextStop: Int?
    public let delay: Double?
    public let trip: Trip?

    /// Delay as TimeInterval in seconds.
    public var delayInterval: TimeInterval {
        (delay ?? 0) / 1000.0
    }
}
