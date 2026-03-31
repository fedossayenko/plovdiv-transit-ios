import Foundation

/// Bilingual string with Bulgarian and English variants, matching the API format.
public struct LocalizedString: Codable, Hashable, Sendable {
    public let bg: String
    public let en: String

    public init(bg: String, en: String) {
        self.bg = bg
        self.en = en
    }

    /// Returns the localized value based on the current device locale.
    public var localized: String {
        if #available(iOS 16, macOS 13, *) {
            return Locale.current.language.languageCode?.identifier == "bg" ? bg : en
        } else {
            return Locale.current.languageCode == "bg" ? bg : en
        }
    }
}
