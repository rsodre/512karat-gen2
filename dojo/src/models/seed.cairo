use starknet::{ContractAddress};
use karat_v2::utils::hash::{make_seed};
// use karat_v2::{
//     models::class::{Class, ClassTrait, CLASS_COUNT},
// };

#[dojo::model]
#[derive(Copy, Drop, Serde)]
pub struct Seed {
    #[key]
    pub contract_address: ContractAddress,
    #[key]
    pub token_id: u128,
    pub seed: felt252,
}

#[generate_trait]
pub impl SeedTraitImpl of SeedTrait {
    fn new(contract_address: ContractAddress, token_id: u128) -> Seed {
        let seed: felt252 = make_seed(contract_address, token_id);
        (Seed { contract_address, token_id, seed })
    }
    // fn get_class(self: Seed) -> Class {
    //     let s: u128 = (self.seed % CLASS_COUNT);
    //     if (s == 0) { Class::A }
    //     else if (s == 1) { Class::B }
    //     else if (s == 2) { Class::C }
    //     else if (s == 3) { Class::D }
    //     else if (s == 4) { Class::E }
    //     else if (s == 5) { Class::L }
    //     else  { Class::A }
    // }
    // fn get_realm_id(self: Seed) -> felt252 {
    //     ((self.seed % 8_000).into() + 1)
    // }
}





//----------------------------
// tests
//
#[cfg(test)]
mod tests {
    use super::{Seed, SeedTrait};
    use karat_v2::tests::tester::tester::{OWNER, OTHER};

    #[test]
    fn test_seed_is_unique() {
        let seed_A_1: Seed = SeedTrait::new(OWNER(), 1);
        let seed_A_2: Seed = SeedTrait::new(OWNER(), 2);
        let seed_A_1b: Seed = SeedTrait::new(OWNER(), 1);
        assert_gt!(seed_A_1.seed.into(), 0_u256, "seed_A_1");
        assert_gt!(seed_A_2.seed.into(), 0_u256, "seed_A_2");
        assert_ne!(seed_A_1.seed, seed_A_2.seed, "seed_A_1 <> seed_A_2");
        assert_eq!(seed_A_1.seed, seed_A_1b.seed, "seed_A_1 == seed_A_1b");
        let seed_B_1 = SeedTrait::new(OTHER(), 1);
        let seed_B_2 = SeedTrait::new(OTHER(), 2);
        assert_gt!(seed_B_1.seed.into(), 0_u256, "seed_B_1");
        assert_gt!(seed_B_2.seed.into(), 0_u256, "seed_B_2");
        assert_ne!(seed_B_1.seed, seed_B_2.seed, "seed_B_1 <> seed_B_2");
        assert_ne!(seed_B_1.seed, seed_A_1.seed, "seed_B_1 <> seed_A_1");
        assert_ne!(seed_B_2.seed, seed_A_2.seed, "seed_B_2 <> seed_A_2");
    }
}
