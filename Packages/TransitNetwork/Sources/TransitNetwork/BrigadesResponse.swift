import CoreModels
import Foundation

// MARK: - BrigadesResponse

/// Response from the brigades endpoint.
public struct BrigadesResponse: Codable, Sendable {
    public let brigades: [Brigade]?
}

// MARK: - Brigade

public struct Brigade: Codable, Identifiable, Sendable {
    public let id: String
    public let trips: [BrigadeTrip]?
}

// MARK: - BrigadeTrip

public struct BrigadeTrip: Codable, Sendable {
    public let tripId: String?
    public let destination: LocalizedString?
    public let stops: [BrigadeTripStop]?
}

// MARK: - BrigadeTripStop

public struct BrigadeTripStop: Codable, Sendable {
    public let id: String?
    public let time: Double?
}
