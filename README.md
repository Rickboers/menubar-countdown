# Menu Bar Countdown

A tiny Mac app that counts down to one date in your menu bar: a launch, a deadline, a trip. It shows **`12d`**, **`3h 20m`** or a ticking **`01:02:03`**, whichever you pick, and nothing else. No window, no Dock icon.

- **Free and open source** (MIT license).
- **Private.** It collects nothing and sends nothing. See [PRIVACY.md](PRIVACY.md).
- **Light.** One small file of code. It only wakes up when the number it shows changes: once a day, once a minute or once a second.
- Works on **macOS 14 Sonoma or newer**, on Apple silicon and Intel Macs.

---

## Install it (about 5 minutes, no coding)

There's no ready-made download yet, so your Mac builds the app from this folder with one command. It's free and needs no Apple account.

1. **Download** this project: click the green **Code** button at the top of this page, then **Download ZIP**, and unzip it. You get a folder called something like `menubar-countdown-main`.
2. Open **Terminal** (press ⌘ Space, type `Terminal`, press Return).
3. **First time only:** install Apple's free developer tools by pasting this and pressing Return, then click **Install** in the window that appears and wait for it to finish:
   ```
   xcode-select --install
   ```
   If it says they're already installed, that's fine, go on.
4. Type `cd ` (with a space after it), drag the unzipped folder onto the Terminal window, and press Return.
5. Paste this and press Return:
   ```
   ./build.sh && open Countdown.app
   ```
6. The countdown appears in your menu bar, at the top right of the screen. Click it to set your date.

To keep it, drag **Countdown.app** from the folder into your **Applications** folder and open it from there.

### Or let your AI install it

If you use an AI coding tool (Claude Code, Cursor, Codex, Windsurf, Copilot and the like), you can skip the steps above. Paste this:

> Clone https://github.com/Rickboers/menubar-countdown, read its AGENTS.md, and help me build and install the app on my Mac.

The [AGENTS.md](AGENTS.md) file tells the AI how the project works, how to install it for you and how to change it safely. You can then ask for changes in plain words, for example:

> Show "days left" instead of "d".
>
> Add a label in front of the number, like "Launch: 12d".
>
> Show a notification when the countdown reaches zero.

---

## Using it

Click the countdown in the menu bar:

| Menu item | What it does |
| --- | --- |
| Date and time | the moment you're counting down to. Click a part (day, hour…) and type, or use the arrows. |
| Days | shows whole days left, like `12d`. Under a day it shows `<1d`. |
| Minutes | shows days, hours and minutes, like `2d 3h 4m` |
| Seconds | a ticking clock, like `01:02:03` |
| Launch at Login | starts the countdown when you log in. It's turned on the first time you open the app; click it to turn it off. |
| Quit | closes the app |

When the date passes, it shows **Done**. Your date and choice are remembered when you quit.

## Troubleshooting

- **"command not found: swiftc" or "xcrun: error".** The developer tools from step 3 aren't installed yet. Run `xcode-select --install` again and wait for it to finish.
- **"permission denied: ./build.sh".** Run `chmod +x build.sh test.sh` once, then try again.
- **I can't see it in the menu bar.** On a Mac with a notch, a full menu bar can hide icons behind the notch. Quit an app with a menu bar icon, or hold ⌘ and drag icons to make room.
- **It started by itself after a restart.** That's Launch at Login. Untick it in the menu, or remove it in System Settings → General → Login Items.
- **macOS says it can't check the app for malicious software.** That only happens if you copied the app from another Mac. Build it on your own Mac with the steps above instead.

## Updating

Download the ZIP again (or `git pull` if you cloned it), quit the countdown, and run `./build.sh` again in the new folder. If you keep it in Applications, drag the new **Countdown.app** over the old one. Your date and choices stay.

## Removing it

Quit it from its menu, untick **Launch at Login** first if you want, and drag **Countdown.app** to the Trash.

## How it works

No dependencies and no Xcode project: two Swift files built with one command.

| File | Job |
| --- | --- |
| `Countdown.swift` | the countdown rules: the text it shows and when it next changes |
| `main.swift` | the menu bar icon, the menu, remembering your choices, and Launch at Login |
| `build.sh` | builds `Countdown.app` for Apple silicon and Intel and signs it for your own Mac |
| `test.sh`, `Tests/` | automated checks of the countdown rules |

It asks for no permissions. It saves your date and display choice in the app's own settings on your Mac.

## Contributing

Bug reports and improvements are welcome. Before a pull request, run `./test.sh` and `./build.sh` and try the change in the menu bar. [AGENTS.md](AGENTS.md) has the project's rules, which apply to people too.

## License

[MIT](LICENSE). Use it, change it, share it.
