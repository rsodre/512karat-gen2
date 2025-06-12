
pub trait SafeMathTrait<T,TI> {
    fn sub(a: T, b: T) -> T;
}

pub impl SafeMathU32 of SafeMathTrait<u32,i32> {
    fn sub(a: u32, b: u32) -> u32 {
        if (a <= b) {(0)} else {(a - b)}
    }
}

pub impl SafeMathU64 of SafeMathTrait<u64,i64> {
    fn sub(a: u64, b: u64) -> u64 {
        if (a <= b) {(0)} else {(a - b)}
    }
}


//----------------------------------------
// Unit  tests
//
#[cfg(test)]
mod unit {
    use super::{
        SafeMathU32,SafeMathU64,
    };

    #[test]
    fn test_sub_u32() {
        assert_eq!(SafeMathU32::sub(10, 0), 10, "sub32_10_0");
        assert_eq!(SafeMathU32::sub(10, 2), 8, "sub32_10_2");
        assert_eq!(SafeMathU32::sub(10, 9), 1, "sub32_10_9");
        assert_eq!(SafeMathU32::sub(10, 10), 0, "sub32_10_10");
        assert_eq!(SafeMathU32::sub(10, 11), 0, "sub32_10_11");
        assert_eq!(SafeMathU32::sub(10, 255), 0, "sub32_10_155");
    }
    
    #[test]
    fn test_sub_u64() {
        assert_eq!(SafeMathU64::sub(10, 0), 10, "sub64_10_0");
        assert_eq!(SafeMathU64::sub(10, 2), 8, "sub64_10_2");
        assert_eq!(SafeMathU64::sub(10, 9), 1, "sub64_10_9");
        assert_eq!(SafeMathU64::sub(10, 10), 0, "sub64_10_10");
        assert_eq!(SafeMathU64::sub(10, 11), 0, "sub64_10_11");
        assert_eq!(SafeMathU64::sub(10, 255), 0, "sub64_10_155");
    }

}
