use karat_gen2::models::gen2::{
    class::{Class, ClassTrait},
    palette::{Palette, PaletteTrait},
};

#[derive(Drop)]
pub struct Gen2Props {
    pub token_id: u128,
    pub seed: u256,
    pub class: Class,
    pub palette: Palette,
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
    // internal
    fn _generate_class(self: @Seed) -> Class {
        let seed: u256 = (*self.seed).into();
        (ClassTrait::randomize(seed.low))
    }
    fn _generate_palette(self: @Seed) -> Palette {
        let seed: u256 = (*self.seed).into();
        (PaletteTrait::randomize(seed.high))
    }
    fn _generate_realm_id(self: @Seed) -> u128 {
        let seed: u256 = (*self.seed).into();
        ((seed.low % 8_000) + 1)
    }
    //
    // Gen2Props
    //
    fn generate_props(self: @Seed) -> Gen2Props {
        let palette: Palette = self._generate_palette();
        let class: Class =
            if (palette == Palette::Mono(0)) {Class::E(0)}
            else {self._generate_class()};
        let realm_id: u128 = self._generate_realm_id();
        let mut attributes: Span<Attribute> = array![
            Attribute {
                key: "Class",
                value: class.name(),
            },
            Attribute {
                key: "Class Style",
                value: class.style_name(),
            },
            Attribute {
                key: "Palette",
                value: palette.name(),
            },
            Attribute {
                key: "Palette Style",
                value: palette.style_name(),
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
            palette,
            realm_id,
            attributes,
        })
    }
}

