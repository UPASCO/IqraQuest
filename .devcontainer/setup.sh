#!/usr/bin/env bash
# One-shot Codespace setup: installs the Flutter SDK pinned to the version
# this app is developed against, then prepares the project so
# `flutter run -d web-server` works immediately.
set -euo pipefail

FLUTTER_VERSION="3.47.2"

sudo apt-get update -qq
sudo apt-get install -y -qq curl git unzip xz-utils zip libglu1-mesa

if [ ! -d /opt/flutter ]; then
  sudo git clone --depth 1 --branch "$FLUTTER_VERSION" \
    https://github.com/flutter/flutter.git /opt/flutter
  sudo chown -R "$(id -u):$(id -g)" /opt/flutter
fi

export PATH="$PATH:/opt/flutter/bin"

flutter config --no-analytics
flutter precache --web
flutter pub get
flutter gen-l10n

echo
echo "IqraQuest est prêt. Pour tester dans le navigateur :"
echo "  flutter run -d web-server --web-port 3000 --web-hostname 0.0.0.0"
