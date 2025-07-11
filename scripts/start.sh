#!/bin/bash
PORT=80
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --port) PORT="$2"; shift ;;
    esac
    shift
done

cd /app || exit 1
nohup python3 -m http.server "$PORT" &
