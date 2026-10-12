#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."

if ! command -v flutter >/dev/null 2>&1; then
  echo "Flutter is missing. Install Flutter 3.35.7 and add its bin directory to PATH." >&2
  exit 1
fi

flutter pub get
flutter analyze --no-fatal-infos
flutter test
flutter build apk --release

mkdir -p dist
cp build/app/outputs/flutter-apk/app-release.apk dist/TuneTube.apk
echo "APK: $(pwd)/dist/TuneTube.apk (release mode, debug signing key)"
