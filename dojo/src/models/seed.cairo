use starknet::{ContractAddress};
use karat_gen2::utils::hash::{make_seed};
use karat_gen2::{
    models::class::{Class, ClassTrait},
};

#[dojo::model]
#[derive(Copy, Drop, Serde)]
pub struct Seed {
    #[key]
    pub contract_address: ContractAddress,
    #[key]
    pub token_id: u128,
    pub seed: felt252,
}

#[derive(Drop)]
pub struct TokenData {
    pub token_id: u128,
    pub seed: u256,
    pub class: Class,
    pub realm_id: u128,
    pub attributes: Span<Attribute>,
}


//---------------------------------------
// Traits
//
use nft_combo::utils::renderer::{Attribute};

#[generate_trait]
pub impl SeedTraitImpl of SeedTrait {
    fn new(contract_address: ContractAddress, token_id: u128) -> Seed {
        let seed: felt252 = make_seed(contract_address, token_id);
        (Seed { contract_address, token_id, seed })
    }
    fn get_class(self: @Seed) -> Class {
        let seed: u256 = (*self.seed).into();
        let s: u128 = (seed.low % ClassTrait::class_count());
        (s.into())
    }
    fn get_realm_id(self: @Seed) -> u128 {
        let seed: u256 = (*self.seed).into();
        ((seed.low % 8_000) + 1)
    }
    //
    // TokenData
    //
    fn get_token_data(self: @Seed) -> TokenData {
        let class: Class = self.get_class();
        let realm_id: u128 = self.get_realm_id();
        let mut attributes: Span<Attribute> = array![
            Attribute {
                key: "Class",
                value: class.name(),
            },
            Attribute {
                key: "Realm",
                value: format!("{}", realm_id),
            },
        ].span();
        (TokenData{
            token_id: *self.token_id,
            seed: (*self.seed).into(),
            class,
            realm_id,
            attributes,
        })
    }
}



//----------------------------
// tests
//
#[cfg(test)]
mod tests {
    use super::{Seed, SeedTrait};
    use karat_gen2::tests::tester::tester::{OWNER, OTHER};

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
