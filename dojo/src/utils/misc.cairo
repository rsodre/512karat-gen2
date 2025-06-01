use starknet::{ContractAddress};

pub mod CONST {
    pub const ETH_TO_WEI: u256 = 1_000_000_000_000_000_000;
    pub const ONE_DAY: u64 = 60 * 60 * 24;
}

pub fn ZERO() -> ContractAddress { starknet::contract_address_const::<0x0>() }

#[inline(always)]
pub fn WEI(value: u128) -> u128 {
    (value * CONST::ETH_TO_WEI.low)
}
#[inline(always)]
pub fn ETH(value: u128) -> u128 {
    (value / CONST::ETH_TO_WEI.low)
}
