#!/bin/sh
set -e

CONFIG_DIR="/etc/git2consul.d"

# If /etc/git2consul.d/ is not empty, run config_seeder.js
if [ -d $CONFIG_DIR ] && [ "$(ls -A $CONFIG_DIR)" ]; then
  # Parse out endpoint and port
  /usr/bin/node /usr/lib/node_modules/git2consul/utils/config_seeder.js $@ $(find $CONFIG_DIR -type f -name *.json | sort | head -n 1)
fi

/usr/bin/node /usr/lib/node_modules/git2consul "$@"
