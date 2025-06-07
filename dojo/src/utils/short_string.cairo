
#[generate_trait]
pub impl ShortString of ShortStringTrait {
    fn strlen(self: felt252) -> usize {
        let mut result: usize = 0;
        let mut v: u256 = self.into();
        while (v != 0) {
            result += 1;
            v /= 0x100;
        };
        (result)
    }

    fn to_string(self: felt252) -> ByteArray {
        // alternative: core::to_byte_array::FormatAsByteArray
        let mut result: ByteArray = "";
        result.append_word(self, self.strlen());
        (result)
    }
}



//----------------------------------------
// Unit  tests
//
#[cfg(test)]
mod unit {
    use super::{ShortString};
    
    #[test]
    fn test_strlen() {
        assert_eq!(0.strlen(), 0, "0");
        assert_eq!(''.strlen(), 0, "empty");
        assert_eq!('1'.strlen(), 1, "not 1");
        assert_eq!('Hey'.strlen(), 3, "not 5");
        assert_eq!('Hey World'.strlen(), 9, "not 9");
        assert_eq!('1234567890123456789012345678901'.strlen(), 31, "not 31");
    }
    
    #[test]
    fn test_string() {
        assert_eq!(0.to_string(), "", "not 0");
        assert_eq!(''.to_string(), "", "not empty");
        assert_eq!('1'.to_string(), "1", "not 1");
        assert_eq!('Hey'.to_string(), "Hey", "not Hey");
        assert_eq!('Hey World'.to_string(), "Hey World", "not Hey World");
        assert_eq!('1234567890123456789012345678901'.to_string(), "1234567890123456789012345678901", "not 31");
    }
}
