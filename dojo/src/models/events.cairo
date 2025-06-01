use starknet::{ContractAddress};

#[derive(Copy, Drop, Serde)]
#[dojo::event(historical:false)]
pub struct TokenMintedEvent {
    #[key]
    pub token_contract_address: ContractAddress,
    #[key]
    pub token_id: u128,
    //-----------------------
    pub recipient: ContractAddress,
    pub seed: felt252,
}
