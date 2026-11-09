import Foundation

// The countdown's rules, kept apart from the menu bar code so they can be tested on their own.

enum Granularity: Int, CaseIterable {
    case days, minutes, seconds
    var title: String { ["Days", "Minutes", "Seconds"][rawValue] }
    var unit: TimeInterval { [86_400, 60, 1][rawValue] }
}

/// The text shown in the menu bar for the time that's left.
func countdownText(_ remaining: TimeInterval, _ granularity: Granularity) -> String {
    let total = Int(remaining)
    guard total > 0 else { return "Done" }
    let d = total / 86_400, h = total % 86_400 / 3_600, m = total % 3_600 / 60, s = total % 60
    switch granularity {
    case .days:
        return d > 0 ? "\(d)d" : "<1d"
    case .minutes:
        if d > 0 { return "\(d)d \(h)h \(m)m" }
        return h > 0 ? "\(h)h \(m)m" : "\(m)m"
    case .seconds:
        let clock = String(format: "%02d:%02d:%02d", h, m, s)
        return d > 0 ? "\(d)d \(clock)" : clock
    }
}

/// Seconds until the shown value next drops by one unit, so the timer only wakes when the text changes.
func secondsUntilNextChange(_ remaining: TimeInterval, _ granularity: Granularity) -> TimeInterval {
    let unit = granularity.unit
    let steps = (remaining / unit).rounded(.down)
    var fireIn = remaining - steps * unit
    if fireIn < 0.01 { fireIn += unit }
    return fireIn
}
