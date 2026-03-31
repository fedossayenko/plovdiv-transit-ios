@testable import CoreModels
import Foundation
import Testing

struct FavoritesStoreTests {
    @Test
    @MainActor
    func `Toggle stop adds and removes`() {
        let store = FavoritesStore()
        #expect(!store.isFavorite(stopId: "test_stop"))

        store.toggleStop("test_stop")
        #expect(store.isFavorite(stopId: "test_stop"))

        store.toggleStop("test_stop")
        #expect(!store.isFavorite(stopId: "test_stop"))
    }

    @Test
    @MainActor
    func `Toggle line adds and removes`() {
        let store = FavoritesStore()
        #expect(!store.isFavorite(lineId: "test_line"))

        store.toggleLine("test_line")
        #expect(store.isFavorite(lineId: "test_line"))

        store.toggleLine("test_line")
        #expect(!store.isFavorite(lineId: "test_line"))
    }

    @Test
    @MainActor
    func `Multiple favorites coexist`() {
        let store = FavoritesStore()
        store.toggleStop("s1")
        store.toggleStop("s2")
        store.toggleLine("l1")

        #expect(store.isFavorite(stopId: "s1"))
        #expect(store.isFavorite(stopId: "s2"))
        #expect(store.isFavorite(lineId: "l1"))
        #expect(!store.isFavorite(lineId: "l2"))

        #expect(store.favoriteStopIds.count == 2)
        #expect(store.favoriteLineIds.count == 1)
    }
}
