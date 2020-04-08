#!/usr/bin/env bash

xcodebuild CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO -scheme rostrum-travis -project tadpole.xcodeproj clean build
