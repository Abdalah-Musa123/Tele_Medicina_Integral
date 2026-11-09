#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
node api/validar_db.js
flutter pub get
flutter analyze
flutter test
