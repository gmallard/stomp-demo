#!/bin/sh
#
set -x
# YMMV on 'typical'
ruby ./driver.rb --min_tests=5 --max_tests=8 \
  --min_concli=1 --max_concli=3 \
  --min_msgs=10 --max_msgs=10
set +x

