use starknet::{ContractAddress};

#[starknet::interface]
pub trait IMockToken<TState> {
    fn balance_of(self: @TState, account: ContractAddress) -> u256;
    fn owner_of(self: @TState, token_id: u256) -> ContractAddress;
}

#[dojo::contract]
pub mod mock_token {
    use starknet::{ContractAddress};
    use dojo::world::{WorldStorage};
    use karat_v2::tests::tester::tester::{OWNER, OTHER, ZERO};

    #[generate_trait]
    impl WorldDefaultImpl of WorldDefaultTrait {
        #[inline(always)]
        fn world_default(self: @ContractState) -> WorldStorage {
            (self.world(@"karat_v2"))
        }
    }

    #[abi(embed_v0)]
    impl MockTokenImpl of super::IMockToken<ContractState> {
        fn balance_of(self: @ContractState, account: ContractAddress) -> u256 {
            if (account == OWNER()) {(1)}
            else if (account == OTHER()) {(2)}
            else {(0)}
        }
        fn owner_of(self: @ContractState, token_id: u256) -> ContractAddress {
            match token_id.low {
                0 => ZERO(),
                1 => OWNER(),
                2 => OTHER(),
                3 => OTHER(),
                _ => ZERO(),
            }
        }
    }
}
