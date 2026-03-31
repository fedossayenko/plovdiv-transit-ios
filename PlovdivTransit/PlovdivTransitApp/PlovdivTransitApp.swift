import SwiftUI
import TransitNetwork
import MapFeature
import StopFeature
import ScheduleFeature

@main
struct PlovdivTransitApp: App {
    @State private var transitService = TransitService()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(transitService)
                .task {
                    await transitService.start()
                }
        }
    }
}

struct ContentView: View {
    @Environment(TransitService.self) private var transitService

    var body: some View {
        TabView {
            Tab("Map", systemImage: "map.fill") {
                TransitMapView()
            }
            Tab("Lines", systemImage: "bus.fill") {
                LinesListView()
            }
        }
        .overlay {
            if transitService.isLoading {
                ProgressView("Loading Plovdiv transit...")
                    .padding()
                    .background(.ultraThinMaterial, in: .rect(cornerRadius: 16))
            }
        }
    }
}
