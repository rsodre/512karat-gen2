use starknet::{ContractAddress};
use dojo::world::IWorldDispatcher;

#[starknet::interface]
pub trait ICoinMock<TState> {
    // IWorldProvider
    fn world_dispatcher(self: @TState) -> IWorldDispatcher;

    // IERC20
    fn total_supply(self: @TState) -> u256;
    fn balance_of(self: @TState, account: ContractAddress) -> u256;
    fn allowance(self: @TState, owner: ContractAddress, spender: ContractAddress) -> u256;
    fn transfer(ref self: TState, recipient: ContractAddress, amount: u256) -> bool;
    fn transfer_from(ref self: TState, sender: ContractAddress, recipient: ContractAddress, amount: u256) -> bool;
    fn approve(ref self: TState, spender: ContractAddress, amount: u256) -> bool;
    // IERC20Metadata
    fn name(self: @TState) -> ByteArray;
    fn symbol(self: @TState) -> ByteArray;
    fn decimals(self: @TState) -> u8;
    // IERC20CamelOnly
    fn totalSupply(self: @TState) -> u256;
    fn balanceOf(self: @TState, account: ContractAddress) -> u256;
    fn transferFrom(ref self: TState, sender: ContractAddress, recipient: ContractAddress, amount: u256) -> bool;
    
    // ICoinMockPublic
    fn faucet(ref self: TState);
    fn mint(ref self: TState, recipient: ContractAddress, amount: u256);
}

// Exposed to clients
#[starknet::interface]
pub trait ICoinMockPublic<TState> {
    fn faucet(ref self: TState);
    fn mint(ref self: TState, recipient: ContractAddress, amount: u256);
}

#[dojo::contract]
pub mod mock_coin {
    use starknet::{ContractAddress};

    //-----------------------------------
    // ERC-20 Start
    //
    use openzeppelin_token::erc20::ERC20Component;
    use openzeppelin_token::erc20::ERC20HooksEmptyImpl;
    component!(path: ERC20Component, storage: erc20, event: ERC20Event);
    #[abi(embed_v0)]
    impl ERC20MixinImpl = ERC20Component::ERC20MixinImpl<ContractState>;
    impl ERC20InternalImpl = ERC20Component::InternalImpl<ContractState>;
    #[storage]
    struct Storage {
        #[substorage(v0)]
        erc20: ERC20Component::Storage,
    }
    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        ERC20Event: ERC20Component::Event,
    }
    //
    // ERC-20 End
    //-----------------------------------

    use karat_v2::utils::misc::{WEI};


    //*******************************************
    fn COIN_NAME() -> ByteArray {("mock COIN")}
    fn COIN_SYMBOL() -> ByteArray {("COIN")}
    //*******************************************

    fn dojo_init(ref self: ContractState,
        minter_contract_address: ContractAddress,
        faucet_amount: u128,
    ) {
        self.erc20.initializer(
            COIN_NAME(),
            COIN_SYMBOL(),
        );
    }

    //-----------------------------------
    // Public
    //
    #[abi(embed_v0)]
    impl CoinMockPublicImpl of super::ICoinMockPublic<ContractState> {
        fn faucet(ref self: ContractState) {
            self.mint(starknet::get_caller_address(), WEI(1_000).into());
        }
        fn mint(ref self: ContractState,
            recipient: ContractAddress,
            amount: u256,
        ) {
            self.erc20.mint(recipient, amount);
        }
    }

}
