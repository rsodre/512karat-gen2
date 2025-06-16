// default settings
pub const MAX_SUPPLY: u256 = 512;
pub const DEFAULT_STRK_PRICE_ETH: u8 = 50;
pub const DEFAULT_ROYALTY: u128 = 250;

// token metadata
pub fn TOKEN_NAME() -> ByteArray {"Karat 2nd Generation"}
pub fn TOKEN_SYMBOL() -> ByteArray {"KARATG2"}
// contract metadata
pub fn METADATA_DESCRIPTION() -> ByteArray {"Gemstones for composable lore, 2nd generation. Fully on-chain generative art made with Dojo."}
pub fn EXTERNAL_LINK() -> ByteArray {"https://karat.collect-code.com"}
pub fn BANNER_IMAGE() -> ByteArray {"https://karat.collect-code.com/assets/karat_gen2/banner.jpg"}

// karat#387
pub fn CONTRACT_IMAGE() -> ByteArray {
    ("https://karat.collect-code.com/assets/karat_gen2/icon.jpg")
    // ("data:image/svg+xml;base64,")
}
