#!/bin/sh
MAYARA_INTERFACE=${MAYARA_INTERFACE:-"lo"}
MAYARA_PORT=${MAYARA_PORT:-3002}
echo "Starting mayara listening on interface $MAYARA_INTERFACE..."
echo "Mayara will be available on port $MAYARA_PORT"
./mayara -i $MAYARA_INTERFACE -p $MAYARA_PORT&
signalk-server/bin/signalk-server -c signalk/
