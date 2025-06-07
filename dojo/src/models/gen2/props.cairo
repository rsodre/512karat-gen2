use karat_gen2::models::gen2::{
    class::{Class, ClassTrait},
};

#[derive(Drop)]
pub struct Gen2Props {
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
use karat_gen2::models::seed::{Seed};

#[generate_trait]
pub impl Gen2PropsImpl of Gen2PropsTrait {
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
    // Gen2Props
    //
    fn get_gen2_props(self: @Seed) -> Gen2Props {
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
        (Gen2Props{
            token_id: *self.token_id,
            seed: (*self.seed).into(),
            class,
            realm_id,
            attributes,
        })
    }
}

