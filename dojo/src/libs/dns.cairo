use starknet::{ContractAddress};
// use core::num::traits::Zero;
use dojo::world::{WorldStorage, WorldStorageTrait, IWorldDispatcher};
use dojo::meta::interface::{IDeployedResourceDispatcher, IDeployedResourceDispatcherTrait};

pub use karat_v2::systems::main::{IMainDispatcher, IMainDispatcherTrait};
use karat_v2::libs::misc::{ZERO};

pub mod SELECTORS {
    // systems
    pub const MAIN: felt252 = selector_from_tag!("karat_v2-main");
}

#[generate_trait]
pub impl DnsImpl of DnsTrait {
    #[inline(always)]
    fn find_contract_name(self: @WorldStorage, contract_address: ContractAddress) -> ByteArray {
        (IDeployedResourceDispatcher{contract_address}.dojo_name())
    }
    fn find_contract_address(self: @WorldStorage, contract_name: @ByteArray) -> ContractAddress {
        // let (contract_address, _) = self.dns(contract_name).unwrap(); // will panic if not found
        match self.dns_address(contract_name) {
            Option::Some(contract_address) => {
                (contract_address)
            },
            Option::None => {
                (ZERO())
            },
        }
    }

    // Create a Store from a dispatcher
    // https://github.com/dojoengine/dojo/blob/main/crates/dojo/core/src/contract/components/world_provider.cairo
    // https://github.com/dojoengine/dojo/blob/main/crates/dojo/core/src/world/storage.cairo
    #[inline(always)]
    fn storage(dispatcher: IWorldDispatcher, namespace: @ByteArray) -> WorldStorage {
        (WorldStorageTrait::new(dispatcher, namespace))
    }

    //--------------------------
    // system addresses
    //
    #[inline(always)]
    fn main_address(self: @WorldStorage) -> ContractAddress {
        (self.find_contract_address(@"main"))
    }
    //--------------------------
    // dispatchers
    //
    #[inline(always)]
    fn main_dispatcher(self: @WorldStorage) -> IMainDispatcher {
        (IMainDispatcher{ contract_address: self.main_address() })
    }
}
