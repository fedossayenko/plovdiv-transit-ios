import CoreModels
import SharedUI
import SwiftUI
import TransitNetwork

/// Sheet for filtering which lines and vehicle types appear on the map.
struct MapFilterSheet: View {
    @Environment(TransitService.self) private var transitService
    @Environment(\.dismiss) private var dismiss
    @Binding var filterState: MapFilterState

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button("Show All") {
                        filterState.showAll()
                    }
                }

                let grouped = Dictionary(grouping: transitService.lines) { $0.type }
                let sortedTypes = grouped.keys.sorted { $0.rawValue < $1.rawValue }

                ForEach(sortedTypes, id: \.self) { type in
                    Section(type.rawValue.capitalized) {
                        // Type-level toggle
                        Toggle(isOn: Binding(
                            get: { !filterState.hiddenTypes.contains(type) },
                            set: { _ in filterState.toggleType(type) },
                        )) {
                            Text("All \(type.rawValue)")
                                .font(.headline)
                        }

                        // Individual lines
                        let lines = (grouped[type] ?? [])
                            .sorted { lineNumber($0.name) < lineNumber($1.name) }

                        ForEach(lines) { line in
                            Toggle(isOn: Binding(
                                get: { !filterState.hiddenLineIds.contains(line.id) },
                                set: { _ in filterState.toggleLine(line.id) },
                            )) {
                                HStack {
                                    LineBadge(line: line)
                                    Text(line.routeName)
                                        .font(.body)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Filter Lines")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func lineNumber(_ name: String) -> Int {
        Int(name.filter(\.isNumber)) ?? Int.max
    }
}
