#!/usr/bin/env bash

CURRENT_NODE_HEIGHT=$(/root/.dashcore/dashcore-node/daemon/dash-cli -datadir=/root/.dashcore/dashcore-node/data getblockchaininfo | jq -r .blocks)
if ! egrep -o "^[0-9]+$" <<< "$CURRENT_NODE_HEIGHT" &>/dev/null; then
  echo "Daemon not working correct..."
  exit 1
else
  curl -sf  http://localhost:3001/insight-api/sync
  exit
fi
