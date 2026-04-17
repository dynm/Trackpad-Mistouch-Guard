#!/usr/bin/env bash
set -euo pipefail

MODE="${1:-run}"
APP_NAME="Mistouch Guard"
EXECUTABLE_NAME="Mistouch Guard"
BUILD_PRODUCT_NAME="anti-mistouch"
BUNDLE_ID="com.dynm.mistouchguard"
MIN_SYSTEM_VERSION="13.0"
ICON_NAME="AppIcon"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DIST_DIR="$ROOT_DIR/dist"
APP_BUNDLE="$DIST_DIR/$APP_NAME.app"
APP_CONTENTS="$APP_BUNDLE/Contents"
APP_MACOS="$APP_CONTENTS/MacOS"
APP_RESOURCES="$APP_CONTENTS/Resources"
APP_BINARY="$APP_MACOS/$EXECUTABLE_NAME"
INFO_PLIST="$APP_CONTENTS/Info.plist"
MODULE_CACHE="$ROOT_DIR/.cache/swift-module"
CLANG_CACHE="$ROOT_DIR/.cache/clang-module"
ICONSET_DIR="$DIST_DIR/$ICON_NAME.iconset"
ICON_FILE="$APP_RESOURCES/$ICON_NAME.icns"

export HOME="$ROOT_DIR"
export SWIFTPM_ENABLE_PLUGINS=0
export SWIFTPM_MODULECACHE_OVERRIDE="$MODULE_CACHE"
export CLANG_MODULE_CACHE_PATH="$CLANG_CACHE"

mkdir -p "$DIST_DIR" "$APP_MACOS" "$MODULE_CACHE" "$CLANG_CACHE"

pkill -f "/Contents/MacOS/$EXECUTABLE_NAME" >/dev/null 2>&1 || true
pkill -x "$BUILD_PRODUCT_NAME" >/dev/null 2>&1 || true

swift build
BUILD_BINARY="$(swift build --show-bin-path)/$BUILD_PRODUCT_NAME"

rm -rf "$APP_BUNDLE"
rm -rf "$ICONSET_DIR"
mkdir -p "$APP_MACOS" "$APP_RESOURCES" "$ICONSET_DIR"
cp "$BUILD_BINARY" "$APP_BINARY"
chmod +x "$APP_BINARY"

generate_icon_png() {
  local file_name="$1"
  local pixel_size="$2"
  env \
    HOME="$ROOT_DIR" \
    CLANG_MODULE_CACHE_PATH="$CLANG_CACHE" \
    SWIFTPM_MODULECACHE_OVERRIDE="$MODULE_CACHE" \
    swift "$ROOT_DIR/script/generate_app_icon.swift" "$ICONSET_DIR/$file_name" "$pixel_size"
}

generate_icon_png icon_16x16.png 16
generate_icon_png icon_16x16@2x.png 32
generate_icon_png icon_32x32.png 32
generate_icon_png icon_32x32@2x.png 64
generate_icon_png icon_128x128.png 128
generate_icon_png icon_128x128@2x.png 256
generate_icon_png icon_256x256.png 256
generate_icon_png icon_256x256@2x.png 512
generate_icon_png icon_512x512.png 512
generate_icon_png icon_512x512@2x.png 1024

iconutil -c icns "$ICONSET_DIR" -o "$ICON_FILE"

cat >"$INFO_PLIST" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleExecutable</key>
  <string>$EXECUTABLE_NAME</string>
  <key>CFBundleIdentifier</key>
  <string>$BUNDLE_ID</string>
  <key>CFBundleIconFile</key>
  <string>$ICON_NAME</string>
  <key>CFBundleDisplayName</key>
  <string>$APP_NAME</string>
  <key>CFBundleName</key>
  <string>$APP_NAME</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>LSMinimumSystemVersion</key>
  <string>$MIN_SYSTEM_VERSION</string>
  <key>NSPrincipalClass</key>
  <string>NSApplication</string>
</dict>
</plist>
PLIST

open_app() {
  /usr/bin/open -n "$APP_BUNDLE"
}

case "$MODE" in
  --bundle|bundle)
    ;;
  run)
    open_app
    ;;
  --debug|debug)
    lldb -- "$APP_BINARY"
    ;;
  --logs|logs)
    open_app
    /usr/bin/log stream --info --style compact --predicate "process == \"$EXECUTABLE_NAME\""
    ;;
  --telemetry|telemetry)
    open_app
    /usr/bin/log stream --info --style compact --predicate "subsystem == \"$BUNDLE_ID\""
    ;;
  --verify|verify)
    open_app
    sleep 1
    pgrep -f "/Contents/MacOS/$EXECUTABLE_NAME" >/dev/null
    ;;
  *)
    echo "usage: $0 [bundle|run|--debug|--logs|--telemetry|--verify]" >&2
    exit 2
    ;;
esac
