#!/bin/sh
# 
# = Start a stompserver message processor.
#
set -x
#
# Set command line options.
#
sopts=""
#
# Start the server.
#
stompserver $sopts
set +x

