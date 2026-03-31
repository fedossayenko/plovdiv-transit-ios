import Foundation

/// A transit stop in the Plovdiv network.
public struct Stop: Identifiable, Hashable, Sendable {
    public let id: String
    public let code: String
    public let name: LocalizedString
    public let geo: StopGeo

    public init(id: String, code: String, name: LocalizedString, geo: StopGeo) {
        self.id = id
        self.code = code
        self.name = name
        self.geo = geo
    }
}

public struct StopGeo: Codable, Hashable, Sendable {
    public let coords: Coordinate
    public let bearing: Int

    public init(coords: Coordinate, bearing: Int) {
        self.coords = coords
        self.bearing = bearing
    }
}

extension Stop: Codable {}
