#!/usr/bin/env bash

xcodebuild CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO -scheme rostrum-travis -project rostrum.xcodeproj -sdk iphonesimulator13.4 clean build

