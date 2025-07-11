#!/bin/bash
IP=$1
PORT=${2:-80}

for i in {1..10}; do
    if curl -s --head "http://$IP:$PORT" | grep "200 OK" > /dev/null; then
        echo "App is up and running on $IP:$PORT"
        exit 0
    else
        echo "Waiting for app on $IP:$PORT..."
        sleep 10
    fi
done

echo "App did not become healthy on $IP:$PORT in time."
exit 1
