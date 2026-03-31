import ActivityKit
import CoreModels
import SwiftUI
import WidgetKit

// MARK: - TransitLiveActivity

/// Live Activity showing bus arrival countdown on Lock Screen and Dynamic Island.
struct TransitLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TransitActivityAttributes.self) { context in
            // Lock Screen / banner presentation
            lockScreenView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded presentation
                DynamicIslandExpandedRegion(.leading) {
                    lineBadge(name: context.attributes.lineName, color: context.attributes.lineColor)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    countdownView(minutes: context.state.minutesUntilArrival)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    HStack {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundStyle(.secondary)
                        Text(context.attributes.stopName)
                            .font(.caption)
                        Spacer()
                        Image(systemName: "arrow.right")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Text(context.attributes.destination)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            } compactLeading: {
                lineBadge(name: context.attributes.lineName, color: context.attributes.lineColor)
            } compactTrailing: {
                countdownView(minutes: context.state.minutesUntilArrival)
            } minimal: {
                Text("\(context.state.minutesUntilArrival)")
                    .font(.caption.bold())
            }
        }
    }

    // MARK: - Lock Screen View

    private func lockScreenView(context: ActivityViewContext<TransitActivityAttributes>) -> some View {
        HStack(spacing: 12) {
            // Line badge
            lineBadge(name: context.attributes.lineName, color: context.attributes.lineColor)

            // Info
            VStack(alignment: .leading, spacing: 2) {
                Text(context.attributes.destination)
                    .font(.headline)
                Text(context.attributes.stopName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Countdown
            VStack(alignment: .trailing, spacing: 2) {
                if context.state.minutesUntilArrival <= 0 {
                    Text("Now")
                        .font(.title2.bold())
                        .foregroundStyle(.green)
                } else {
                    Text("\(context.state.minutesUntilArrival)")
                        .font(.title.bold().monospacedDigit())
                    Text("min")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            // Delay indicator
            if context.state.delaySeconds != 0 {
                let delayMin = Int(context.state.delaySeconds / 60)
                Text(delayMin > 0 ? "+\(delayMin)" : "\(delayMin)")
                    .font(.caption.bold())
                    .foregroundStyle(delayMin > 0 ? .red : .green)
            }
        }
        .padding()
    }

    // MARK: - Shared Components

    private func lineBadge(name: String, color: String) -> some View {
        Text(name)
            .font(.system(.caption, design: .rounded, weight: .bold))
            .foregroundStyle(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color(hex: color), in: .capsule)
    }

    private func countdownView(minutes: Int) -> some View {
        Group {
            if minutes <= 0 {
                Text("Now")
                    .font(.caption.bold())
                    .foregroundStyle(.green)
            } else {
                Text("\(minutes) min")
                    .font(.caption.bold().monospacedDigit())
            }
        }
    }
}

// MARK: - Color hex init (duplicated from SharedUI since widgets can't depend on app packages)

private extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255.0
        let g = Double((int >> 8) & 0xFF) / 255.0
        let b = Double(int & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}
