import CoreModels
import MapFeature
import ScheduleFeature
import StopFeature
import SwiftUI
import TransitNetwork

// MARK: - PlovdivTransitApp

@main
struct PlovdivTransitApp: App {
    @State private var transitService = TransitService()
    @State private var favoritesStore = FavoritesStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(transitService)
                .environment(favoritesStore)
                .task {
                    await transitService.start()
                }
        }
    }
}

// MARK: - ContentView

struct ContentView: View {
    @Environment(TransitService.self) private var transitService

    var body: some View {
        TabView {
            Tab("Map", systemImage: "map.fill") {
                TransitMapView()
            }
            Tab("Stops", systemImage: "magnifyingglass") {
                StopSearchView()
            }
            Tab("Lines", systemImage: "bus.fill") {
                LinesListView()
            }
        }
        .overlay(alignment: .top) {
            if !transitService.isConnected, !transitService.isLoading {
                Label("Reconnecting...", systemImage: "wifi.slash")
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.red.opacity(0.9), in: .capsule)
                    .foregroundStyle(.white)
                    .padding(.top, 4)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .overlay {
            if transitService.isLoading {
                ProgressView("Loading Plovdiv transit...")
                    .padding()
                    .background(.ultraThinMaterial, in: .rect(cornerRadius: 16))
            }
        }
        .animation(.easeInOut, value: transitService.isConnected)
    }
}
