use starknet::ContractAddress;

#[dojo::model]
#[derive(Copy, Drop, Serde)]
pub struct TokenConfig {
    #[key]
    pub token_address: ContractAddress,
    //------
    pub minter_address: ContractAddress,
    // purchases
    pub treasury_address: ContractAddress,
    pub purchase_coin_address: ContractAddress,
    pub purchase_price_wei: u128,
    // presale for karat owners
    pub presale_token_address: ContractAddress,
    pub presale_timestamp_end: u64,
}

#[generate_trait]
pub impl TokenConfigTraitImpl of TokenConfigTrait {
    fn is_minter(self: TokenConfig, address: ContractAddress) -> bool { (self.minter_address == address) }
}
