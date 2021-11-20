#! /bin/bash -e
set -eux;

./var/dbb_home/wlp/bin/server start dbb &
pid=$!
wait $pid
tail -f /var/dbb_home/wlp/usr/servers/dbb/logs/dbb.log &
pid=$!
wait $pid