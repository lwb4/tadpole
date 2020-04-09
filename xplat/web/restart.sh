#!/usr/bin/env bash
if [ $(lsof -t -i tcp:5000) ]; then
    echo 'kill running server'
    lsof -t -i tcp:5000 | xargs kill
fi

ps | grep "./build.sh" | grep -v grep | awk '{if($1!="") {print "killing last build process: "$1; system("kill " $1)}}'

echo 'starting server ...'
./build.sh &