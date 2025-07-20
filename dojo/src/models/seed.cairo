use starknet::{ContractAddress};
use karat_gen2::utils::hash::{make_seed};

#[dojo::model]
#[derive(Copy, Drop, Serde)]
pub struct Seed {
    #[key]
    pub contract_address: ContractAddress,
    #[key]
    pub token_id: u128,
    pub seed: felt252,
}

//---------------------------------------
// Traits
//

#[generate_trait]
pub impl SeedImpl of SeedTrait {
    fn new(contract_address: ContractAddress, token_id: u128) -> Seed {
        let seed: felt252 = make_seed(contract_address, token_id);
        (Seed { contract_address, token_id, seed })
    }
}

#[derive(Copy, Drop, Serde)]
pub struct Seeder {
    pub seed: u256,
    pub count: usize,
}

#[derive(Copy, Drop, Serde)]
pub struct RenderParams {
    pub sc_x: usize,
    pub sc_y: usize,
    pub off_x: usize,
    pub off_y: usize,
    pub mod_x: usize,
    pub mod_y: usize,
    pub fade_type: usize,
    pub fade_amount: usize,
}

#[generate_trait]
pub impl SeederImpl of SeederTrait {
    fn new(seed: u256) -> Seeder {
        (Seeder {
            seed,
            count: 0,
        })
    }
    fn get_next(ref self: Seeder, max_exclusive: usize) -> usize {
        let result: u256 = ((self.seed & 0xff) % max_exclusive.into());
        self.count += 1;
        self.seed /= 0x100;
        (result.try_into().unwrap())
    }
    fn get_render_params(ref self: Seeder, char_count: usize, HALF_W: usize, HALF_H: usize) -> RenderParams {
        let sc_x: usize = self.get_next(HALF_W);
        let sc_y = sc_x * self.get_next(3);
        let off_x: usize = self.get_next(HALF_W);
        let off_y: usize = self.get_next(HALF_H);
        let mod_x: usize = 1 + self.get_next(char_count);
        let mod_y: usize = 1 + self.get_next(char_count);
        let fade_type: usize = self.get_next(6);
        let fade_amount: usize = 1 + self.get_next(4);
        (RenderParams {
            sc_x,
            sc_y,
            off_x,
            off_y,
            mod_x,
            mod_y,
            fade_type,
            fade_amount,
        })
    }
}



//----------------------------
// tests
//
#[cfg(test)]
mod unit {
    use super::{Seed, SeedTrait, Seeder, SeederTrait};
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

    #[test]
    fn test_seeder() {
        let seed: u256 = 0x060504030201;
        let mut seeder: Seeder = SeederTrait::new(seed);
        assert_eq!(seeder.seed, seed.into(), "seed.seed_init");
        assert_eq!(seeder.count, 0, "seeder.count_init");
        assert_eq!(seeder.get_next(10), 1, "seeder.get_next(10)_1");
        assert_eq!(seeder.count, 1, "seeder.count(1)");
        assert_eq!(seeder.get_next(10), 2, "seeder.get_next(10)_2");
        assert_eq!(seeder.count, 2, "seeder.count(1)");
        assert_eq!(seeder.get_next(10), 3, "seeder.get_next(10)_3");
        assert_eq!(seeder.count, 3, "seeder.count(1)");
        assert_eq!(seeder.get_next(10), 4, "seeder.get_next(10)_4");
        assert_eq!(seeder.count, 4, "seeder.count(1)");
        assert_eq!(seeder.get_next(10), 5, "seeder.get_next(10)_5");
        assert_eq!(seeder.count, 5, "seeder.count(1)");
        assert_eq!(seeder.get_next(10), 6, "seeder.get_next(10)_6");
        assert_eq!(seeder.count, 6, "seeder.count(1)");
        assert_eq!(seeder.get_next(10), 0, "seeder.get_next(10)_7");
        assert_eq!(seeder.count, 7, "seeder.count(1)");
        // test mods
        let mut seeder: Seeder = SeederTrait::new(seed);
        assert_eq!(seeder.get_next(3), 1, "seeder.get_next(3)_1");
        assert_eq!(seeder.get_next(3), 2, "seeder.get_next(3)_2");
        assert_eq!(seeder.get_next(3), 0, "seeder.get_next(3)_3");
        assert_eq!(seeder.get_next(3), 1, "seeder.get_next(3)_4");
        assert_eq!(seeder.get_next(3), 2, "seeder.get_next(3)_5");
        assert_eq!(seeder.get_next(3), 0, "seeder.get_next(3)_6");
        assert_eq!(seeder.get_next(3), 0, "seeder.get_next(3)_7");
    }
}
