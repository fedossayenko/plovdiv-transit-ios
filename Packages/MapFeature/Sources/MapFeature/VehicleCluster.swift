import CoreModels
import Foundation

/// Groups nearby vehicles into clusters for map display at low zoom levels.
enum VehicleClusterer {
    /// Grid cell size in degrees for clustering.
    private static let cellSize = 0.005

    struct Cluster: Identifiable {
        let id: String
        let center: Coordinate
        let vehicles: [Vehicle]

        var count: Int {
            vehicles.count
        }

        var dominantLineId: String? {
            Dictionary(grouping: vehicles, by: \.lineId)
                .max(by: { $0.value.count < $1.value.count })?
                .key
        }
    }

    /// Clusters vehicles by geographic grid cells.
    static func cluster(_ vehicles: [Vehicle]) -> [Cluster] {
        let grouped = Dictionary(grouping: vehicles) { vehicle in
            let latCell = Int(vehicle.coords.latitude / cellSize)
            let lngCell = Int(vehicle.coords.longitude / cellSize)
            return "\(latCell)_\(lngCell)"
        }

        return grouped.map { key, vehicles in
            let avgLat = vehicles.map(\.coords.latitude).reduce(0, +) / Double(vehicles.count)
            let avgLng = vehicles.map(\.coords.longitude).reduce(0, +) / Double(vehicles.count)
            return Cluster(
                id: key,
                center: Coordinate(latitude: avgLat, longitude: avgLng),
                vehicles: vehicles,
            )
        }
    }
}
