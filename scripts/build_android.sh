#!/usr/bin/env bash
set -euo pipefail

export JAVA_HOME="${JAVA_HOME:-/usr/lib/jvm/java-21-openjdk-amd64}"
export PATH="/home/usmanghias/flutter/bin:$PATH"

cd "$(dirname "$0")/.."

echo "Using Java: $JAVA_HOME"
"$JAVA_HOME/bin/java" -version

flutter pub get
flutter analyze --fatal-infos
flutter test
flutter build apk --debug

echo "APK: build/app/outputs/flutter-apk/app-debug.apk"
