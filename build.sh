#!/bin/sh
# Builds Countdown.app next to this script, for both Apple silicon and Intel Macs.
# Run: ./build.sh && open Countdown.app
set -e
cd "$(dirname "$0")"
APP=Countdown.app
TMP=$(mktemp -d)
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS"
for ARCH in arm64 x86_64; do
  swiftc -O -target "$ARCH-apple-macos14" Countdown.swift main.swift -o "$TMP/Countdown-$ARCH"
done
lipo -create "$TMP/Countdown-arm64" "$TMP/Countdown-x86_64" -output "$APP/Contents/MacOS/Countdown"
rm -rf "$TMP"
cat > "$APP/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>CFBundleExecutable</key><string>Countdown</string>
  <key>CFBundleIdentifier</key><string>com.example.menubar-countdown</string>
  <key>CFBundleName</key><string>Countdown</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleShortVersionString</key><string>1.0.0</string>
  <key>LSMinimumSystemVersion</key><string>14.0</string>
  <key>LSUIElement</key><true/>
</dict></plist>
PLIST
# Ad-hoc signature: enough for your own Mac. No Apple developer account needed.
codesign --force --sign - "$APP"
echo "Built $APP"
