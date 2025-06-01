use starknet::{ContractAddress};
use dojo::world::{WorldStorage};
use dojo::model::{ModelStorage};
use dojo::event::{EventStorage};

pub use karat_v2::models::{
    token_config::{TokenConfig},
    seed::{Seed},
    events::{TokenMintedEvent},
};


#[derive(Copy, Drop)]
pub struct Store {
    pub world: WorldStorage,
}

#[generate_trait]
pub impl StoreImpl of StoreTrait {
    #[inline(always)]
    fn new(world: WorldStorage) -> Store {
        (Store { world })
    }

    //----------------------------------
    // Model Getters
    //

    #[inline(always)]
    fn get_token_config(self: @Store, token_contract_address: ContractAddress) -> TokenConfig {
        (self.world.read_model(token_contract_address))
    }
    #[inline(always)]
    fn get_seed(self: @Store, token_contract_address: ContractAddress, token_id: u128) -> Seed {
        (self.world.read_model((token_contract_address, token_id),))
    }

    //----------------------------------
    // Model Setters
    //

    #[inline(always)]
    fn set_token_config(ref self: Store, model: @TokenConfig) {
        self.world.write_model(model);
    }
    #[inline(always)]
    fn set_seed(ref self: Store, model: @Seed) {
        self.world.write_model(model);
    }


    //----------------------------------
    // Emitters
    //

    #[inline(always)]
    fn emit_token_minted_event(ref self: Store, token_contract_address: ContractAddress, token_id: u128, recipient: ContractAddress, seed: felt252) {
        self.world.emit_event(@TokenMintedEvent{
            token_contract_address,
            token_id,
            recipient,
            seed,
        });
    }
}
