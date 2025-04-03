#!/bin/sh
SERVER_HOST=$1
SERVER_PORT=$2
RCON_PASS=$3
./mcrcon/mcrcon -H $SERVER_HOST -P $SERVER_PORT -p "$RCON_PASS" "stop"
