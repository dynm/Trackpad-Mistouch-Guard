# Mistouch Guard

[![macOS Build](https://github.com/dynm/Trackpad-Mistouch-Guard/actions/workflows/macos-build.yml/badge.svg)](https://github.com/dynm/Trackpad-Mistouch-Guard/actions/workflows/macos-build.yml)

`Mistouch Guard` is a native macOS menu bar app that suppresses trackpad-style pointer events for a short interval after each keystroke. It is inspired by [amanagr/TouchGuard](https://github.com/amanagr/TouchGuard), but packaged as a lightweight AppKit app instead of a launch daemon.

## Why This Project Exists

This project came from using this Apple Magic Keyboard trackpad tray design: [makerworld.com/en/models/1041556-apple-magic-keyboard-trackpad-tray](https://makerworld.com/en/models/1041556-apple-magic-keyboard-trackpad-tray).

The hardware setup is excellent, but in practice it makes it easy for a palm to brush the Magic Trackpad while typing. Those accidental touches can move the pointer, trigger scrolling, or shift focus and interrupt typing.

`Mistouch Guard` solves that specific problem in software by dropping mouse and scroll events for a brief window after each keystroke, so normal typing does not get interrupted by palm mistouches on the trackpad.

## Behavior

- Runs as a menu bar utility.
- Watches global `keyDown` events.
- Drops mouse and scroll events during a configurable suppression window after typing.
- Ignores modifier-only keys so shortcuts do not trigger extra pointer blocking.
- Exposes a small settings window for enable/disable and interval tuning.

## Requirements

- macOS 13 or later
- Accessibility permission
- Input Monitoring may also be required, depending on system policy

## Run

```bash
swift run
```

The first launch will prompt for Accessibility access. If the event tap still fails, also grant Input Monitoring in `System Settings > Privacy & Security`.

## Releases

GitHub Actions builds and tests the app on every push to `main` and on pull requests.

When you push a tag that starts with `v`, such as `v0.1.0`, the workflow also creates or updates a GitHub release and uploads a zipped `Mistouch Guard.app` bundle as a release asset.

## Installing From GitHub Releases

The release build is currently unsigned and not notarized. On macOS, apps downloaded from a browser usually get the `com.apple.quarantine` attribute, so Gatekeeper may block the first launch.

If that happens, use one of these options:

- In Finder, right-click the app and choose `Open`.
- Remove the quarantine attribute manually:

```bash
xattr -dr com.apple.quarantine "/Applications/Mistouch Guard.app"
```

## Notes

This implementation suppresses pointer events in software rather than toggling trackpad hardware state. That keeps the app simple and avoids relying on private or unsupported system interfaces.
