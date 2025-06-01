use starknet::{ContractAddress};
use dojo::world::IWorldDispatcher;

#[starknet::interface]
pub trait IToken<TState> {
    // IWorldProvider
    fn world_dispatcher(self: @TState) -> IWorldDispatcher;

    //-----------------------------------
    // IERC721ComboABI start
    //
    // (ISRC5)
    fn supports_interface(self: @TState, interface_id: felt252) -> bool;
    // (IERC721)
    fn balance_of(self: @TState, account: ContractAddress) -> u256;
    fn owner_of(self: @TState, token_id: u256) -> ContractAddress;
    fn safe_transfer_from(ref self: TState, from: ContractAddress, to: ContractAddress, token_id: u256, data: Span<felt252>);
    fn transfer_from(ref self: TState, from: ContractAddress, to: ContractAddress, token_id: u256);
    fn approve(ref self: TState, to: ContractAddress, token_id: u256);
    fn set_approval_for_all(ref self: TState, operator: ContractAddress, approved: bool);
    fn get_approved(self: @TState, token_id: u256) -> ContractAddress;
    fn is_approved_for_all(self: @TState, owner: ContractAddress, operator: ContractAddress) -> bool;
    // (IERC721Metadata)
    fn name(self: @TState) -> ByteArray;
    fn symbol(self: @TState) -> ByteArray;
    fn token_uri(self: @TState, token_id: u256) -> ByteArray;
    fn tokenURI(self: @TState, tokenId: u256) -> ByteArray;
    //-----------------------------------
    // IERC721Minter
    fn max_supply(self: @TState) -> u256;
    fn total_supply(self: @TState) -> u256;
    fn last_token_id(self: @TState) -> u256;
    fn is_minting_paused(self: @TState) -> bool;
    fn is_owner_of(self: @TState, address: ContractAddress, token_id: u256) -> bool;
    fn token_exists(self: @TState, token_id: u256) -> bool;
    fn totalSupply(self: @TState) -> u256;
    //-----------------------------------
    // IERC7572ContractMetadata
    fn contract_uri(self: @TState) -> ByteArray;
    fn contractURI(self: @TState) -> ByteArray;
    //-----------------------------------
    // IERC4906MetadataUpdate
    //-----------------------------------
    // IERC2981RoyaltyInfo
    fn royalty_info(self: @TState, token_id: u256, sale_price: u256) -> (ContractAddress, u256);
    fn default_royalty(self: @TState) -> (ContractAddress, u128, u128);
    fn token_royalty(self: @TState, token_id: u256) -> (ContractAddress, u128, u128);
    // IERC721ComboABI end
    //-----------------------------------

    // karat_v2
    fn mint_next(ref self: TState, recipient: ContractAddress) -> u128;
    fn burn(ref self: TState, token_id: u256);
    fn set_paused(ref self: TState, is_paused: bool);
}

#[starknet::interface]
pub trait ITokenPublic<TState> {
    fn mint_next(ref self: TState, recipient: ContractAddress) -> u128;
    fn burn(ref self: TState, token_id: u256);
    // admin
    fn set_paused(ref self: TState, is_paused: bool);
}

#[dojo::contract]
pub mod token {
    use starknet::ContractAddress;
    use dojo::world::{WorldStorage, IWorldDispatcherTrait};

