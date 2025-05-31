# 512 KARAT Vol 2

## Generative Art made with Dojo

code + art: **Roger S.** aka **Mataleone** ([@matalecode](https://x.com/matalecode))


## Mainnet Minting

* TBA


## Project structure

* `/dojo`: Dojo contracts (deprecated with Origami)
* `/dojo/scripts`: Scripts to interact with the contracts
* `/draft`: Token experiments (metadata, svg)
* `/scripts`: Scripts for fetching Karat data on-chain
* `/tokens`: Cached KARAT metadata and art
* [p5js](https://editor.p5js.org/rsodre/sketches/LbtLW29da): Art development playground


## Sepolia / Mainnet Deployment

This is a **generic guide** to deploy a Dojo world to Sepolia.
The steps for Mainnet are exactly the same, just replace the chain name and ID when necessary.


### Setup

* You need a [Starknet RPC Provider](https://www.starknet.io/fullnodes-rpc-services/) to deploy contracts on-chain. After you get yours, check if it works and is on the chain you want to deploy (`SN_SEPOLIA` or `SN_MAIN`)

```sh
# get dojoup
curl -L https://install.dojoengine.org | bash
# install the correct dojo version
dojoup install v1.5.0
```

After deployment, we can use some sozo commands to manage the contracts.

```sh
# mint one token to the deployer account
scripts/mint_to.sh mainnet
# mint to a specific wallet
scripts/mint_to.sh mainnet 0x04042b3F651F6d6Ff03b929437AdC30257333723970071b05cb0E2270C9dc385
# change the currently amount of available to mint
scripts/set_available.sh mainnet 128
```


## Resources and Process

This project sarted from scratch for [StarkHack 2024](https://ethglobal.com/events/starkhack), using a few open source boilerplates, mainly from [Dojo](https://www.dojoengine.org/), [Origami](https://book.dojoengine.org/toolchain/origami) and [Pistols at 10 Blocks](https://pistols.underware.gg/).

The original submission, containing the full process of how it was built in June 2024 is on the [stark_hack](https://github.com/rsodre/512karat/tree/stark_hack) tag (**outdated!**).
