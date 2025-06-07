
#[derive(Copy, Drop, Serde, PartialEq, Introspect)]
pub enum Palette {
    Karat: u32,
    Graphite: u32,
    Gold: u32,
    Turquoise: u32,
    Grape: u32,
    Blues: u32,
    Paper: u32,
    Papyrus: u32,
    Mono: u32,
    //----
    Count,
}


//---------------------------------------
// Traits
//
use karat_gen2::utils::short_string::{ShortStringTrait};

#[generate_trait]
pub impl PaletteImpl of PaletteTrait {
    fn palette_count() -> u128 {
        (Palette::Count.into())
    }
    fn randomize(seed: u256) -> Palette {
        let p: Palette = (seed.high % Self::palette_count()).into();
        let seed: u32 = ((seed.high / 0x100) & 0xff).try_into().unwrap();
        let index: u32 = (seed % p.get_inks().len());
        (match (p) {
            Palette::Karat => Palette::Karat(index),
            Palette::Grape => Palette::Grape(index),
            Palette::Graphite => Palette::Graphite(index),
            Palette::Gold => Palette::Gold(index),
            Palette::Turquoise  => Palette::Turquoise(index),
            Palette::Blues => Palette::Blues(index),
            Palette::Paper => Palette::Paper(index),
            Palette::Papyrus => Palette::Papyrus(index),
            Palette::Mono => Palette::Mono(index),
            Palette::Count => Palette::Count,
        })
    }
    fn get_index(self: @Palette) -> u32 {
        (match self {
            Palette::Karat(i) => (*i), 
            Palette::Graphite(i) => (*i), 
            Palette::Gold(i) => (*i), 
            Palette::Turquoise(i) => (*i), 
            Palette::Grape(i) => (*i), 
            Palette::Blues(i) => (*i), 
            Palette::Paper(i) => (*i), 
            Palette::Papyrus(i) => (*i), 
            Palette::Mono(i) => (*i), 
            Palette::Count => (0),
        })
    }
    fn name(self: @Palette) -> ByteArray {
        (match self {
            Palette::Karat      => "Karat",
            Palette::Grape      => "Grape",
            Palette::Graphite   => "Graphite",
            Palette::Gold       => "Gold",
            Palette::Turquoise  => "Turquoise",
            Palette::Blues      => "Blues",
            Palette::Paper      => "Paper",
            Palette::Papyrus    => "Papyrus",
            Palette::Mono       => "Mono",
            Palette::Count      => "Count",
        })
    }
    fn style_name(self: @Palette) -> ByteArray {
        (format!("{}-{}", self.name(), ('A'+self.get_index().into()).to_string()))
    }
    fn get_colors(self: @Palette) -> (ByteArray, ByteArray, ByteArray) {
        let index: u32 = self.get_index();
        (
            self.get_bg(),
            self.get_inks().at(index).clone(), 
            self.get_shadows().at(index).clone(), 
        )
    }
    //
    // generated from:
    // https://editor.p5js.org/rsodre/sketches/LbtLW29da
    //
    fn get_bg(self: @Palette) -> ByteArray {
        (match self {
            Palette::Karat => "#181818", 
            Palette::Graphite => "#242429", 
            Palette::Gold => "#211c17", 
            Palette::Turquoise => "#1E3230", 
            Palette::Grape => "#1a001a", 
            Palette::Blues => "#010813", 
            Palette::Paper => "#fdf7e3", 
            Palette::Papyrus => "#FDF1CB", 
            Palette::Mono => "#ffffff", 
            Palette::Count => "",
        })
    }
    fn get_inks(self: @Palette) -> Array<ByteArray> {
        (match self {
            Palette::Karat(_) => array!["#c2e0fd", "#FFE694", "#dddddd"], 
            Palette::Graphite(_) => array!["#c2e0fd", "#FFE694", "#FFFFFF"], 
            Palette::Gold(_) => array!["#F6DFC0", "#b98b3d"], 
            Palette::Turquoise(_) => array!["#3DBAA5", "#FFFFFF"], 
            Palette::Grape(_) => array!["#E3A3E3", "#E1C17B", "#FFFFFF"], 
            Palette::Blues(_) => array!["#67b4f8", "#ff33cc", "#FFFFFF"], 
            Palette::Paper(_) => array!["#333333", "#300808", "#735433"], 
            Palette::Papyrus(_) => array!["#06391A", "#222266", "#741036", "#e56729"], 
            Palette::Mono(_) => array!["#000000", "#0800ff", "#FF005F"], 
            Palette::Count => array![], 
        })
    }
    fn get_shadows(self: @Palette) -> Array<ByteArray> {
        (match self {
            Palette::Karat(_) => array!["", "", ""], 
            Palette::Graphite(_) => array!["", "", ""], 
            Palette::Gold(_) => array!["", ""], 
            Palette::Turquoise(_) => array!["#181818", "#181818"], 
            Palette::Grape(_) => array!["", "", ""], 
            Palette::Blues(_) => array!["#CA0000", "", "#CA0000"], 
            Palette::Paper(_) => array!["", "", "#b98b3d"], 
            Palette::Papyrus(_) => array!["#E1C17B", "", "", "#E1C17B"], 
            Palette::Mono(_) => array!["", "#CA004C", "#0700CA"], 
            Palette::Count => array![], 
        })
    }
}


