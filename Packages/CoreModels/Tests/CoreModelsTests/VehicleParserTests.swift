@testable import CoreModels
import Foundation
import Testing

struct VehicleParserTests {
    @Test
    func `Parses EVehicle2 tuple with delay`() {
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
            1_774_968_518_000.0,
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

    @Test
    func `Parses negative delay (early vehicle)`() {
        let tuple: [Any] = [
            "3/PB3235CP",
            "bus",
            "14",
            "3",
            ["bg": "Тракия А12", "en": "Trakiya A12"],
            -345_000,
            [42.133919, 24.736032],
            75,
            38,
            1_774_968_545_000.0,
        ]

        let vehicle = VehicleParser.parseVehicleTuple(tuple)
        #expect(vehicle != nil)
        #expect(vehicle?.delay == -345.0)
        #expect(vehicle?.isEarly == true)
        #expect(vehicle?.isDelayed == false)
        #expect(vehicle?.speed == 38)
    }

    @Test
    func `Parses full WebSocket message`() throws {
        let json = """
        [
            ["3/PB0104PE","bus","28","6",{"bg":"Прослав 1","en":"Proslav 1"},18000,[42.151884,24.773591],311,0,1774968518000],
            ["3/PB0778XT","bus","2","6",{"bg":"Прослав","en":"Proslav"},296000,[42.130897,24.754898],182,42,1774968545000]
        ]
        """
        let data = try #require(json.data(using: .utf8))
        let vehicles = try VehicleParser.parseWebSocketMessage(data)
        #expect(vehicles.count == 2)
        #expect(vehicles[0].id == "3/PB0104PE")
        #expect(vehicles[1].id == "3/PB0778XT")
        #expect(vehicles[1].speed == 42)
    }

    @Test
    func `Returns nil for malformed tuple`() {
        let tuple: [Any] = ["only", "two"]
        let vehicle = VehicleParser.parseVehicleTuple(tuple)
        #expect(vehicle == nil)
    }

    @Test
    func `LocalizedString returns correct locale`() {
        let str = LocalizedString(bg: "Пловдив", en: "Plovdiv")
        // In test environment, default should be English
        #expect(str.en == "Plovdiv")
        #expect(str.bg == "Пловдив")
    }

    @Test
    func `Coordinate decodes from JSON array`() throws {
        let json = "[42.12793, 24.70177]"
        let data = try #require(json.data(using: .utf8))
        let coord = try JSONDecoder().decode(Coordinate.self, from: data)
        #expect(coord.latitude == 42.12793)
        #expect(coord.longitude == 24.70177)
    }

    @Test
    func `DepartureTime decodes from millisecond timestamps`() throws {
        let json = """
        {"scheduled": 1774968840000, "actual": 1774968900000}
        """
        let data = try #require(json.data(using: .utf8))
        let time = try JSONDecoder().decode(DepartureTime.self, from: data)
        #expect(time.delay == 60.0) // 60 seconds late
    }
}
