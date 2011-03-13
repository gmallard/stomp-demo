#!/bin/sh
#
set -x
ruby volume/driver.rb -t 5 -u 5 -c 7 -d 7 -m 20 -n 20
set +x

