import Foundation

// MARK: - Departure

/// A departure from a virtual board at a stop.
public struct Departure: Identifiable, Codable, Hashable, Sendable {
    public let tripId: String
    public let lineId: String
    public let vehicleId: String?
    public let activeTrip: Bool?
    public let time: DepartureTime
    public let destination: LocalizedString

    public var id: String {
        tripId
    }

    public init(
        tripId: String,
        lineId: String,
        vehicleId: String?,
        activeTrip: Bool?,
        time: DepartureTime,
        destination: LocalizedString,
    ) {
        self.tripId = tripId
        self.lineId = lineId
        self.vehicleId = vehicleId
        self.activeTrip = activeTrip
        self.time = time
        self.destination = destination
    }

    /// Minutes until departure from now.
    public var minutesUntil: Int {
        let interval = time.actual.timeIntervalSinceNow
        return max(0, Int(interval / 60))
    }
}

// MARK: - DepartureTime

public struct DepartureTime: Codable, Hashable, Sendable {
    public let scheduled: Date
    public let actual: Date

    public init(scheduled: Date, actual: Date) {
        self.scheduled = scheduled
        self.actual = actual
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let scheduledMs = try container.decode(Double.self, forKey: .scheduled)
        let actualMs = try container.decode(Double.self, forKey: .actual)
        scheduled = Date(timeIntervalSince1970: scheduledMs / 1000.0)
        actual = Date(timeIntervalSince1970: actualMs / 1000.0)
    }

    /// Delay in seconds (positive = late, negative = early).
    public var delay: TimeInterval {
        actual.timeIntervalSince(scheduled)
    }

    private enum CodingKeys: String, CodingKey {
        case scheduled, actual
    }
}

// MARK: - VirtualBoardResponse

/// Response from the virtual board endpoint.
public struct VirtualBoardResponse: Codable, Sendable {
    public let departures: [Departure]
}
