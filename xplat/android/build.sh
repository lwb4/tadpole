#!/usr/bin/env bash
./gradlew installDebug
adb install app/build/outputs/apk/debug/app-debug.apk
