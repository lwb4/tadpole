#!/usr/bin/env bash
./restart.sh
fswatch -t0 ../../assets/ | xargs -0 -n 1 ./restart.sh