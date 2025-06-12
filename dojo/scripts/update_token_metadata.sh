#!/bin/bash
set -euo pipefail
source scripts/setup.sh

if [ $# -ge 2 ]; then
  export TOKEN_ID=$2
else
  # export PROFILE="dev"
  echo "usage: $0 <PROFILE> <TOKEN_ID>"
  exit 1
fi

# move down to /dojo
pushd $(dirname "$0")/..

# sozo execute --world <WORLD_ADDRESS> <CONTRACT> <ENTRYPOINT>
echo "> update_token_metadata($TOKEN_ID)..."
sozo execute karat_gen2-token --world $WORLD_ADDRESS --wait update_token_metadata u256:$TOKEN_ID
