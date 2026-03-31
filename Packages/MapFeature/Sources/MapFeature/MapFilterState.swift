import CoreModels
import Foundation

/// Tracks which vehicle types and lines are visible on the map.
@Observable
@MainActor
final class MapFilterState {
    var hiddenLineIds: Set<String> = []
    var hiddenTypes: Set<VehicleType> = []

    func isVisible(_ vehicle: Vehicle) -> Bool {
        !hiddenTypes.contains(vehicle.type) && !hiddenLineIds.contains(vehicle.lineId)
    }

    func toggleType(_ type: VehicleType) {
        if hiddenTypes.contains(type) {
            hiddenTypes.remove(type)
        } else {
            hiddenTypes.insert(type)
        }
    }

    func toggleLine(_ lineId: String) {
        if hiddenLineIds.contains(lineId) {
            hiddenLineIds.remove(lineId)
        } else {
            hiddenLineIds.insert(lineId)
        }
    }

    func showAll() {
        hiddenLineIds.removeAll()
        hiddenTypes.removeAll()
    }
}
