import Foundation

/// Persists favorite stops and lines using UserDefaults.
@Observable
@MainActor
public final class FavoritesStore {
    private static let stopKey = "favoriteStops"
    private static let lineKey = "favoriteLines"

    private(set) public var favoriteStopIds: Set<String>
    private(set) public var favoriteLineIds: Set<String>

    public init() {
        let stops = UserDefaults.standard.stringArray(forKey: Self.stopKey) ?? []
        let lines = UserDefaults.standard.stringArray(forKey: Self.lineKey) ?? []
        favoriteStopIds = Set(stops)
        favoriteLineIds = Set(lines)
    }

    public func isFavorite(stopId: String) -> Bool {
        favoriteStopIds.contains(stopId)
    }

    public func isFavorite(lineId: String) -> Bool {
        favoriteLineIds.contains(lineId)
    }

    public func toggleStop(_ id: String) {
        if favoriteStopIds.contains(id) {
            favoriteStopIds.remove(id)
        } else {
            favoriteStopIds.insert(id)
        }
        UserDefaults.standard.set(Array(favoriteStopIds), forKey: Self.stopKey)
    }

    public func toggleLine(_ id: String) {
        if favoriteLineIds.contains(id) {
            favoriteLineIds.remove(id)
        } else {
            favoriteLineIds.insert(id)
        }
        UserDefaults.standard.set(Array(favoriteLineIds), forKey: Self.lineKey)
    }
}
