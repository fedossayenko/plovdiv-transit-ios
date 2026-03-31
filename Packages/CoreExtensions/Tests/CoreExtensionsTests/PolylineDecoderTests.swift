@testable import CoreExtensions
import CoreLocation
import Testing

struct PolylineDecoderTests {
    @Test
    func `Decodes simple encoded polyline`() {
        // Encoded polyline for a straight line from (38.5, -120.2) to (40.7, -120.95) to (43.252, -126.453)
        let encoded = "_p~iF~ps|U_ulLnnqC_mqNvxq`@"
        let coords = PolylineDecoder.decode(encoded)

        #expect(coords.count == 3)
        #expect(abs(coords[0].latitude - 38.5) < 0.001)
        #expect(abs(coords[0].longitude - -120.2) < 0.001)
        #expect(abs(coords[1].latitude - 40.7) < 0.001)
        #expect(abs(coords[1].longitude - -120.95) < 0.001)
        #expect(abs(coords[2].latitude - 43.252) < 0.001)
        #expect(abs(coords[2].longitude - -126.453) < 0.001)
    }

    @Test
    func `Empty string returns empty array`() {
        let coords = PolylineDecoder.decode("")
        #expect(coords.isEmpty)
    }

    @Test
    func `Single point polyline`() {
        // Encoded for approximately (42.14, 24.75) — Plovdiv center
        let encoded = "org`Gk}fvC"
        let coords = PolylineDecoder.decode(encoded)

        #expect(coords.count == 1)
        #expect(abs(coords[0].latitude - 42.14) < 0.05)
        #expect(abs(coords[0].longitude - 24.75) < 0.05)
    }
}
