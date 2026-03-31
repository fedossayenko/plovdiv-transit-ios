import SwiftUI

/// Shows delay status with color coding.
public struct DelayIndicator: View {
    let delaySeconds: TimeInterval

    public init(delaySeconds: TimeInterval) {
        self.delaySeconds = delaySeconds
    }

    public var body: some View {
        Text(text)
            .font(TransitTypography.caption)
            .foregroundStyle(color)
    }

    private var text: String {
        let minutes = Int(delaySeconds / 60)
        if abs(minutes) < 1 { return "On time" }
        return minutes > 0 ? "+\(minutes) min" : "\(minutes) min"
    }

    private var color: Color {
        let minutes = Int(delaySeconds / 60)
        if abs(minutes) < 1 { return TransitColors.onTime }
        return minutes > 0 ? TransitColors.delayPositive : TransitColors.delayNegative
    }
}
