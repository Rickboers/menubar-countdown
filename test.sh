#!/bin/sh
# Runs the countdown tests. Run: ./test.sh
set -e
cd "$(dirname "$0")"
OUT=$(mktemp -d)
swiftc Countdown.swift Tests/main.swift -o "$OUT/countdown-tests"
"$OUT/countdown-tests"
rm -rf "$OUT"
