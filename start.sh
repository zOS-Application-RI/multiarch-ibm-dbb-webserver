#! /bin/bash -e
set -eux;
pid=$!
./var/dbb_home/wlp/bin/server start dbb &

wait $pid
tail -f /var/dbb_home/wlp/usr/servers/dbb/logs/dbb.log