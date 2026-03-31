import ActivityKit
import Foundation

/// Defines the data model for the bus arrival Live Activity.
public struct TransitActivityAttributes: ActivityAttributes {
    /// Static data that doesn't change during the activity.
    public let lineName: String
    public let lineColor: String
    public let stopName: String
    public let destination: String

    /// Dynamic data that updates over time.
    public struct ContentState: Codable, Hashable {
        public let minutesUntilArrival: Int
        public let delaySeconds: Double
        public let scheduledTime: Date
        public let isActive: Bool

        public init(
            minutesUntilArrival: Int,
            delaySeconds: Double,
            scheduledTime: Date,
            isActive: Bool = true,
        ) {
            self.minutesUntilArrival = minutesUntilArrival
            self.delaySeconds = delaySeconds
            self.scheduledTime = scheduledTime
            self.isActive = isActive
        }
    }

    public init(lineName: String, lineColor: String, stopName: String, destination: String) {
        self.lineName = lineName
        self.lineColor = lineColor
        self.stopName = stopName
        self.destination = destination
    }
}
