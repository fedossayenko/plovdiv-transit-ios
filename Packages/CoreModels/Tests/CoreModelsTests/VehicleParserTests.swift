import Testing
import Foundation
@testable import CoreModels

@Suite("VehicleParser")
struct VehicleParserTests {

    @Test("Parses EVehicle2 tuple with delay")
    func parseVehicle2() throws {
        let tuple: [Any] = [
            "3/PB0104PE",
            "bus",
            "28",
            "6",
            ["bg": "Прослав 1", "en": "Proslav 1"],
            18000,
            [42.151884, 24.773591],
            311,
            0,
            1774968518000.0
        ]

        let vehicle = VehicleParser.parseVehicleTuple(tuple)
        #expect(vehicle != nil)
        #expect(vehicle?.id == "3/PB0104PE")
        #expect(vehicle?.type == .bus)
        #expect(vehicle?.lineId == "28")
        #expect(vehicle?.blockId == "6")
        #expect(vehicle?.destination.bg == "Прослав 1")
        #expect(vehicle?.destination.en == "Proslav 1")
        #expect(vehicle?.delay == 18.0) // 18000ms = 18s
        #expect(vehicle?.coords.latitude == 42.151884)
        #expect(vehicle?.coords.longitude == 24.773591)
        #expect(vehicle?.bearing == 311)
        #expect(vehicle?.speed == 0)
    }

    @Test("Parses negative delay (early vehicle)")
    func parseNegativeDelay() throws {
        let tuple: [Any] = [
            "3/PB3235CP",
            "bus",
            "14",
            "3",
            ["bg": "Тракия А12", "en": "Trakiya A12"],
            -345000,
            [42.133919, 24.736032],
            75,
            38,
            1774968545000.0
        ]

        let vehicle = VehicleParser.parseVehicleTuple(tuple)
        #expect(vehicle != nil)
        #expect(vehicle?.delay == -345.0)
        #expect(vehicle?.isEarly == true)
        #expect(vehicle?.isDelayed == false)
        #expect(vehicle?.speed == 38)
    }

    @Test("Parses full WebSocket message")
    func parseWebSocketMessage() throws {
        let json = """
        [
            ["3/PB0104PE","bus","28","6",{"bg":"Прослав 1","en":"Proslav 1"},18000,[42.151884,24.773591],311,0,1774968518000],
            ["3/PB0778XT","bus","2","6",{"bg":"Прослав","en":"Proslav"},296000,[42.130897,24.754898],182,42,1774968545000]
        ]
        """
        let data = json.data(using: .utf8)!
        let vehicles = try VehicleParser.parseWebSocketMessage(data)
        #expect(vehicles.count == 2)
        #expect(vehicles[0].id == "3/PB0104PE")
        #expect(vehicles[1].id == "3/PB0778XT")
        #expect(vehicles[1].speed == 42)
    }

    @Test("Returns nil for malformed tuple")
    func parseMalformed() {
        let tuple: [Any] = ["only", "two"]
        let vehicle = VehicleParser.parseVehicleTuple(tuple)
        #expect(vehicle == nil)
    }

    @Test("LocalizedString returns correct locale")
    func localizedString() {
        let str = LocalizedString(bg: "Пловдив", en: "Plovdiv")
        // In test environment, default should be English
        #expect(str.en == "Plovdiv")
        #expect(str.bg == "Пловдив")
    }

    @Test("Coordinate decodes from JSON array")
    func coordinateDecode() throws {
        let json = "[42.12793, 24.70177]"
        let data = json.data(using: .utf8)!
        let coord = try JSONDecoder().decode(Coordinate.self, from: data)
        #expect(coord.latitude == 42.12793)
        #expect(coord.longitude == 24.70177)
    }

    @Test("DepartureTime decodes from millisecond timestamps")
    func departureTimeDecode() throws {
        let json = """
        {"scheduled": 1774968840000, "actual": 1774968900000}
        """
        let data = json.data(using: .utf8)!
        let time = try JSONDecoder().decode(DepartureTime.self, from: data)
        #expect(time.delay == 60.0) // 60 seconds late
    }
}
