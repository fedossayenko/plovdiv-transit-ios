import CoreModels
import SharedUI
import SwiftUI
import TransitNetwork

/// Shows all transit lines, grouped by type.
public struct LinesListView: View {
    @Environment(TransitService.self) private var transitService
    @Environment(FavoritesStore.self) private var favoritesStore

    public init() {}

    public var body: some View {
        NavigationStack {
            List {
                // Favorite lines
                let favoriteLines = favoritesStore.favoriteLineIds.compactMap { transitService.line(for: $0) }
                if !favoriteLines.isEmpty {
                    Section("Favorites") {
                        ForEach(favoriteLines) { line in
                            NavigationLink(value: line) {
                                lineRow(line)
                            }
                        }
                    }
                }

                let grouped = Dictionary(grouping: transitService.lines) { $0.type }
                let sortedTypes = grouped.keys.sorted { $0.rawValue < $1.rawValue }

                ForEach(sortedTypes, id: \.self) { type in
                    Section(type.rawValue.capitalized) {
                        let lines = (grouped[type] ?? [])
                            .sorted { lineNumber($0.name) < lineNumber($1.name) }

                        ForEach(lines) { line in
                            NavigationLink(value: line) {
                                lineRow(line)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Lines")
            .navigationDestination(for: TransitLine.self) { line in
                LineDetailView(line: line)
            }
        }
    }

    private func lineRow(_ line: TransitLine) -> some View {
        HStack {
            LineBadge(line: line)
            Text(line.routeName)
                .font(.body)
            Spacer()
            let count = transitService.vehicles(onLine: line.id).count
            if count > 0 {
                Text("\(count)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(.quaternary, in: .capsule)
            }
        }
    }

    private func lineNumber(_ name: String) -> Int {
        Int(name.filter(\.isNumber)) ?? Int.max
    }
}
