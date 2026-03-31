import SwiftUI

/// Shows delay status with color coding, symbol, and accessibility label.
public struct DelayIndicator: View {
    let delaySeconds: TimeInterval

    public init(delaySeconds: TimeInterval) {
        self.delaySeconds = delaySeconds
    }

    public var body: some View {
        Label(text, systemImage: symbolName)
            .font(TransitTypography.caption)
            .foregroundStyle(color)
            .accessibilityLabel(accessibilityText)
    }

    private var minutes: Int {
        Int(delaySeconds / 60)
    }

    private var text: String {
        if abs(minutes) < 1 {
            return "On time"
        }
        return minutes > 0 ? "+\(minutes) min" : "\(minutes) min"
    }

    private var symbolName: String {
        if abs(minutes) < 1 {
            return "checkmark.circle.fill"
        }
        return minutes > 0 ? "arrow.up.circle.fill" : "arrow.down.circle.fill"
    }

    private var color: Color {
        if abs(minutes) < 1 {
            return TransitColors.onTime
        }
        return minutes > 0 ? TransitColors.delayPositive : TransitColors.delayNegative
    }

    private var accessibilityText: String {
        if abs(minutes) < 1 {
            return "On time"
        }
        return minutes > 0 ? "\(minutes) minutes late" : "\(abs(minutes)) minutes early"
    }
}
