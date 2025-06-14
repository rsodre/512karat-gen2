
#[derive(Copy, Drop, Serde, PartialEq, Introspect)]
pub enum Class {
    A: u32,
    B: u32,
    C: u32,
    D: u32,
    E: u32,
    F: u32,
    H: u32,
    V: u32,
    L: u32,
    //----
    Count,
}


//---------------------------------------
// Traits
//
use karat_gen2::utils::short_string::{ShortStringTrait};

#[generate_trait]
pub impl ClassImpl of ClassTrait {
    fn class_count() -> u128 {
        (Class::Count.into())
    }
    fn randomize(seed: u128) -> Class {
        let p: Class = (seed % Self::class_count()).into();
        let iseed: u32 = ((seed / 0x100) & 0xff).try_into().unwrap();
        let index: u32 = (iseed % p._get_charsets().len());
        (match (p) {
            Class::A => Class::A(index),
            Class::B => Class::B(index),
            Class::C => Class::C(index),
            Class::D => Class::D(index),
            Class::E => Class::E(index),
            Class::F => Class::F(index),
            Class::H => Class::H(index),
            Class::V => Class::V(index),
            Class::L => Class::L(index),
            Class::Count => Class::Count,
        })
    }
    fn get_index(self: @Class) -> u32 {
        (match self {
            Class::A(i) => (*i),
            Class::B(i) => (*i),
            Class::C(i) => (*i),
            Class::D(i) => (*i),
            Class::E(i) => (*i),
            Class::F(i) => (*i),
            Class::H(i) => (*i),
            Class::V(i) => (*i),
            Class::L(i) => (*i),
            Class::Count => (0),
        })
    }
    fn name(self: @Class) -> ByteArray {
        match self {
            Class::A => "A",
            Class::B => "B",
            Class::C => "C",
            Class::D => "D",
            Class::E => "E",
            Class::F => "G",
            Class::H => "H",
            Class::V => "V",
            Class::L => "L",
            Class::Count => "Count",
        }
    }
    fn style_name(self: @Class) -> ByteArray {
        (format!("{}-{}", self.name(), ('A'+self.get_index().into()).to_string()))
    }
    fn get_props(self: @Class) -> (Span<felt252>, Span<usize>, ByteArray, usize, ByteArray, ByteArray) {
        let index: u32 = self.get_index();
        let (text_length, text_scale): (usize, ByteArray) = self._get_text_props();
        let (text_size): (ByteArray,) = self._get_adjustments();
        (
            self._get_charsets().at(index).clone(),
            self._get_charset_lengths().at(index).clone(),
            self._font_name().clone(),
            text_length,
            text_scale,
            text_size,
        )
    }
    //---------------------------------------
    // generated from:
    // https://editor.p5js.org/rsodre/sketches/LbtLW29da
    //
    fn _get_charsets(self: @Class) -> Span<Span<felt252>> {
        match self {
            Class::A => array![ 
                array!['&#95;', '&#95;', '&#9620;', '&#9620;', '&#9585;', '&#9585;', '&#9586;', '&#9586;', '&#9621;', '&#9621;'].span(),
                array!['&#95;', '&#95;', '&#9620;', '&#9620;', '&#9586;', '&#9586;', '&#9585;', '&#9585;', '&#9621;', '&#9621;'].span(),
                array!['&#95;', '&#95;', '&#9620;', '&#9620;', '&#9586;', '&#9585;', '&#9587;', '&#9587;', '&#9585;', '&#9586;', '&#9621;', '&#9621;'].span(),
            ].span(),
            Class::B => array![ 
                array!['&#9585;', '&#9585;', '&#9586;', '&#9586;'].span(),
                array!['&#9586;', '&#9586;', '&#9585;', '&#9585;'].span(),
                array!['&#9585;', '&#9585;', '&#9586;', '&#9585;', '&#9586;', '&#9586;'].span(),
                array!['&#9586;', '&#9586;', '&#9585;', '&#9585;', '&#9585;', '&#9586;', '&#9586;', '&#9586;', '&#9585;', '&#9585;'].span(),
                array!['&#9586;', '&#9585;', '&#9587;', '&#9585;', '&#9586;', '&#9587;', '&#9586;', '&#9585;'].span(),
            ].span(),
            Class::C => array![ 
                array!['&#45;', '&#45;', '&#9671;', '&#9643;', '&#9634;', '&#9634;', '&#9636;', '&#9637;', '&#9641;', '&#9641;', '&#11446;', '&#11452;', '&#11604;'].span(),
                array!['&#46;', '&#46;', '&#45;', '&#45;', '&#43;', '&#43;', '&#9643;', '&#9643;', '&#9643;', '&#9634;', '&#9634;', '&#9634;', '&#9641;', '&#9641;', '&#9641;', '&#9608;', '&#9608;', '&#9608;'].span(),
            ].span(),
            Class::D => array![ 
                array!['&#124;', '&#46;', '&#46;', '&#32;', '&#9671;', '&#9671;', '&#9670;', '&#9698;', '&#9700;', '&#9701;', '&#9699;', '&#9664;', '&#9654;', '&#11604;'].span(),
                array!['&#32;', '&#46;', '&#46;', '&#124;', '&#124;', '&#9671;', '&#9671;', '&#11604;', '&#9670;', '&#11042;', '&#9698;', '&#9700;', '&#9701;', '&#9699;', '&#11039;'].span(),
            ].span(),
            Class::E => array![ 
                array!['&#96;', '&#44;', '&#46;', '&#9587;', '&#9587;', '&#9623;', '&#9629;', '&#9622;', '&#9624;', '&#9626;', '&#9630;', '&#9625;', '&#9608;', '&#9620;'].span(),
                array!['&#46;', '&#46;', '&#95;', '&#95;', '&#9626;', '&#9630;', '&#9625;', '&#9623;', '&#9629;', '&#9622;', '&#9624;', '&#9587;', '&#9587;', '&#9621;', '&#9621;', '&#9608;', '&#9608;'].span(),
            ].span(),
            Class::F => array![ 
                array!['&#9621;', '&#9621;', '&#9620;', '&#9620;', '&#9597;', '&#9599;', '&#9597;', '&#9599;', '&#9608;', '&#9608;', '&#9620;', '&#9620;', '&#46;', '&#46;'].span(),
                array!['&#9476;', '&#9472;', '&#9473;', '&#9621;', '&#9620;', '&#9620;', '&#9550;', '&#9550;', '&#9474;', '&#9597;', '&#9599;', '&#9597;', '&#9599;', '&#9603;', '&#9603;', '&#9608;'].span(),
            ].span(),
            Class::H => array![ 
                array!['&#95;', '&#95;', '&#9601;', '&#9601;', '&#9602;', '&#9602;', '&#9603;', '&#9603;', '&#9604;', '&#9604;', '&#9605;', '&#9605;', '&#9607;', '&#9607;', '&#9608;', '&#9608;'].span(),
            ].span(),
            Class::V => array![ 
                array!['&#45;', '&#43;', '&#9608;', '&#9609;', '&#9610;', '&#9611;', '&#9612;', '&#9613;', '&#9614;'].span(),
                array!['&#46;', '&#32;', '&#32;', '&#32;', '&#9615;', '&#9614;', '&#9613;', '&#9612;', '&#9611;', '&#9610;', '&#9609;', '&#9630;', '&#9626;'].span(),
                array!['&#32;', '&#32;', '&#32;', '&#9615;', '&#9614;', '&#9613;', '&#9612;', '&#9611;', '&#9610;', '&#9609;', '&#9609;', '&#9610;', '&#9611;', '&#9612;', '&#9613;', '&#9614;', '&#9615;'].span(),
            ].span(),
            Class::L => array![ 
                array!['&#124;', '&#124;', '&#45;', '&#9769;', '&#12494;', '&#12504;', '&#12511;', '&#12530;', '&#915;', '&#76;', '&#11604;', '&#11604;', '&#882;', '&#124;', '&#12528;', '&#12460;', '&#12476;', '&#9698;', '&#9700;', '&#9701;', '&#9699;'].span(),
                array!['&#46;', '&#94;', '&#45;', '&#9769;', '&#42;', '&#9671;', '&#124;', '&#76;', '&#11604;', '&#11604;', '&#882;', '&#124;', '&#11446;', '&#915;', '&#11045;', '&#11042;', '&#9664;', '&#9654;', '&#11091;'].span(),
            ].span(),
            Class::Count => array![array![].span()].span(),
        }
    }
    fn _get_charset_lengths(self: @Class) -> Span<Span<u32>> {
        match self {
            Class::A => array![
                array![5, 5, 7, 7, 7, 7, 7, 7, 7, 7].span(),
                array![5, 5, 7, 7, 7, 7, 7, 7, 7, 7].span(),
                array![5, 5, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7].span(),
            ].span(),
            Class::B => array![ 
                array![7, 7, 7, 7].span(),
                array![7, 7, 7, 7].span(),
                array![7, 7, 7, 7, 7, 7].span(),
                array![7, 7, 7, 7, 7, 7, 7, 7, 7, 7].span(),
                array![7, 7, 7, 7, 7, 7, 7, 7].span(),
            ].span(),
            Class::C => array![ 
                array![5, 5, 7, 7, 7, 7, 7, 7, 7, 7, 8, 8, 8].span(),
                array![5, 5, 5, 5, 5, 5, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7].span(),
            ].span(),
            Class::D => array![ 
                array![6, 5, 5, 5, 7, 7, 7, 7, 7, 7, 7, 7, 7, 8].span(),
                array![5, 5, 5, 6, 6, 7, 7, 8, 7, 8, 7, 7, 7, 7, 8].span(),
            ].span(),
            Class::E => array![ 
                array![5, 5, 5, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7].span(),
                array![5, 5, 5, 5, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7].span(),
            ].span(),
            Class::F => array![ 
                array![7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 5, 5].span(),
                array![7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7].span(),
            ].span(),
            Class::H => array![ 
                array![5, 5, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7].span(),
            ].span(),
            Class::V => array![ 
                array![5, 5, 7, 7, 7, 7, 7, 7, 7].span(),
                array![5, 5, 5, 5, 7, 7, 7, 7, 7, 7, 7, 7, 7].span(),
                array![5, 5, 5, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7].span(),
            ].span(),
            Class::L => array![ 
                array![6, 6, 5, 7, 8, 8, 8, 8, 6, 5, 8, 8, 6, 6, 8, 8, 8, 7, 7, 7, 7].span(),
                array![5, 5, 5, 7, 5, 7, 6, 5, 8, 8, 6, 6, 8, 6, 8, 8, 7, 7, 8].span(),
            ].span(),
             Class::Count => array![array![].span()].span(),
        }
    }
    fn _get_text_props(self: @Class) -> (u32, ByteArray) {
        match self {
            Class::A => (18, "1.9"),
            Class::B => (18, "1.9"),
            Class::C => (36, "1"),
            Class::D => (36, "1"),
            Class::E => (21, "1.667"),
            Class::F => (18, "1.9"),
            Class::H => (21, "1.667"),
            Class::V => (36, "1"),
            Class::L => (36, "1"),  
            Class::Count => (0, ""),
        }
    }
    fn _font_name(self: @Class) -> ByteArray {
        match self {
            Class::A => "Courier New",
            Class::B => "Courier New",
            Class::C => "Courier New",
            Class::D => "Courier New",
            Class::E => "Courier New",
            Class::F => "Courier New",
            Class::H => "Courier New",
            Class::V => "Courier New",
            Class::L => "Times New Roman",
            Class::Count => "",
        }
    }
    //---------------------------------------
    // svg adjustements
    //
    fn _get_adjustments(self: @Class) -> (ByteArray,) {
        match self {
            Class::A => (("1px"),),
            Class::B => (("1px"),),
            Class::C => (("1px"),),
            Class::D => (("1px"),),
            Class::E => (("1px"),),
            Class::F => (("1px"),),
            Class::H => (("1.15px"),),
            Class::V => (("1px"),),
            Class::L => (("1px"),),  
            Class::Count => ((""),),
        }
    }
}


