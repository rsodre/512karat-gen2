#!/bin/bash
set -euo pipefail
source scripts/setup.sh

if [ $# -ge 2 ]; then
  export RESERVED_SUPPLY=$2
else
  # export PROFILE="dev"
  echo "usage: $0 <PROFILE> <RESERVED_SUPPLY>"
  exit 1
fi

# move down to /dojo
pushd $(dirname "$0")/..

# sozo execute --world <WORLD_ADDRESS> <CONTRACT> <ENTRYPOINT>
echo "> new reserved_supply: $RESERVED_SUPPLY"
sozo execute karat_gen2-token --world $WORLD_ADDRESS --wait set_reserved_supply u256:$RESERVED_SUPPLY
