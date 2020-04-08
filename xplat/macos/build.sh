#!/usr/bin/env bash

xcodebuild CODE_SIGNING_REQUIRED=NO -scheme rostrum-travis build -project tadpole.xcodeproj
