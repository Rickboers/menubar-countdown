import AppKit
import ServiceManagement

// The menu bar app. Plain AppKit status item; the countdown rules live in Countdown.swift.
// The timer only fires when the displayed text would change:
// once per day in Days mode, once per minute in Minutes mode, once per second in Seconds mode.

final class AppDelegate: NSObject, NSApplicationDelegate {
    private let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private let defaults = UserDefaults.standard
    private var timer: Timer?
    private var granularityItems: [NSMenuItem] = []
    private let loginItem = NSMenuItem(title: "Launch at Login", action: #selector(toggleLogin), keyEquivalent: "")

    private var target: Date {
        get { Date(timeIntervalSince1970: defaults.double(forKey: "target")) }
        set { defaults.set(newValue.timeIntervalSince1970, forKey: "target") }
    }
    private var granularity: Granularity {
        get { Granularity(rawValue: defaults.integer(forKey: "granularity")) ?? .days }
        set { defaults.set(newValue.rawValue, forKey: "granularity") }
    }

    func applicationDidFinishLaunching(_ note: Notification) {
        if defaults.object(forKey: "target") == nil { target = Date().addingTimeInterval(7 * 86_400) }
        if !defaults.bool(forKey: "loginConfigured") {
            try? SMAppService.mainApp.register()
            defaults.set(true, forKey: "loginConfigured")
        }

        item.button?.font = .monospacedDigitSystemFont(ofSize: NSFont.systemFontSize, weight: .regular)
        item.menu = buildMenu()

        // Re-sync after sleep or a clock change, since the timer is scheduled against wall-clock time.
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(refresh), name: NSWorkspace.didWakeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: .NSSystemClockDidChange, object: nil)
        refresh()
    }

    private func buildMenu() -> NSMenu {
        let menu = NSMenu()
        menu.delegate = self

        let picker = NSDatePicker()
        picker.datePickerStyle = .textFieldAndStepper
        picker.datePickerElements = [.yearMonthDay, .hourMinute]
        picker.dateValue = target
        picker.target = self
        picker.action = #selector(dateChanged)
        picker.sizeToFit()
        let container = NSView(frame: NSRect(x: 0, y: 0, width: picker.frame.width + 28, height: picker.frame.height + 8))
        picker.setFrameOrigin(NSPoint(x: 14, y: 4))
        container.addSubview(picker)
        let pickerItem = NSMenuItem()
        pickerItem.view = container
        menu.addItem(pickerItem)
        menu.addItem(.separator())

        for g in Granularity.allCases {
            let mi = NSMenuItem(title: g.title, action: #selector(pickGranularity), keyEquivalent: "")
            mi.target = self
            mi.tag = g.rawValue
            granularityItems.append(mi)
            menu.addItem(mi)
        }
        menu.addItem(.separator())
        loginItem.target = self
        menu.addItem(loginItem)
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate), keyEquivalent: "q"))
        return menu
    }

    @objc private func dateChanged(_ sender: NSDatePicker) {
        target = sender.dateValue
        refresh()
    }

    @objc private func pickGranularity(_ sender: NSMenuItem) {
        granularity = Granularity(rawValue: sender.tag) ?? .days
        refresh()
    }

    @objc private func toggleLogin() {
        if SMAppService.mainApp.status == .enabled {
            try? SMAppService.mainApp.unregister()
        } else {
            try? SMAppService.mainApp.register()
        }
    }

    @objc private func refresh() {
        timer?.invalidate()
        timer = nil
        let remaining = target.timeIntervalSinceNow
        item.button?.title = format(remaining)
        guard remaining > 0 else { return }

        // Next moment the floored value drops by one unit.
        let fireIn = secondsUntilNextChange(remaining, granularity)
        let t = Timer(fire: Date().addingTimeInterval(fireIn + 0.01), interval: 0, repeats: false) { [weak self] _ in self?.refresh() }
        t.tolerance = granularity == .seconds ? 0.05 : 1
        RunLoop.main.add(t, forMode: .common)
        timer = t
    }

    private func format(_ remaining: TimeInterval) -> String {
        countdownText(remaining, granularity)
    }
}

extension AppDelegate: NSMenuDelegate {
    func menuNeedsUpdate(_ menu: NSMenu) {
        for mi in granularityItems { mi.state = mi.tag == granularity.rawValue ? .on : .off }
        loginItem.state = SMAppService.mainApp.status == .enabled ? .on : .off
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.accessory)
app.run()