impl ClassIntoU128 of Into<Class, u128> {
    fn into(self: Class) -> u128 {
        match self {
            Class::A => 0,
            Class::B => 1,
            Class::C => 2,
            Class::D => 3,
            Class::E => 4,
            Class::F => 5,
            Class::H => 6,
            Class::V => 7,
            Class::L => 8,
            Class::Count => 9,
        }
    }
}
impl U128IntoClass of Into<u128, Class> {
    fn into(self: u128) -> Class {
        match self {
            0 => Class::A(0),
            1 => Class::B(0),
            2 => Class::C(0),
            3 => Class::D(0),
            4 => Class::E(0),
            5 => Class::F(0),
            6 => Class::H(0),
            7 => Class::V(0),
            8 => Class::L(0),
            9 => Class::Count,
            _ => Class::A(0),
        }
    }
}





//----------------------------
// tests
//
#[cfg(test)]
mod unit {
    use super::{Class, ClassTrait};
    // use karat_gen2::models::seed::{Seed, SeedTrait};

    #[test]
    fn test_array_sizes() {
        let mut c: u128 = 0;
        loop {
            if (c == ClassTrait::class_count()) {
                break;
            }
            let class: Class = c.into();
            // println!("class[{}][{}]: {},{}", c, class.name(), class._get_charsets().len(), class._get_charset_lengths().len());
            assert_eq!(class._get_charsets().len(), class._get_charset_lengths().len(), "[{}] charsets != charset_lengths", class.name());
            c += 1;
        };
    }
}

