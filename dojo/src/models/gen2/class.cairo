
#[derive(Copy, Drop, Serde, PartialEq, Introspect)]
pub enum Class {
    A,
    B,
    C,
    D,
    E,
    G,
    H,
    V,
    L,
    //----
    Count,
}


//---------------------------------------
// Traits
//

#[generate_trait]
pub impl ClassImpl of ClassTrait {
    fn class_count() -> u128 {
        (Class::Count.into())
    }
    fn name(self: @Class) -> ByteArray {
        match self {
            Class::A => "A",
            Class::B => "B",
            Class::C => "C",
            Class::D => "D",
            Class::E => "E",
            Class::G => "G",
            Class::H => "H",
            Class::V => "V",
            Class::L => "L",
            Class::Count => "Count",
        }
    }
    fn get_char_set(self: @Class) -> Span<felt252> {
        match self {
            Class::A => array!['&#95;', '&#95;', '&#9620;', '&#9620;', '&#9585;', '&#9585;', '&#9586;', '&#9586;', '&#9621;', '&#9621;'].span(), 
            Class::B => array!['&#9585;', '&#9585;', '&#9586;', '&#9585;', '&#9586;', '&#9586;'].span(), 
            Class::C => array!['&#46;', '&#46;', '&#45;', '&#45;', '&#43;', '&#43;', '&#9643;', '&#9643;', '&#9643;', '&#9634;', '&#9634;', '&#9634;', '&#9641;', '&#9641;', '&#9641;', '&#9608;', '&#9608;'].span(), 
            Class::D => array!['&#32;', '&#46;', '&#46;', '&#124;', '&#124;', '&#9671;', '&#9671;', '&#11604;', '&#9670;', '&#11042;', '&#9698;', '&#9700;', '&#9701;', '&#9699;', '&#11039;'].span(), 
            Class::E => array!['&#96;', '&#44;', '&#46;', '&#9587;', '&#9587;', '&#9623;', '&#9629;', '&#9622;', '&#9624;', '&#9626;', '&#9630;', '&#9625;', '&#9608;', '&#9620;'].span(), 
            Class::G => array!['&#9476;', '&#9472;', '&#9473;', '&#9620;', '&#9620;', '&#9603;', '&#9550;', '&#9474;', '&#9597;', '&#9599;', '&#9597;', '&#9599;', '&#9608;'].span(), 
            Class::H => array!['&#95;', '&#95;', '&#9601;', '&#9601;', '&#9602;', '&#9602;', '&#9603;', '&#9603;', '&#9604;', '&#9604;', '&#9605;', '&#9605;', '&#9607;', '&#9607;', '&#9608;', '&#9608;'].span(), 
            Class::V => array!['&#32;', '&#32;', '&#32;', '&#9615;', '&#9614;', '&#9613;', '&#9612;', '&#9611;', '&#9610;', '&#9609;', '&#9609;', '&#9610;', '&#9611;', '&#9612;', '&#9613;', '&#9614;'].span(),
            Class::L => array!['&#46;', '&#94;', '&#45;', '&#9769;', '&#42;', '&#9671;', '&#124;', '&#76;', '&#11604;', '&#11604;', '&#882;', '&#124;', '&#11446;', '&#915;', '&#11045;', '&#11042;', '&#9664;', '&#9654;', '&#11091;'].span(),
            Class::Count => array![].span(),
        }
    }
    fn get_char_set_lengths(self: @Class) -> Span<usize> {
        match self {
            Class::A => array![5, 5, 7, 7, 7, 7, 7, 7, 7, 7].span(), 
            Class::B => array![7, 7, 7, 7, 7, 7].span(), 
            Class::C => array![5, 5, 5, 5, 5, 5, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7].span(), 
            Class::D => array![5, 5, 5, 6, 6, 7, 7, 8, 7, 8, 7, 7, 7, 7, 8].span(), 
            Class::E => array![5, 5, 5, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7].span(), 
            Class::G => array![7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7].span(), 
            Class::H => array![5, 5, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7].span(), 
            Class::V => array![5, 5, 5, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7].span(), 
            Class::L => array![5, 5, 5, 7, 5, 7, 6, 5, 8, 8, 6, 6, 8, 6, 8, 8, 7, 7, 8].span(), 
            Class::Count => array![].span(),
        }
    }
    fn get_text_size(self: @Class) -> (usize, ByteArray) {
        match self {
            Class::A => (18, "1.9"), 
            Class::B => (18, "1.9"), 
            Class::C => (36, "1"), 
            Class::D => (36, "1"), 
            Class::E => (22, "1.62"), 
            Class::G => (18, "1.9"), 
            Class::H => (22, "1.62"), 
            Class::V => (36, "1"), 
            Class::L => (36, "1"), 
            Class::Count => (0, ""), 
        }
    }
    fn font_name(self: @Class) -> ByteArray {
        match self {
            Class::A => "Courier New", 
            Class::B => "Courier New", 
            Class::C => "Courier New", 
            Class::D => "Courier New", 
            Class::E => "Courier New", 
            Class::G => "Courier New", 
            Class::H => "Courier New", 
            Class::V => "Courier New", 
            Class::L => "Times New Roman", 
            Class::Count => "",
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
            Class::G => 5,
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
            0 => Class::A,
            1 => Class::B,
            2 => Class::C,
            3 => Class::D,
            4 => Class::E,
            5 => Class::G,
            6 => Class::H,
            7 => Class::V,
            8 => Class::L,
            9 => Class::Count,
            _ => Class::A,
        }
    }
}





//----------------------------
// tests
//
// #[cfg(test)]
// mod unit {
//     use super::{Class, ClassTrait};
//     use karat_gen2::models::seed::{Seed, SeedTrait};

//     #[test]
//     fn test_class_array_sizes() {
//         let mut c: u128 = 0;
//         loop {
//             if (c == ClassTrait::class_count()) {
//                 break;
//             }
//             let seed: Seed = Seed{ token_id:1, seed:(0x57237+c) };
//             let class: Class = seed.get_class();
//             assert!(class.get_char_set().len() == CHAR_COUNT, 'not char len');
//             c += 1;
//         };
//     }
// }

