use starknet::{ContractAddress};

#[starknet::interface]
pub trait IMinter<TState> {
    fn get_price(self: @TState, token_contract_address: ContractAddress) -> (ContractAddress, u128);
    fn can_mint(self: @TState, token_contract_address: ContractAddress, recipient: ContractAddress) -> Option<ByteArray>;
    fn get_presale_countdown(self: @TState, token_contract_address: ContractAddress) -> Option<u64>;
    fn mint(ref self: TState, token_contract_address: ContractAddress) -> u128;
    fn mint_to(ref self: TState, token_contract_address: ContractAddress, recipient: ContractAddress) -> u128;

    // admin
    fn set_paused(ref self: TState, token_contract_address: ContractAddress, is_paused: bool);
    fn set_purchase_price(ref self: TState, token_contract_address: ContractAddress, purchase_coin_address: ContractAddress, purchase_price_eth: u8);
    // fn set_presale_token(ref self: TState, token_contract_address: ContractAddress, presale_token_address: ContractAddress);
}

#[dojo::contract]
pub mod minter {
    use core::num::traits::Zero;
    use starknet::{ContractAddress};
    use dojo::world::{WorldStorage, IWorldDispatcherTrait};

    use karat_gen2::systems::token::{ITokenDispatcher, ITokenDispatcherTrait};
    // use karat_gen2::systems::renderer::{renderer};
    use karat_gen2::interfaces::ierc20::{IERC20Dispatcher, IERC20DispatcherTrait};
    use karat_gen2::libs::store::{Store, StoreTrait};
    use karat_gen2::libs::dns::{DnsTrait, SELECTORS};
    use karat_gen2::utils::misc::{CONST, WEI};
    use karat_gen2::models::{
        token_config::{TokenConfig, TokenConfigTrait},
        gen2::{constants},
    };
    use karat_gen2::utils::math::{SafeMathU64};
    
    mod Errors {
        pub const CALLER_IS_NOT_OWNER: felt252      = 'MINTER: caller is not owner';
        pub const INVALID_TREASURY_ADDRESS: felt252 = 'MINTER: invalid treasury';
        pub const INVALID_COIN_ADDRESS: felt252     = 'MINTER: invalid coin address';
        pub const INVALID_TOKEN_ADDRESS: felt252    = 'MINTER: invalid token address';
        pub const UNAVAILABLE: felt252              = 'MINTER: unavailable';
        pub const PAUSED: felt252                   = 'MINTER: minting is paused';
        pub const PRESALE_TO_OTHER: felt252         = 'MINTER: presale to other';
        pub const PRESALE_ALREADY_MINTED: felt252   = 'MINTER: already minted presale';
        pub const PRESALE_INELIGIBLE: felt252       = 'MINTER: ineligible to presale';
        pub const INVALID_RECEIVER: felt252         = 'MINTER: invalid receiver';
        pub const INSUFFICIENT_ALLOWANCE: felt252   = 'MINTER: insufficient allowance';
        pub const INSUFFICIENT_BALANCE: felt252     = 'MINTER: insufficient balance';
    }

    //---------------------------------------
    // params passed from overlays files
    // https://github.com/dojoengine/dojo/blob/328004d65bbbf7692c26f030b75fa95b7947841d/examples/spawn-and-move/manifests/dev/overlays/contracts/dojo_examples_others_others.toml
    // https://github.com/dojoengine/dojo/blob/328004d65bbbf7692c26f030b75fa95b7947841d/examples/spawn-and-move/src/others.cairo#L18
    // overlays generated with: sozo migrate --generate-overlays
    //
    fn dojo_init(ref self: ContractState,
        treasury_address: ContractAddress,
        purchase_coin_address: ContractAddress, // STRK
        presale_token_address: ContractAddress, // KARAT
    ) {
        let mut store: Store = StoreTrait::new(self.world_default());
        assert(treasury_address.is_non_zero(), Errors::INVALID_TREASURY_ADDRESS);
        assert(purchase_coin_address.is_non_zero(), Errors::INVALID_COIN_ADDRESS);
        assert(presale_token_address.is_non_zero(), Errors::INVALID_TOKEN_ADDRESS);
        store.set_token_config(@TokenConfig{
            token_address: store.world.token_address(),
            minter_address: starknet::get_contract_address(),
            treasury_address,
            purchase_coin_address,
            purchase_price_wei: WEI(constants::DEFAULT_STRK_PRICE_ETH.into()),
            presale_token_address,
            presale_timestamp_end: 0,
        });
    }

    #[generate_trait]
    impl WorldDefaultImpl of WorldDefaultTrait {
        #[inline(always)]
        fn world_default(self: @ContractState) -> WorldStorage {
            (self.world(@"karat_gen2"))
        }
    }

    //---------------------------------------
    // IMinter
    //
    #[abi(embed_v0)]
    impl MinterImpl of super::IMinter<ContractState> {
        fn get_price(self: @ContractState, token_contract_address: ContractAddress) -> (ContractAddress, u128) {
            let mut store: Store = StoreTrait::new(self.world_default());
            let token_config: TokenConfig = store.get_token_config(token_contract_address);
            (token_config.purchase_coin_address, token_config.purchase_price_wei)
        }

