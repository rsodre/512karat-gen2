#[cfg(test)]
pub mod tester {
    use core::num::traits::Zero;
    use starknet::{ContractAddress, testing};

    use dojo::world::{WorldStorage, IWorldDispatcherTrait};
    // use dojo::model::{ModelStorageTest};
    use dojo_cairo_test::{
        spawn_test_world,
        NamespaceDef, TestResource,
        ContractDefTrait, ContractDef,
        WorldStorageTestTrait,
    };

    pub use karat_v2::systems::{
        token::{ITokenDispatcher, ITokenDispatcherTrait},
        minter::{IMinterDispatcher, IMinterDispatcherTrait},
    };
    pub use karat_v2::libs::store::{Store, StoreTrait};
    pub use karat_v2::libs::dns::{DnsTrait};
    pub use karat_v2::tests::{
        mock_coin::{ICoinMockDispatcher, ICoinMockDispatcherTrait},
        mock_token::{IMockTokenDispatcher, IMockTokenDispatcherTrait},
    };

    
    //
    // starknet testing cheats
    // https://github.com/starkware-libs/cairo/blob/main/corelib/src/starknet/testing.cairo
    //

    pub fn ZERO()      -> ContractAddress { starknet::contract_address_const::<0x0>() }
    pub fn OWNER()     -> ContractAddress { starknet::contract_address_const::<0x1>() } // mock owner of duelists 1-2
    pub fn OTHER()     -> ContractAddress { starknet::contract_address_const::<0x3>() } // mock owner of duelists 3-4
    pub fn BUMMER()    -> ContractAddress { starknet::contract_address_const::<0x5>() } // mock owner of duelists 5-6
    pub fn RECIPIENT() -> ContractAddress { starknet::contract_address_const::<0x222>() }
    pub fn SPENDER()   -> ContractAddress { starknet::contract_address_const::<0x333>() }
    pub fn TREASURY()  -> ContractAddress { starknet::contract_address_const::<0x444>() }
    pub fn XYZ()       -> ContractAddress { starknet::contract_address_const::<0x1231278612>() }


    // set_contract_address : to define the address of the calling contract,
    // set_account_contract_address : to define the address of the account used for the current transaction.
    pub fn impersonate(address: ContractAddress) {
        testing::set_contract_address(address);             // starknet::get_execution_info().contract_address
        testing::set_account_contract_address(address);     // starknet::get_execution_info().tx_info.account_contract_address
    }
    pub fn get_impersonator() -> ContractAddress {
        (starknet::get_execution_info().tx_info.account_contract_address)
    }


    //-------------------------------
    // Test world

    pub const INITIAL_TIMESTAMP: u64 = 0x100000000;
    pub const TIMESTEP: u64 = 0x1;

    pub mod FLAGS {
        pub const NONE: u8      = 0;
        pub const UNPAUSE: u8   = 0b1;
    }

    #[derive(Copy, Drop)]
    pub struct TestSystems {
        pub world: WorldStorage,
        pub token: ITokenDispatcher,
        pub minter: IMinterDispatcher,
        pub coin: ICoinMockDispatcher,
        pub store: Store,
    }

