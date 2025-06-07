// default settings
pub const MAX_SUPPLY: u256 = 512;
pub const DEFAULT_STRK_PRICE_ETH: u8 = 50;
pub const DEFAULT_ROYALTY: u128 = 250;

// token metadata
pub fn TOKEN_NAME() -> ByteArray {"Karat Generation 2"}
pub fn TOKEN_SYMBOL() -> ByteArray {"KARAT2G"}
// contract metadata
pub fn METADATA_DESCRIPTION() -> ByteArray {"Gemstones for composable lore"}
pub fn EXTERNAL_LINK() -> ByteArray {"https://karat.collect-code.com"}
pub fn BANNER_IMAGE() -> ByteArray {"https://karat.collect-code.com/banner.png"}

// karat#387
pub fn CONTRACT_IMAGE() -> ByteArray {
    ("data:image/svg+xml;base64,")
}
