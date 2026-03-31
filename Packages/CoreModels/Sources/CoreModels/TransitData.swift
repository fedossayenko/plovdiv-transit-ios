import Foundation

/// Response from the /data endpoint containing all lines and stops.
public struct TransitData: Codable, Sendable {
    public let lines: [TransitLine]
    public let stops: [Stop]

    public init(lines: [TransitLine], stops: [Stop]) {
        self.lines = lines
        self.stops = stops
    }
}
