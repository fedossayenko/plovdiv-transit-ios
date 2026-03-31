import Foundation

/// Parses the array-indexed vehicle data from the WebSocket.
///
/// The API sends vehicles as JSON arrays for bandwidth efficiency.
/// Two formats exist: EVehicle (9 fields, no delay) and EVehicle2 (10 fields, with delay).
public enum VehicleParser {

    /// Parses a WebSocket message containing an array of vehicle tuples.
    public static func parseWebSocketMessage(_ data: Data) throws -> [Vehicle] {
        let jsonArray = try JSONSerialization.jsonObject(with: data) as? [[Any]] ?? []
        return jsonArray.compactMap { parseVehicleTuple($0) }
    }

    /// Parses a single vehicle tuple array into a Vehicle struct.
    ///
    /// EVehicle2 format (10 fields):
    /// `[id, type, lineId, blockId, {destination}, delay_ms, [lat, lng], bearing, speed, lastUpdated_ms]`
    ///
    /// EVehicle format (9 fields, no delay):
    /// `[id, type, lineId, blockId, {destination}, [lat, lng], bearing, speed, lastUpdated_ms]`
    public static func parseVehicleTuple(_ tuple: [Any]) -> Vehicle? {
        let hasDelay = tuple.count >= 10

        guard tuple.count >= 9 else { return nil }

        guard
            let id = tuple[0] as? String,
            let typeString = tuple[1] as? String,
            let lineId = tuple[2] as? String,
            let blockId = tuple[3] as? String,
            let destDict = tuple[4] as? [String: String],
            let bg = destDict["bg"],
            let en = destDict["en"]
        else { return nil }

        let type = VehicleType(rawValue: typeString) ?? .bus

        let delayOffset = hasDelay ? 1 : 0
        let delayMs = hasDelay ? (tuple[5] as? Double ?? Double(tuple[5] as? Int ?? 0)) : 0

        guard
            let coordsArray = tuple[5 + delayOffset] as? [Any],
            coordsArray.count >= 2,
            let lat = coordsArray[0] as? Double,
            let lng = coordsArray[1] as? Double,
            let bearing = tuple[6 + delayOffset] as? Int,
            let speed = tuple[7 + delayOffset] as? Int,
            let lastUpdatedMs = tuple[8 + delayOffset] as? Double
        else { return nil }

        return Vehicle(
            id: id,
            type: type,
            lineId: lineId,
            blockId: blockId,
            destination: LocalizedString(bg: bg, en: en),
            delay: delayMs / 1000.0,
            coords: Coordinate(latitude: lat, longitude: lng),
            bearing: bearing,
            speed: speed,
            lastUpdated: Date(timeIntervalSince1970: lastUpdatedMs / 1000.0)
        )
    }
}
