import Foundation

/// A real-time vehicle position received via WebSocket.
///
/// The API sends vehicles as positional arrays for bandwidth efficiency:
/// `[id, type, lineId, blockId, destination, delay, [lat, lng], bearing, speed, lastUpdated]`
public struct Vehicle: Identifiable, Hashable, Sendable {
    public let id: String
    public let type: VehicleType
    public let lineId: String
    public let blockId: String
    public let destination: LocalizedString
    public let delay: TimeInterval
    public let coords: Coordinate
    public let bearing: Int
    public let speed: Int
    public let lastUpdated: Date

    public init(
        id: String,
        type: VehicleType,
        lineId: String,
        blockId: String,
        destination: LocalizedString,
        delay: TimeInterval,
        coords: Coordinate,
        bearing: Int,
        speed: Int,
        lastUpdated: Date,
    ) {
        self.id = id
        self.type = type
        self.lineId = lineId
        self.blockId = blockId
        self.destination = destination
        self.delay = delay
        self.coords = coords
        self.bearing = bearing
        self.speed = speed
        self.lastUpdated = lastUpdated
    }

    /// Whether the vehicle is delayed (positive delay).
    public var isDelayed: Bool {
        delay > 0
    }

    /// Whether the vehicle is ahead of schedule (negative delay).
    public var isEarly: Bool {
        delay < 0
    }

    /// Formatted delay string (e.g., "+3 min", "-1 min", "On time").
    public var delayText: String {
        let minutes = Int(delay / 60)
        if minutes == 0 {
            return "On time"
        }
        return minutes > 0 ? "+\(minutes) min" : "\(minutes) min"
    }
}