impl PaletteIntoU128 of Into<Palette, u128> {
    fn into(self: Palette) -> u128 {
        match self {
            Palette::Karat => 0,
            Palette::Graphite => 1,
            Palette::Gold => 2,
            Palette::Turquoise => 3,
            Palette::Grape => 4,
            Palette::Blues => 5,
            Palette::Paper => 6,
            Palette::Papyrus => 7,
            Palette::Mono => 8,
            Palette::Count => 9,
        }
    }
}
impl U128IntoPalette of Into<u128, Palette> {
    fn into(self: u128) -> Palette {
        match self {
            0 => Palette::Karat(0),
            1 => Palette::Graphite(0),
            2 => Palette::Gold(0),
            3 => Palette::Turquoise(0),
            4 => Palette::Grape(0),
            5 => Palette::Blues(0),
            6 => Palette::Paper(0),
            7 => Palette::Papyrus(0),
            8 => Palette::Mono(0),
            9 => Palette::Count,
            _ => Palette::Karat(0),
        }
    }
}





//----------------------------
// tests
//
#[cfg(test)]
mod unit {
    use super::{Palette, PaletteTrait};
    use karat_gen2::utils::hash::{make_seed};
    use karat_gen2::tests::tester::tester::{OWNER};

    #[test]
    fn test_inks_shadows() {
        let mut p: u128 = 0;
        loop {
            if (p == PaletteTrait::palette_count()) {
                break;
            }
            let palette: Palette = p.into();
            // println!("palette[{}][{}]: {},{}", p, palette.name(), palette.get_inks().len(), palette.get_shadows().len());
            assert_eq!(palette.get_inks().len(), palette.get_shadows().len(), "[{}] inks != shadows", palette.name());
            p += 1;
        };
    }

    #[test]
    #[ignore]
    fn test_random() {
        let mut p: u128 = 0;
        while (p < 100) {
            let seed: u256 = make_seed(OWNER(), p).into();
            let palette: Palette = PaletteTrait::randomize(seed);
            let index: u32 = match palette {
                Palette::Karat(i) => i,
                Palette::Graphite(i) => i,
                Palette::Gold(i) => i,
                Palette::Turquoise(i) => i,
                Palette::Grape(i) => i,
                Palette::Blues(i) => i,
                Palette::Paper(i) => i,
                Palette::Papyrus(i) => i,
                Palette::Mono(i) => i,
                Palette::Count => 0,
            };
            println!("random_palette[{}][{}] = [{}] {},{}", p, palette.style_name(), index, palette.get_inks().len(), palette.get_shadows().len());
            p += 1;
        };
    }
}

