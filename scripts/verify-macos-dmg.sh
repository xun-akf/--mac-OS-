#!/usr/bin/env bash
set -euo pipefail

dmg='release/Project-Investment-Manager-mac-arm64.dmg'
test -s "$dmg"
mount_point="$RUNNER_TEMP/project-manager-dmg"
mkdir -p "$mount_point"
hdiutil attach "$dmg" -readonly -nobrowse -mountpoint "$mount_point"
trap 'hdiutil detach "$mount_point"' EXIT
app="$mount_point/项目投资资料管理工具.app"
contents="$app/Contents"
test -d "$app"
test -L "$mount_point/Applications"
test "$(readlink "$mount_point/Applications")" = /Applications
plist="$contents/Info.plist"
test -s "$plist"
plutil -lint "$plist"
test "$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$plist")" = 'cn.project.investment.manager'
binary_name="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleExecutable' "$plist")"
binary="$contents/MacOS/$binary_name"
test -x "$binary"
test -s "$contents/Resources/app.asar"
test -d "$contents/Frameworks/Electron Framework.framework"
test -x "$contents/Frameworks/Electron Framework.framework/Electron Framework"
for helper in '项目投资资料管理工具 Helper' '项目投资资料管理工具 Helper (Renderer)' '项目投资资料管理工具 Helper (GPU)' '项目投资资料管理工具 Helper (Plugin)'; do
  test -x "$contents/Frameworks/$helper.app/Contents/MacOS/$helper"
done
native_module="$(find "$contents/Resources" -name better_sqlite3.node -type f -print -quit)"
test -n "$native_module"

while IFS= read -r -d '' executable; do
  file "$executable" | grep -q 'Mach-O' || continue
  lipo "$executable" -verify_arch arm64
  codesign --verify --strict --verbose=2 "$executable"
done < <(find "$contents" -type f -perm -111 -print0)
lipo "$native_module" -verify_arch arm64
codesign --verify --strict --verbose=2 "$native_module"
codesign --verify --deep --strict --verbose=2 "$app"
codesign -dv --verbose=4 "$app" 2>&1 | tee "$RUNNER_TEMP/app-signature.txt"
grep -q 'Signature=adhoc' "$RUNNER_TEMP/app-signature.txt"
if xattr -lr "$app" | tee "$RUNNER_TEMP/app-xattrs.txt" | grep -q 'com.apple.quarantine'; then
  echo 'Unexpected quarantine attribute embedded in the DMG app' >&2
  exit 1
fi

# A downloaded ad-hoc signed app is not notarized. Record Gatekeeper's real
# assessment rather than claiming acceptance from a local integrity check.
if spctl --assess --type execute --verbose=4 "$app"; then
  echo 'Gatekeeper accepted the app.'
else
  echo 'Gatekeeper rejected the ad-hoc signed app; Developer ID signing and notarization are required for normal downloaded-app opening.'
fi
