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

//---------------------------------------
// Traits
//
use core::num::traits::Zero;
use karat_gen2::interfaces::ierc721::{IERC721Dispatcher, IERC721DispatcherTrait};
use karat_gen2::interfaces::ierc20::{IERC20Dispatcher};

#[generate_trait]
pub impl TokenConfigImpl of TokenConfigTrait {
    fn is_minter(self: TokenConfig, address: ContractAddress) -> bool {
        (self.minter_address == address)
    }
    fn is_eligible_for_presale(self: TokenConfig, account_address: ContractAddress) -> bool {
        let presale_dispatcher = IERC721Dispatcher{ contract_address: self.presale_token_address };
        (presale_dispatcher.balance_of(account_address).is_non_zero())
    }
    fn purchase_coin_dispatcher(self: TokenConfig) -> IERC20Dispatcher {
        (IERC20Dispatcher{ contract_address: self.purchase_coin_address })
    }
}
