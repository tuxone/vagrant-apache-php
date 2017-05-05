#!/bin/bash

curl "http://127.0.0.1:8080/" -s | grep "Sono le \d\d:\d\d" > /dev/null

if [ $? -eq 0 ]; then
    echo ok
    exit 0
else
    echo ERR
    exit 1
fi