    pub fn setup_world(flags: u8) -> TestSystems {
        let unpause = (flags & FLAGS::UNPAUSE) != 0;
        
        let mut resources: Array<TestResource> = array![
            // contracts
            TestResource::Contract(karat_v2::systems::token::token::TEST_CLASS_HASH),
            TestResource::Contract(karat_v2::systems::minter::minter::TEST_CLASS_HASH),
            TestResource::Contract(karat_v2::tests::mock_coin::mock_coin::TEST_CLASS_HASH),
            TestResource::Contract(karat_v2::tests::mock_token::mock_token::TEST_CLASS_HASH),
            // models
            TestResource::Model(karat_v2::models::token_config::m_TokenConfig::TEST_CLASS_HASH),
            TestResource::Model(karat_v2::models::seed::m_Seed::TEST_CLASS_HASH),
            // events
            TestResource::Event(karat_v2::models::events::e_TokenMintedEvent::TEST_CLASS_HASH),
        ];

        let namespace_def = NamespaceDef {
            namespace: "karat_v2",
            resources: resources.span(),
        };

        let mut world: WorldStorage = spawn_test_world([namespace_def].span());

        let sys = TestSystems {
            world,
            token: world.token_dispatcher(),
            minter: world.minter_dispatcher(),
            coin: ICoinMockDispatcher{ contract_address: world.find_contract_address(@"mock_coin") },
            store: StoreTrait::new(world),
        };

        let strk_address = sys.coin.contract_address.into();
        let presale_token_address = world.find_contract_address(@"mock_token");

        let mut contract_defs: Array<ContractDef> = array![
            ContractDefTrait::new(@"karat_v2", @"token")
                .with_writer_of([dojo::utils::bytearray_hash(@"karat_v2")].span())
                .with_init_calldata([
                    TREASURY().into(),
                ].span()),
            ContractDefTrait::new(@"karat_v2", @"minter")
                .with_writer_of([dojo::utils::bytearray_hash(@"karat_v2")].span())
                .with_init_calldata([
                    TREASURY().into(),
                    (if strk_address.is_non_zero() {strk_address} else {XYZ()}).into(),
                    (if presale_token_address.is_non_zero() {presale_token_address} else {XYZ()}).into(),
                ].span()),
        ];

        // setup block
        testing::set_block_number(1);
        testing::set_block_timestamp(INITIAL_TIMESTAMP);

        world.sync_perms_and_inits(contract_defs.span());
        world.dispatcher.grant_owner(dojo::utils::bytearray_hash(@"karat_v2"), OWNER());
        world.dispatcher.grant_owner(selector_from_tag!("karat_v2-minter"), OWNER());

        impersonate(OWNER());

        if (unpause) {
            sys.minter.set_paused(sys.token.contract_address, false);
        }

// println!("READY!");
        (sys)
    }

    #[inline(always)]
    pub fn get_block_number() -> u64 {
        let block_info = starknet::get_block_info().unbox();
        (block_info.block_number)
    }

    #[inline(always)]
    pub fn get_block_timestamp() -> u64 {
        let block_info = starknet::get_block_info().unbox();
        (block_info.block_timestamp)
    }

    #[inline(always)]
    pub fn _next_block() -> (u64, u64) {
        (elapse_block_timestamp(TIMESTEP))
    }

    pub fn elapse_block_timestamp(delta: u64) -> (u64, u64) {
        let new_timestamp = starknet::get_block_timestamp() + delta;
        (set_block_timestamp(new_timestamp))
    }

    pub fn set_block_timestamp(new_timestamp: u64) -> (u64, u64) {
        assert_ge!(new_timestamp, starknet::get_block_timestamp(), "set_block_timestamp() <<< Back in time...");
        let new_block_number = get_block_number() + 1;
        testing::set_block_number(new_block_number);
        testing::set_block_timestamp(new_timestamp);
        (new_block_number, new_timestamp)
    }

    // event helpers
    // examples...
    // https://docs.swmansion.com/scarb/corelib/core-starknet-testing-pop_log.html
    pub fn pop_log<T, +Drop<T>, +starknet::Event<T>>(address: ContractAddress, event_selector: felt252) -> Option<T> {
        let (mut keys, mut data) = testing::pop_log_raw(address)?;
        let id = keys.pop_front().unwrap(); // Remove the event ID from the keys
        assert_eq!(id, @event_selector, "Wrong event!");
        let ret = starknet::Event::deserialize(ref keys, ref data);
        assert!(data.is_empty(), "Event has extra data (wrong event?)");
        assert!(keys.is_empty(), "Event has extra keys (wrong event?)");
        (ret)
    }
    pub fn assert_no_events_left(address: ContractAddress) {
        assert!(testing::pop_log_raw(address).is_none(), "Events remaining on queue");
    }
    pub fn drop_event(address: ContractAddress) {
        match testing::pop_log_raw(address) {
            core::option::Option::Some(_) => {},
            core::option::Option::None => {},
        };
    }
    pub fn drop_all_events(address: ContractAddress) {
        loop {
            match testing::pop_log_raw(address) {
                core::option::Option::Some(_) => {},
                core::option::Option::None => { break; },
            };
        }
    }

    pub fn starts_with(input: ByteArray, prefix: ByteArray) -> bool {
        (if (input.len() < prefix.len()) {
            (false)
        } else {
            let mut result = true;
            let mut i = 0;
            while (i < prefix.len()) {
                if (input[i] != prefix[i]) {
                    result = false;
                    break;
                }
                i += 1;
            };
            (result)
        })
    }
}
