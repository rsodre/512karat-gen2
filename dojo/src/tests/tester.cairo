#[cfg(test)]
pub mod tester {
    use starknet::{ContractAddress, testing};

    use dojo::world::{WorldStorage};
    // use dojo::model::{ModelStorageTest};
    use dojo_cairo_test::{
        spawn_test_world,
        NamespaceDef, TestResource,
        ContractDefTrait, ContractDef,
        WorldStorageTestTrait,
    };

    pub use karat_v2::systems::main::{main, IMainDispatcher, IMainDispatcherTrait};
    pub use karat_v2::libs::dns::{DnsTrait};

    
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

    #[derive(Copy, Drop)]
    pub struct TestSystems {
        pub world: WorldStorage,
        pub main: IMainDispatcher,
        // pub store: Store,
    }

    #[generate_trait]
    pub impl TestSystemsImpl of TestSystemsTrait {
        #[inline(always)]
        fn from_world(world: WorldStorage) -> TestSystems {
            (TestSystems {
                world,
                main: world.main_dispatcher(),
                // store: StoreTrait::new(world),
            })
        }
    }

    pub fn setup_world() -> TestSystems {
        
        let mut resources: Array<TestResource> = array![
            // contracts
            TestResource::Contract(main::TEST_CLASS_HASH),
            // models
            // TestResource::Model(karat_v2::models::config::m_Config::TEST_CLASS_HASH),
        ];

        let mut contract_defs: Array<ContractDef> = array![
            ContractDefTrait::new(@"karat_v2", @"main")
                .with_writer_of([dojo::utils::bytearray_hash(@"karat_v2")].span())
                .with_init_calldata([].span())
        ];

        let namespace_def = NamespaceDef {
            namespace: "karat_v2",
            resources: resources.span(),
        };

        // setup block
        testing::set_block_number(1);
        testing::set_block_timestamp(INITIAL_TIMESTAMP);

        let mut world: WorldStorage = spawn_test_world([namespace_def].span());

        world.sync_perms_and_inits(contract_defs.span());

        let sys: TestSystems = TestSystemsTrait::from_world(world);

        impersonate(OWNER());

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

}
