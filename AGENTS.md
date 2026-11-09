# AGENTS.md

Instructions for AI coding agents (Claude Code, Cursor, Codex, Copilot and others) working in this repository. Humans are welcome to read it too.

## What this is

A tiny macOS menu bar app (an `LSUIElement` agent, no Dock icon) that counts down to one date. Plain Swift and AppKit, no dependencies, no Xcode project and no package manager: `build.sh` compiles two files with `swiftc` into `Countdown.app`.

The person you're helping may not be a programmer. Explain what you're doing in plain words, avoid jargon, and tell them exactly what to click when something has to happen on their screen.

## Installing it for someone

1. Check the developer tools: `xcode-select -p`. If it fails, run `xcode-select --install` and tell them to click **Install** in the window that appears and wait for it to finish. A full Xcode install also works but isn't needed.
2. Get the code: `git clone https://github.com/Rickboers/menubar-countdown.git` into a folder they'll keep (for example `~/Documents/menubar-countdown`), or have them use **Code → Download ZIP** on GitHub and unzip it.
3. Build and start it: `./build.sh && open Countdown.app`.
4. Offer to copy it to Applications so it survives deleting the folder: `ditto Countdown.app /Applications/Countdown.app && open /Applications/Countdown.app`. Quit the copy running from the project folder first (its menu → Quit), so there's only one.
5. Tell them to look at the top right of the screen and click the countdown to set their date. Mention that **Launch at Login** is switched on the first time it opens, and that they can untick it in the same menu.

Requirements: macOS 14 Sonoma or newer, Apple silicon or Intel.

After any code change: quit the running app, run `./build.sh`, then `open Countdown.app` (and copy it to Applications again if that's where they keep it). Remind them every time.

## Files

| File | Job |
| --- | --- |
| `Countdown.swift` | pure logic, no AppKit: `Granularity`, `countdownText(_:_:)` (the menu bar text) and `secondsUntilNextChange(_:_:)` (when the timer should next fire) |
| `main.swift` | the app: status item, menu with date picker, display modes, Launch at Login (`SMAppService.mainApp`), and settings in `UserDefaults` (`target`, `granularity`, `loginConfigured`) |
| `build.sh` | compiles a universal (arm64 + x86_64) binary, writes `Info.plist`, ad-hoc signs the app |
| `test.sh`, `Tests/main.swift` | compiles `Countdown.swift` with the tests and runs them; exits non-zero on a failure |

## Rules

Keep these unless the person explicitly asks otherwise.

1. **Stay light.** The timer fires only when the shown text changes, never on a fixed fast interval. Keep it that way: it's why the app uses almost no battery.
2. **Logic goes in `Countdown.swift`** (no AppKit there) and gets a test in `Tests/main.swift`. `main.swift` only wires it to the menu bar.
3. **No data leaves the Mac.** No network requests, analytics, update checks or third-party code. The app needs no permissions; don't add entitlements or permission prompts without telling the person why.
4. **No dependencies and no Xcode project.** It must keep building with `./build.sh` and only Apple's command line tools.
5. **Keep settings compatible.** Don't rename the `UserDefaults` keys, or people lose their date when they update.
6. **Never commit personal data**, such as account names, emails, Apple team IDs, or file paths from your own machine. Don't commit `Countdown.app`; it's build output and `.gitignore` excludes it.

## Common changes

- **Change how the text looks** (for example `12 days` instead of `12d`): edit `countdownText` in `Countdown.swift` and update the matching expectations in `Tests/main.swift`.
- **Add a display mode:** add a case to `Granularity` with its `title` and `unit`, handle it in `countdownText`, and add tests. The menu picks up new cases by itself.
- **Add a menu item:** add it in `buildMenu()` in `main.swift`, with `target = self` and an `@objc` action.
- **Notify at zero:** this needs `UserNotifications` and asks the person for permission the first time. Say so before adding it.

Update the README's "Using it" table and `CHANGELOG.md` whenever what people see changes.

## Checking your work

1. `./test.sh` must print `All countdown tests passed`.
2. `./build.sh` must finish with `Built Countdown.app`.
3. By hand: quit the old copy, `open Countdown.app`, and check the menu bar text in each mode, changing the date, Launch at Login on and off, and Quit.

CI (`.github/workflows/test.yml`) runs `./test.sh` and `./build.sh` on macOS for every push and pull request.

## Releasing

Bump `CFBundleShortVersionString` in `build.sh` (semantic versioning), add a dated entry to `CHANGELOG.md`, run `./test.sh` and `./build.sh`, then commit. A downloadable app that opens without warnings on other Macs needs a Developer ID signature and Apple notarization, which this project doesn't do yet; the ad-hoc signature from `build.sh` is only for the Mac that built it.
