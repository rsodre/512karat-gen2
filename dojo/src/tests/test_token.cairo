#[cfg(test)]
mod tests {
    // use starknet::{ContractAddress};
    // use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

    // karat
    use karat_gen2::{
        systems::{token::{ITokenDispatcherTrait}},
        systems::{minter::{IMinterDispatcherTrait}},
        models::gen2::{constants},
        models::seed::{Seed},
        utils::misc::{WEI},
    };
    use karat_gen2::tests::{
        tester::{tester},
        tester::tester::{
            TestSystems, FLAGS,
            Store, StoreTrait,
            OWNER, OTHER, TREASURY,
        },
    };

    use openzeppelin_introspection::{interface as src5_interface};
    use openzeppelin_token::erc721::{interface as erc721_interface};
    use nft_combo::common::{interface as common_interface};
    
    pub const DEFAULT_DENOMINATOR: u128 = 10_000;
    pub const DEFAULT_FEE: u128 = 250;

    fn _set_seed(ref sys: TestSystems, token_id: u128, new_seed: felt252) {
        let mut store: Store = StoreTrait::new(sys.world);
        let mut seed: Seed = store.get_seed(sys.token.contract_address, token_id);
        seed.seed = new_seed;
        tester::set_seed(ref sys.world, @seed);
    }

    #[test]
    fn test_initialized() {
        let sys: TestSystems = tester::setup_world(FLAGS::NONE);
        println!("NAME: {}", sys.token.name());
        println!("SYMBOL: {}", sys.token.symbol());
        assert_ne!(sys.token.name(), "", "empty name");
        assert_ne!(sys.token.symbol(), "", "empty symbol");
        assert_eq!(sys.token.name(), constants::TOKEN_NAME(), "wrong name");
        assert_eq!(sys.token.symbol(), constants::TOKEN_SYMBOL(), "wrong symbol");
        assert!(sys.token.supports_interface(src5_interface::ISRC5_ID), "should support ISRC5_ID");
        assert!(sys.token.supports_interface(erc721_interface::IERC721_ID), "should support IERC721_ID");
        assert!(sys.token.supports_interface(erc721_interface::IERC721_METADATA_ID), "should support METADATA");
        assert!(sys.token.supports_interface(common_interface::IERC7572_ID), "should support IERC7572_ID");
        assert!(sys.token.supports_interface(common_interface::IERC4906_ID), "should support IERC4906_ID");
        assert!(sys.token.supports_interface(common_interface::IERC2981_ID), "should support IERC2981_ID");
    }

    #[test]
    fn test_token_uri() {
        let mut sys: TestSystems = tester::setup_world(FLAGS::UNPAUSE);
        tester::impersonate(OWNER());
        sys.minter.mint(sys.token.contract_address);
_set_seed(ref sys, 1, 0x05ffb53ecb1afe4b91ff5d2365207ed973f916afae1ebfaf73a90aa56c6368cb);
        let uri: ByteArray = sys.token.token_uri(1);
        let uri_camel = sys.token.tokenURI(1);
println!("___token_uri(1):[{}]", uri);
        assert_gt!(uri.len(), 0, "contract_uri() should not be empty");
        assert_eq!(uri, uri_camel, "contractURI() == contract_uri()");
        assert!(tester::starts_with(uri, "data:"), "contract_uri() should be a json string");
    }


    //
    // contract_uri
    //

    #[test]
    fn test_contract_uri() {
        let sys: TestSystems = tester::setup_world(FLAGS::NONE);
        let uri: ByteArray = sys.token.contract_uri();
        let uri_camel = sys.token.contractURI();
println!("___contract_uri():[{}]", uri);
        assert_ne!(uri, "", "contract_uri() should not be empty");
        assert_eq!(uri, uri_camel, "contractURI() == contract_uri()");
        assert!(tester::starts_with(uri, "data:"), "contract_uri() should be a json string");
    }


    //
    // royalty_info
    //

    #[test]
    fn test_default_royalty() {
        let sys: TestSystems = tester::setup_world(FLAGS::NONE);
        let (receiver, numerator, denominator) = sys.token.default_royalty();
        assert_eq!(receiver, TREASURY(), "set: wrong receiver");
        assert_eq!(numerator, DEFAULT_FEE, "set: wrong numerator");
        assert_eq!(denominator, DEFAULT_DENOMINATOR, "set: denominator");
    }

    #[test]
    fn test_token_royalty() {
        let sys: TestSystems = tester::setup_world(FLAGS::NONE);
        let (receiver, numerator, denominator) = sys.token.token_royalty(1);
        assert_eq!(receiver, TREASURY(), "set: wrong receiver");
        assert_eq!(numerator, DEFAULT_FEE, "set: wrong numerator");
        assert_eq!(denominator, DEFAULT_DENOMINATOR, "set: denominator");
    }

    #[test]
    fn test_royalty_info() {
        let sys: TestSystems = tester::setup_world(FLAGS::NONE);
        let PRICE: u128 = WEI(1000); // 1000 STRK
        let (receiver, fees) = sys.token.royalty_info(1, PRICE.into());
        assert_eq!(receiver, TREASURY(), "set: wrong receiver");
        assert_eq!(fees, WEI(25).into(), "set: wrong fees"); // default 2.5%
    }
    
    //
    // admin
    //

    #[test]
    fn test_admin_set_paused() {
        let sys: TestSystems = tester::setup_world(FLAGS::NONE);
        assert!(!sys.token.is_minting_paused(), "paused:START");
        tester::impersonate(sys.minter.contract_address);
        sys.token.set_paused(false);
        assert!(!sys.token.is_minting_paused(), "paused:false");
        sys.token.set_paused(true);
        assert!(sys.token.is_minting_paused(), "paused:true");
    }

    #[test]
    #[should_panic(expected:('KARAT: caller is not minter','ENTRYPOINT_FAILED'))]
    fn test_admin_set_paused_not_minter() {
        let sys: TestSystems = tester::setup_world(FLAGS::NONE);
        tester::impersonate(OWNER());
        sys.token.set_paused(false);
    }

    #[test]
    fn test_admin_set_reserved_supply() {
        let sys: TestSystems = tester::setup_world(FLAGS::NONE);
        assert_eq!(sys.token.reserved_supply(), 12, "reserved_supply:START");
        tester::impersonate(OWNER());
        sys.token.set_reserved_supply(10);
        assert_eq!(sys.token.reserved_supply(), 10, "reserved_supply:10");
        tester::impersonate(OWNER());
        sys.token.set_reserved_supply(0);
        assert_eq!(sys.token.reserved_supply(), 0, "reserved_supply:0");
    }

    #[test]
    #[should_panic(expected:('KARAT: caller is not owner','ENTRYPOINT_FAILED'))]
    fn test_admin_set_reserved_supply_not_owner() {
        let sys: TestSystems = tester::setup_world(FLAGS::NONE);
        tester::impersonate(OTHER());
        sys.token.set_reserved_supply(0);
    }

}
