#!/bin/bash
# Script de build pour Vercel : Flutter n est pas preinstalle, donc on
# le telecharge nous-memes avant de compiler la version web de l app.
set -e

git clone https://github.com/flutter/flutter.git -b stable --depth 1
export PATH="$PATH:$(pwd)/flutter/bin"

flutter doctor
flutter pub get
flutter build web --dart-define=API_BASE_URL=https://cnfpatel-backend.onrender.com/api
