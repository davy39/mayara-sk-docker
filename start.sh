#!/bin/sh
MAYARA_INTERFACE=${MAYARA_INTERFACE:-"lo"}
MAYARA_PORT=${MAYARA_PORT:-3002}
HOST=${HOST:-localhost}
sed -i "s/host: 'localhost',/host: '$HOST',/g" signalk-server/node_modules/@signalk/freeboard-sk/public/main.js
echo "Starting mayara listening on interface $MAYARA_INTERFACE..."
echo "Mayara will be available on port $MAYARA_PORT"
./mayara -i $MAYARA_INTERFACE -p $MAYARA_PORT&
signalk-server/bin/signalk-server -c signalk/
