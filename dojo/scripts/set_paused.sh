#!/bin/bash
set -euo pipefail
source scripts/setup.sh

if [ $# -ge 2 ]; then
  export PAUSED=$2
else
  # export PROFILE="dev"
  echo "usage: $0 <PROFILE> <PAUSED>"
  exit 1
fi

# move down to /dojo
pushd $(dirname "$0")/..

# sozo execute --world <WORLD_ADDRESS> <CONTRACT> <ENTRYPOINT>
echo "> new paused: $PAUSED"
sozo execute karat_gen2-minter --world $WORLD_ADDRESS --wait set_paused $TOKEN_ADDRESS $PAUSED
sozo -P $PROFILE model get karat_gen2-TokenConfig $TOKEN_ADDRESS
