import Foundation

// Tests for Countdown.swift. Run with ./test.sh (no Xcode project needed).

var failures = 0
func expect<T: Equatable>(_ got: T, _ want: T, _ what: String, line: Int = #line) {
    if got != want {
        failures += 1
        print("FAIL line \(line): \(what): got \(got), want \(want)")
    }
}

let day: TimeInterval = 86_400, hour: TimeInterval = 3_600, minute: TimeInterval = 60

// Days mode
expect(countdownText(3 * day + 5 * hour, .days), "3d", "days rounds down")
expect(countdownText(5 * hour, .days), "<1d", "under a day")
expect(countdownText(0, .days), "Done", "zero is done")
expect(countdownText(-30, .days), "Done", "past target is done")

// Minutes mode
expect(countdownText(2 * day + 3 * hour + 4 * minute + 59, .minutes), "2d 3h 4m", "days, hours, minutes")
expect(countdownText(3 * hour + 4 * minute, .minutes), "3h 4m", "no days")
expect(countdownText(4 * minute + 30, .minutes), "4m", "only minutes")
expect(countdownText(30, .minutes), "0m", "under a minute")

// Seconds mode
expect(countdownText(1 * hour + 2 * minute + 3, .seconds), "01:02:03", "clock")
expect(countdownText(day + 5, .seconds), "1d 00:00:05", "clock with days")
expect(countdownText(0.4, .seconds), "Done", "less than a second left")

// The timer wakes exactly when the shown text changes
expect(secondsUntilNextChange(3 * day + 5 * hour, .days), 5 * hour, "next day boundary")
expect(secondsUntilNextChange(4 * minute + 30, .minutes), 30, "next minute boundary")
expect(secondsUntilNextChange(10.25, .seconds), 0.25, "next second boundary")
expect(secondsUntilNextChange(2 * minute, .minutes), 60, "on a boundary waits a full unit")

if failures > 0 {
    print("\(failures) test(s) failed")
    exit(1)
}
print("All countdown tests passed")
