#!/bin/sh
# Run from project root to fix iOS code signature / install issues (e.g. 0xe8008001)

set -e
cd "$(dirname "$0")/.."

echo "Cleaning Flutter..."
flutter clean

echo "Removing iOS build artifacts..."
rm -rf ios/build
rm -rf ios/Pods
rm -rf ios/Podfile.lock
rm -rf ios/.symlinks
rm -rf ios/Flutter/Flutter.framework
rm -rf ios/Flutter/Flutter.podspec

echo "Removing Xcode DerivedData for this project..."
DERIVED=~/Library/Developer/Xcode/DerivedData
if [ -d "$DERIVED" ]; then
  # Remove Runner-* entries for this project
  find "$DERIVED" -maxdepth 1 -type d -name "Runner-*" -exec rm -rf {} + 2>/dev/null || true
fi

echo "Getting Flutter packages..."
flutter pub get

echo "Installing iOS pods..."
cd ios && pod install && cd ..

echo "Done. Next: open ios/Runner.xcworkspace in Xcode, then:"
echo "  1. Product > Clean Build Folder"
echo "  2. Select your device and run (or use flutter run)"
echo ""
echo "On device: Settings > General > VPN & Device Management > trust your developer certificate."
echo ""
echo "If app crashes on device with 'mprotect failed: 13 (Permission denied)':"
echo "  1. FVM: use a fixed Flutter version (see .fvmrc). Install: fvm install && fvm use"
echo "  2. Then run with FVM: fvm flutter run  (or fvm flutter run --profile)"
echo "  See: https://github.com/flutter/flutter/issues/163984"
