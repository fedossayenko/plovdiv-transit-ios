import SwiftUI
import CoreModels
import TransitNetwork
import SharedUI

/// Shows all transit lines, grouped by type.
public struct LinesListView: View {
    @Environment(TransitService.self) private var transitService

    public init() {}

    public var body: some View {
        NavigationStack {
            List {
                let grouped = Dictionary(grouping: transitService.lines) { $0.type }
                let sortedTypes = grouped.keys.sorted { $0.rawValue < $1.rawValue }

                ForEach(sortedTypes, id: \.self) { type in
                    Section(type.rawValue.capitalized) {
                        let lines = (grouped[type] ?? [])
                            .sorted { lineNumber($0.name) < lineNumber($1.name) }

                        ForEach(lines) { line in
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
                    }
                }
            }
            .navigationTitle("Lines")
        }
    }

    private func lineNumber(_ name: String) -> Int {
        Int(name.filter(\.isNumber)) ?? Int.max
    }
}
