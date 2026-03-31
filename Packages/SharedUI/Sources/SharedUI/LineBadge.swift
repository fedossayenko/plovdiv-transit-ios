import SwiftUI
import CoreModels

/// Displays a transit line number badge with the line's color.
public struct LineBadge: View {
    let line: TransitLine

    public init(line: TransitLine) {
        self.line = line
    }

    public var body: some View {
        Text(line.name)
            .font(TransitTypography.lineNumber)
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .background(Color(hex: line.color), in: .capsule)
    }
}
