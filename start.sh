#! /bin/bash -e
set -eux;

./var/dbb_home/wlp/bin/server start dbb &
wait n
tail -f /var/dbb_home/wlp/usr/servers/dbb/logs/dbb.log