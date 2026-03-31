import CoreLocation

/// Decodes Google Encoded Polyline format into coordinates.
/// Used for route shapes from the trip API.
///
/// Reference: https://developers.google.com/maps/documentation/utilities/polylinealgorithm
public enum PolylineDecoder {

    public static func decode(_ encoded: String) -> [CLLocationCoordinate2D] {
        var coordinates: [CLLocationCoordinate2D] = []
        var index = encoded.startIndex
        var lat: Int32 = 0
        var lng: Int32 = 0

        while index < encoded.endIndex {
            lat += decodeValue(from: encoded, index: &index)
            lng += decodeValue(from: encoded, index: &index)
            coordinates.append(CLLocationCoordinate2D(
                latitude: Double(lat) / 1e5,
                longitude: Double(lng) / 1e5
            ))
        }

        return coordinates
    }

    private static func decodeValue(from string: String, index: inout String.Index) -> Int32 {
        var result: Int32 = 0
        var shift: Int32 = 0
        var byte: Int32

        repeat {
            byte = Int32(string[index].asciiValue! - 63)
            index = string.index(after: index)
            result |= (byte & 0x1F) << shift
            shift += 5
        } while byte >= 0x20

        return (result & 1) != 0 ? ~(result >> 1) : (result >> 1)
    }
}
