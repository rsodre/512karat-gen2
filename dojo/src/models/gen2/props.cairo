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
use karat_gen2::models::seed::{Seed, Seeder, SeederTrait, RenderParams};

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
    fn _generate_matrix(self: @Seed) -> (ByteArray, ByteArray) {
        // the matrix trait was added later, so it's a little hacky
        // we generate RenderParams with ANY arguments, just to clone the renderer
        // because we just need the last one, and it does not depend on the arguments
        let mut seeder: Seeder = SeederTrait::new((*self.seed).into());
        let p: RenderParams = seeder.get_render_params(20, 20, 20);
        let matrix: ByteArray = (if (p.fade_type == 1) { 
            ("Hollow") // inside-out
        } else if (p.fade_type == 2) {
            ("Karat") // inverted border
        } else if (p.fade_type == 3 ) {
            ("Horizon") // top/bottom v2
        } else if (p.fade_type == 4 ) {
            ("Crown") // top/bottom
        } else if (p.fade_type == 5 ) {
            ("Slit") // sides
        } else {
            ("Flat")
        });
        (
            matrix,
            format!("{}-{}", matrix, p.fade_amount),
        )
    }
    //
    // Gen2Props
    //
    fn generate_props(self: @Seed) -> Gen2Props {
        let palette: Palette = self._generate_palette();
        let class: Class = match palette {
            // The Mono palette is always Class::E(0 or 1)
            Palette::Mono(_) => (Class::E((*self.token_id % 2).try_into().unwrap())),
            _ => (self._generate_class())
        };
        let (matrix, matrix_style): (ByteArray, ByteArray) = self._generate_matrix();
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
                key: "Matrix",
                value: matrix,
            },
            Attribute {
                key: "Matrix Tier",
                value: matrix_style,
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




//----------------------------
// tests
//
#[cfg(test)]
mod unit {
    use super::{Gen2Props, Gen2PropsTrait};
    use karat_gen2::models::seed::{Seed};
    use karat_gen2::models::gen2::{palette::{Palette, PaletteTrait}};
    use karat_gen2::models::gen2::class::{Class, ClassTrait};
    use karat_gen2::tests::tester::tester::{OWNER};

    fn _check_class(seed: Seed) {
        let props: Gen2Props = seed.generate_props();
        // println!("{} {} {}", seed.token_id, props.palette.style_name(), props.class.style_name());
        match props.palette {
            Palette::Mono(_) => {}, // OK!
            _ => assert!(false, "wrong palette! {} {}", seed.token_id, props.palette.name()),
        };
        match props.class {
            Class::E(style) => assert_le!(style, 1, "wrong class style! {} {}", seed.token_id, props.class.name()),
            _ => assert!(false, "wrong class! {} {}", seed.token_id, props.class.name())
        };
    }

    #[test]
    fn test_mono_class() {
        let mut seed_value: u256 = 12123123;
        seed_value.high = 9;
        let mut seed: Seed = Seed{
            contract_address: OWNER(),
            token_id: 0,
            seed: seed_value.try_into().unwrap(),
        };
        while (seed.token_id < 10) {
            _check_class(seed);
            seed.token_id += 1;
        }
    }

}