    //-----------------------------------
    // ERC721 start
    //
    use openzeppelin_introspection::src5::SRC5Component;
    use openzeppelin_token::erc721::ERC721Component;
    use nft_combo::erc721::erc721_combo::ERC721ComboComponent;
    use nft_combo::erc721::erc721_combo::ERC721ComboComponent::{ERC721HooksImpl};
    component!(path: SRC5Component, storage: src5, event: SRC5Event);
    component!(path: ERC721Component, storage: erc721, event: ERC721Event);
    component!(path: ERC721ComboComponent, storage: erc721_combo, event: ERC721ComboEvent);
    impl ERC721InternalImpl = ERC721Component::InternalImpl<ContractState>;
    impl ERC721ComboInternalImpl = ERC721ComboComponent::InternalImpl<ContractState>;
    #[abi(embed_v0)]
    impl ERC721ComboMixinImpl = ERC721ComboComponent::ERC721ComboMixinImpl<ContractState>;
    #[storage]
    struct Storage {
        #[substorage(v0)]
        src5: SRC5Component::Storage,
        #[substorage(v0)]
        erc721: ERC721Component::Storage,
        #[substorage(v0)]
        erc721_combo: ERC721ComboComponent::Storage,
    }
    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        SRC5Event: SRC5Component::Event,
        #[flat]
        ERC721Event: ERC721Component::Event,
        #[flat]
        ERC721ComboEvent: ERC721ComboComponent::Event,
    }
    //
    // ERC721 end
    //-----------------------------------

    use karat_v2::models::token_config::{TokenConfig, TokenConfigTrait};
    use karat_v2::libs::store::{Store, StoreTrait};
    use karat_v2::libs::dns::{SELECTORS};
    use karat_v2::models::seed::{Seed, SeedTrait};

    mod Errors {
        pub const CALLER_IS_NOT_OWNER: felt252      = 'KARAT-V2: caller is not owner';
        pub const CALLER_IS_NOT_MINTER: felt252     = 'KARAT-V2: caller is not minter';
    }

    //*******************************
    fn TOKEN_NAME()   -> ByteArray {("Karat II")}
    fn TOKEN_SYMBOL() -> ByteArray {("KARAT-G2")}
    //*******************************

    fn dojo_init(ref self: ContractState,
        treasury_address: ContractAddress,
    ) {
        self.erc721_combo.initializer(
            TOKEN_NAME(),
            TOKEN_SYMBOL(),
            Option::None, // use hooks
            Option::None, // use hooks
            Option::Some(512),
        );
        self.erc721_combo._set_default_royalty(treasury_address, 500);
        self.erc721_combo._set_minting_paused(true);
    }

    #[generate_trait]
    impl WorldDefaultImpl of WorldDefaultTrait {
        #[inline(always)]
        fn world_default(self: @ContractState) -> WorldStorage {
            (self.world(@"karat_v2"))
        }
    }


    //-----------------------------------
    // ITokenPublic
    //
    #[abi(embed_v0)]
    impl ITokenPublicImpl of super::ITokenPublic<ContractState> {
        fn mint_next(ref self: ContractState, recipient: ContractAddress) -> u128 {
            let mut store: Store = StoreTrait::new(self.world_default());
            self._assert_caller_is_minter(@store);

            // mint
            let token_id: u128 = self.erc721_combo._mint_next(recipient).low;

            // generate seed
            let token_contract_address: ContractAddress = starknet::get_contract_address();
            let seed: Seed = SeedTrait::new(token_contract_address, token_id);
            store.set_seed(@seed);

            // event...
            store.emit_token_minted_event(token_contract_address, token_id, recipient, seed.seed);

            (token_id)
        }
        fn burn(ref self: ContractState, token_id: u256) {
            // self.erc721_burnable.burn(token_id);
        }
        fn set_paused(ref self: ContractState, is_paused: bool) {
            let mut store: Store = StoreTrait::new(self.world_default());
            self._assert_caller_is_minter(@store);
            self.erc721_combo._set_minting_paused(is_paused);
        }
    }


    //-----------------------------------
    // Internal
    //
    #[generate_trait]
    impl InternalImpl of InternalTrait {
        #[inline(always)]
        fn _assert_caller_is_owner(self: @ContractState) {
            assert(self._caller_is_owner(), Errors::CALLER_IS_NOT_OWNER);
        }
        #[inline(always)]
        fn _caller_is_owner(self: @ContractState) -> bool {
            (self.world_default().dispatcher.is_owner(SELECTORS::TOKEN, starknet::get_caller_address()))
        }
        #[inline(always)]
        fn _assert_caller_is_minter(self: @ContractState, store: @Store) {
            let token_contract_address: ContractAddress = starknet::get_contract_address();
            let config: TokenConfig = store.get_token_config(token_contract_address);
            assert(config.is_minter(starknet::get_caller_address()), Errors::CALLER_IS_NOT_MINTER);
        }
    }

    //-----------------------------------
    // ERC721ComboHooksTrait
    //
    pub impl ERC721ComboHooksImpl of ERC721ComboComponent::ERC721ComboHooksTrait<ContractState> {
    }
}
