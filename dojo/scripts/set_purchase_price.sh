#!/bin/bash
set -euo pipefail
source scripts/setup.sh

# if [ $# -ge 2 ]; then
#   export TREASURY_ADDRESS=$2
# else
#   # export PROFILE="dev"
#   echo "usage: $0 <PROFILE> <TREASURY_ADDRESS>"
#   exit 1
# fi

if [[ "$PROFILE" == "sepolia" ]]; then
  export TREASURY_ADDRESS=0x070ea289f608f37e2ee38e8a5a5e1cd9203e7666db36714d20382b73302308e5
elif [[ "$PROFILE" == "mainnet" ]]; then
  export TREASURY_ADDRESS=0x0
else
  echo "! Missing TREASURY_ADDRESS 👎"
  exit 1
fi

# STRK address is the same in all networks
# https://docs.starknet.io/resources/chain-info/
export STRK_ADDRESS=0x04718f5a0fc34cc1af16a1cdee98ffb20c31f5cd61d6ab07201858f4287c938d

# move down to /dojo
pushd $(dirname "$0")/..

# sozo execute --world <WORLD_ADDRESS> <CONTRACT> <ENTRYPOINT>
sozo execute karat_gen2-minter --world $WORLD_ADDRESS --wait set_purchase_price $TOKEN_ADDRESS $STRK_ADDRESS 100
sozo -P $PROFILE model get karat_gen2-TokenConfig $TOKEN_ADDRESS
