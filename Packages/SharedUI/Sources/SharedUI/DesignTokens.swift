import SwiftUI

// MARK: - TransitColors

/// Design tokens for the Plovdiv Transit app.
public enum TransitColors {
    public static let busDefault = Color(hex: "#0073ac")
    public static let delayPositive = Color.red
    public static let delayNegative = Color.green
    public static let onTime = Color.primary
}

// MARK: - TransitTypography

public enum TransitTypography {
    public static let lineNumber = Font.system(.title3, design: .rounded, weight: .bold)
    public static let stopName = Font.system(.body, weight: .medium)
    public static let countdown = Font.system(.title, design: .monospaced, weight: .semibold)
    public static let caption = Font.system(.caption)
}

public extension Color {
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
