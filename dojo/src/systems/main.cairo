
// Exposed to clients
#[starknet::interface]
pub trait IMain<TState> {
    fn validate(ref self: TState); // @description: Validate player tokens
}

#[dojo::contract]
pub mod main {
    // use core::num::traits::Zero;
    // use starknet::{ContractAddress};
    use dojo::world::{WorldStorage, IWorldDispatcherTrait};
    use karat_v2::libs::dns::{SELECTORS};



    pub mod Errors {
        pub const CALLER_NOT_OWNER: felt252         = 'KARAT-V2: Caller not owner';
        pub const NOT_IMPLEMENTED: felt252          = 'KARAT-V2: Not implemented';
    }

    fn dojo_init(ref self: ContractState) {
    }

    #[generate_trait]
    impl WorldDefaultImpl of WorldDefaultTrait {
        #[inline(always)]
        fn world_default(self: @ContractState) -> WorldStorage {
            (self.world(@"karat_v2"))
        }
    }

    #[abi(embed_v0)]
    impl MainImpl of super::IMain<ContractState> {

        //------------------------
        // Game actions
        //

        fn validate(ref self: ContractState) {
            // let mut store: Store = StoreTrait::new(self.world_default());
            // assert(false, Errors::NOT_IMPLEMENTED);
        }
    }

    //------------------------------------
    // Internal calls
    //
    #[generate_trait]
    impl InternalImpl of InternalTrait {
        fn _assert_caller_is_owner(self: @ContractState) {
            let mut world = self.world_default();
            assert(world.dispatcher.is_owner(SELECTORS::MAIN, starknet::get_caller_address()) == true, Errors::CALLER_NOT_OWNER);
        }
    }
}

