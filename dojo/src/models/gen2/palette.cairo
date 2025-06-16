
#[derive(Copy, Drop, Serde, PartialEq, Introspect)]
pub enum Palette {
    Karat: u32,
    Graphite: u32,
    Gold: u32,
    Cloak: u32,
    Shift: u32,
    Grape: u32,
    Draft: u32,
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
    fn randomize(seed: u128) -> Palette {
        let p: Palette = (seed % Self::palette_count()).into();
        let iseed: u32 = ((seed / 0x100) & 0xff).try_into().unwrap();
        let index: u32 = (iseed % p._get_inks().len());
        (match (p) {
            Palette::Karat => Palette::Karat(index),
            Palette::Graphite => Palette::Graphite(index),
            Palette::Gold => Palette::Gold(index),
            Palette::Cloak  => Palette::Cloak(index),
            Palette::Shift => Palette::Shift(index),
            Palette::Grape => Palette::Grape(index),
            Palette::Draft => Palette::Draft(index),
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
            Palette::Cloak(i) => (*i),
            Palette::Shift(i) => (*i),
            Palette::Grape(i) => (*i),
            Palette::Draft(i) => (*i),
            Palette::Paper(i) => (*i),
            Palette::Papyrus(i) => (*i),
            Palette::Mono(i) => (*i),
            Palette::Count => (0),
        })
    }
    fn name(self: @Palette) -> ByteArray {
        (match self {
            Palette::Karat      => "Karat",
            Palette::Graphite   => "Graphite",
            Palette::Gold       => "Gold",
            Palette::Cloak      => "Cloak",
            Palette::Shift      => "Shift",
            Palette::Grape      => "Grape",
            Palette::Draft      => "Draft",
            Palette::Paper      => "Paper",
            Palette::Papyrus    => "Papyrus",
            Palette::Mono       => "Mono",
            Palette::Count      => "Count",
        })
    }
    fn style_name(self: @Palette) -> ByteArray {
        (format!("{}-{}", self.name(), ('A'+self.get_index().into()).to_string()))
    }
    fn get_props(self: @Palette) -> (ByteArray, ByteArray, ByteArray) {
        let index: u32 = self.get_index();
        (
            self._get_bg(),
            self._get_inks().at(index).clone(),
            self._get_shadows().at(index).clone(),
        )
    }
    //---------------------------------------
    // generated from:
    // https://editor.p5js.org/rsodre/sketches/LbtLW29da
    //
    fn _get_bg(self: @Palette) -> ByteArray {
        (match self {
            Palette::Karat => "#181818",
            Palette::Graphite => "#242429",
            Palette::Gold => "#211c17",
            Palette::Cloak => "#1E3230",
            Palette::Shift => "#010813",
            Palette::Grape => "#1a001a",
            Palette::Draft => "#485057",
            Palette::Paper => "#fdf7e3",
            Palette::Papyrus => "#FDF1CB",
            Palette::Mono => "#ffffff",
            Palette::Count => "",
        })
    }
    fn _get_inks(self: @Palette) -> Array<ByteArray> {
        (match self {
            Palette::Karat(_) => array!["#c2e0fd", "#FFE694", "#dddddd"],
            Palette::Graphite(_) => array!["#B47D40", "#D76017", "#dddddd"],
            Palette::Gold(_) => array!["#F6DFC0", "#b98b3d"],
            Palette::Cloak(_) => array!["#3DBAA5", "#b98b3d", "#dddddd"],
            Palette::Shift(_) => array!["#67b4f8", "#ff33cc", "#FFFFFF"],
            Palette::Grape(_) => array!["#FF4949", "#FF9E49", "#F8DEEF"], 
            Palette::Draft(_) => array!["#42C7D4", "#acb4bc", "#ffffff"],
            Palette::Paper(_) => array!["#5B5B5B", "#735433", "#300808"],
            Palette::Papyrus(_) => array!["#06391A", "#222266", "#741036", "#e56729"],
            Palette::Mono(_) => array!["#000000", "#0800ff", "#FF005F"],
            Palette::Count => array![],
        })
    }
    fn _get_shadows(self: @Palette) -> Array<ByteArray> {
        (match self {
            Palette::Karat(_) => array!["", "#000000", "#0700CA"],
            Palette::Graphite(_) => array!["#000000", "#000000", "#CA0000"],
            Palette::Gold(_) => array!["", ""],
            Palette::Cloak(_) => array!["#181818", "#181818", "#181818"],
            Palette::Shift(_) => array!["#CA004C", "#0700CA", "#CA004C"],
            Palette::Grape(_) => array!["#CA0000", "#CA0000", ""],
            Palette::Draft(_) => array!["#00051E", "#0D1C67", "#0D1C67"],
            Palette::Paper(_) => array!["#b98b3d", "#FFA100", ""],
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
            Palette::Cloak => 3,
            Palette::Shift => 4,
            Palette::Grape => 5,
            Palette::Draft => 6,
            Palette::Paper => 7,
            Palette::Papyrus => 8,
            Palette::Mono => 9,
            Palette::Count => 10,
        }
    }
}
impl U128IntoPalette of Into<u128, Palette> {
    fn into(self: u128) -> Palette {
        match self {
            0 => Palette::Karat(0),
            1 => Palette::Graphite(0),
            2 => Palette::Gold(0),
            3 => Palette::Cloak(0),
            4 => Palette::Shift(0),
            5 => Palette::Grape(0),
            6 => Palette::Draft(0),
            7 => Palette::Paper(0),
            8 => Palette::Papyrus(0),
            9 => Palette::Mono(0),
            10 => Palette::Count,
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
    fn test_array_sizes() {
        let mut p: u128 = 0;
        loop {
            if (p == PaletteTrait::palette_count()) {
                break;
            }
            let palette: Palette = p.into();
            // println!("palette[{}][{}]: {},{}", p, palette.name(), palette._get_inks().len(), palette._get_shadows().len());
            assert_eq!(palette._get_inks().len(), palette._get_shadows().len(), "[{}] inks != shadows", palette.name());
            p += 1;
        };
    }

    #[test]
    #[ignore]
    fn test_random() {
        let mut p: u128 = 0;
        while (p < 100) {
            let seed: u256 = make_seed(OWNER(), p).into();
            let palette: Palette = PaletteTrait::randomize(seed.high);
            let index: u32 = match palette {
                Palette::Karat(i) => i,
                Palette::Graphite(i) => i,
                Palette::Gold(i) => i,
                Palette::Cloak(i) => i,
                Palette::Grape(i) => i,
                Palette::Shift(i) => i,
                Palette::Draft(i) => i,
                Palette::Paper(i) => i,
                Palette::Papyrus(i) => i,
                Palette::Mono(i) => i,
                Palette::Count => 0,
            };
            println!("random_palette[{}][{}] = [{}] {},{}", p, palette.style_name(), index, palette._get_inks().len(), palette._get_shadows().len());
            p += 1;
        };
    }
}

