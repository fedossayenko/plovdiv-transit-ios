import Foundation

public extension Date {
    /// Formats as "HH:mm" in the Sofia timezone.
    var transitTimeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.timeZone = TimeZone(identifier: "Europe/Sofia")
        return formatter.string(from: self)
    }

    /// Minutes from now, clamped to 0.
    var minutesFromNow: Int {
        max(0, Int(timeIntervalSinceNow / 60))
    }
}