        fn can_mint(self: @ContractState, token_contract_address: ContractAddress, recipient: ContractAddress) -> Option<ByteArray> {
            let mut store: Store = StoreTrait::new(self.world_default());
            let token_config: TokenConfig = store.get_token_config(token_contract_address);
            let token_dispatcher = ITokenDispatcher{contract_address:token_contract_address};
            let is_presale: bool = (starknet::get_block_timestamp() <= token_config.presale_timestamp_end);
            if (token_config.presale_timestamp_end == 0) {
                (Option::Some("Unavailable"))
            } else if (token_dispatcher.is_minted_out()) {
                (Option::Some("Minted out"))
            } else if (token_dispatcher.is_minting_paused()) {
                (Option::Some("Paused"))
            } else if (is_presale && !token_config.is_eligible_for_presale(recipient)) {
                (Option::Some("Ineligible"))
            } else if (is_presale && token_dispatcher.balance_of(recipient).is_non_zero()) {
                (Option::Some("Already minted"))
            } else if (token_config.purchase_coin_dispatcher().balance_of(recipient) < token_config.purchase_price_wei.into()) {
                (Option::Some("Insufficient balance"))
            } else {
                // can mint!
                (Option::None)
            }
        }

        fn get_presale_countdown(self: @ContractState, token_contract_address: ContractAddress) -> Option<u64> {
            let mut store: Store = StoreTrait::new(self.world_default());
            let token_config: TokenConfig = store.get_token_config(token_contract_address);
            if (token_config.presale_timestamp_end == 0) {
                (Option::None)
            } else {
                (Option::Some(SafeMathU64::sub(token_config.presale_timestamp_end, starknet::get_block_timestamp())))
            }
        }

        fn mint(ref self: ContractState, token_contract_address: ContractAddress) -> u128 {
            (self.mint_to(token_contract_address, starknet::get_caller_address()))
        }

        fn mint_to(ref self: ContractState, token_contract_address: ContractAddress, recipient: ContractAddress) -> u128 {
            // check availability
            let store: Store = StoreTrait::new(self.world_default());
            let token_config: TokenConfig = store.get_token_config(token_contract_address);
            let token_dispatcher = ITokenDispatcher{contract_address:token_contract_address};
            
            // check current minting rules...
            // (contract owner is always allowed to mint)
            if (!self._caller_is_owner()) {
                let caller: ContractAddress = starknet::get_caller_address();

                // not released yet
                assert(token_config.presale_timestamp_end != 0, Errors::UNAVAILABLE);
                assert(!token_dispatcher.is_minting_paused(), Errors::PAUSED);

                // in presale
                if (starknet::get_block_timestamp() <= token_config.presale_timestamp_end) {
                    assert(caller == recipient, Errors::PRESALE_TO_OTHER);
                    // minted 1 per wallet
                    assert(token_dispatcher.balance_of(caller).is_zero(), Errors::PRESALE_ALREADY_MINTED);
                    // must own presale_token
                    assert(token_config.is_eligible_for_presale(caller), Errors::PRESALE_INELIGIBLE);
                }

                // charge!
                if (token_config.purchase_price_wei != 0) {
                    // must have balance
                    let coin_dispatcher: IERC20Dispatcher = token_config.purchase_coin_dispatcher();
                    let balance: u256 = coin_dispatcher.balance_of(caller);
                    let amount: u256 = token_config.purchase_price_wei.into();
                    assert(balance >= amount, Errors::INSUFFICIENT_BALANCE);
                    // must have allowance
                    let allowance: u256 = coin_dispatcher.allowance(caller, starknet::get_contract_address());
                    assert(allowance >= amount, Errors::INSUFFICIENT_ALLOWANCE);
                    // transfer...
                    assert(token_config.treasury_address.is_non_zero(), Errors::INVALID_RECEIVER);
                    coin_dispatcher.transfer_from(caller, token_config.treasury_address, amount);
                }
            }

            // mint!
            let token_id: u128 = token_dispatcher.mint_next(recipient);
            (token_id)
        }


        //---------------------------------------
        // admin
        //
        fn set_paused(ref self: ContractState, token_contract_address: ContractAddress, is_paused: bool) {
            self._assert_caller_is_owner();
            let mut store: Store = StoreTrait::new(self.world_default());
            let mut token_config: TokenConfig = store.get_token_config(token_contract_address);
            // start presale!
            if (!is_paused && token_config.presale_timestamp_end == 0) {
                token_config.presale_timestamp_end = starknet::get_block_timestamp() + CONST::ONE_DAY;
                store.set_token_config(@token_config);
            }
            // set paused
            let token_dispatcher = ITokenDispatcher{contract_address:token_contract_address};
            token_dispatcher.set_paused(is_paused);
        }

        fn set_purchase_price(ref self: ContractState,
            token_contract_address: ContractAddress,
            purchase_coin_address: ContractAddress,
            purchase_price_eth: u8,
        ) {
            self._assert_caller_is_owner();
            let mut store: Store = StoreTrait::new(self.world_default());
            let mut token_config: TokenConfig = store.get_token_config(token_contract_address);
            assert(token_config.minter_address == starknet::get_contract_address(), Errors::INVALID_TOKEN_ADDRESS);
            token_config.purchase_coin_address = purchase_coin_address;
            token_config.purchase_price_wei = WEI(purchase_price_eth.into());
            store.set_token_config(@token_config);
        }

        // fn set_presale_token(ref self: ContractState,
        //     token_contract_address: ContractAddress,
        //     presale_token_address: ContractAddress,
        // ) {
        //     self._assert_caller_is_owner();
        //     let mut store: Store = StoreTrait::new(self.world_default());
        //     let mut token_config: TokenConfig = store.get_token_config(token_contract_address);
        //     assert(token_config.minter_address == starknet::get_contract_address(), Errors::INVALID_TOKEN_ADDRESS);
        //     token_config.presale_token_address = presale_token_address;
        //     store.set_token_config(@token_config);
        // }
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
            let mut world = self.world_default();
            (world.dispatcher.is_owner(SELECTORS::MINTER, starknet::get_caller_address()))
        }
    }

}
