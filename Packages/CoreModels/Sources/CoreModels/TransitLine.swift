import Foundation

// MARK: - TransitLine

/// A transit line (bus route) in the Plovdiv network.
public struct TransitLine: Identifiable, Hashable, Sendable {
    public let id: String
    public let type: VehicleType
    public let color: String
    public let name: String
    public let routeName: String

    public init(id: String, type: VehicleType, color: String, name: String, routeName: String) {
        self.id = id
        self.type = type
        self.color = color
        self.name = name
        self.routeName = routeName
    }
}

// MARK: Codable

extension TransitLine: Codable {}

// MARK: - VehicleType

public enum VehicleType: String, Codable, Hashable, Sendable {
    case bus
    case trolley
    case tram
    case metro
    case nightBus
}
