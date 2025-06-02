#[cfg(test)]
mod tests {
    use starknet::{ContractAddress};
    // use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

    // karat
    use karat_gen2::{
        systems::{minter::{IMinterDispatcherTrait}},
        systems::{token::{ITokenDispatcherTrait}},
        models::token_config::{TokenConfig},
        models::seed::{Seed,},
        models::{constants},
        utils::misc::{WEI},
    };

    use karat_gen2::tests::{
        tester::{tester},
        tester::tester::{
            TestSystems, FLAGS,
            OWNER, OTHER, BUMMER, SPENDER, RECIPIENT, ZERO, TREASURY,
            StoreTrait,
        },
        mock_coin::{ICoinMockDispatcherTrait},
    };

    fn _start_presale(sys: TestSystems) {
        tester::impersonate(OWNER());
        sys.minter.set_paused(sys.token.contract_address, false);
    }
    fn _end_presale(sys: TestSystems) {
        tester::impersonate(OWNER());
        let timestamp: u64 = sys.store.get_token_config(sys.token.contract_address).presale_timestamp_end;
        tester::set_block_timestamp(timestamp + 1);
    }

    fn _approve(sys: TestSystems, account: ContractAddress, quantity: u128) -> u256 {
        let (purchase_coin_address, purchase_price) = sys.minter.get_price(sys.token.contract_address);
        assert_eq!(purchase_coin_address, sys.coin.contract_address, "purchase_coin_address");
        let approve_amount: u256 = (purchase_price * quantity).into();
        tester::impersonate(account);
        if (sys.coin.balance_of(account) < approve_amount) {
            sys.coin.faucet();
        }
        sys.coin.approve(sys.minter.contract_address, approve_amount);
        (approve_amount)
    }

    fn _assert_minted(sys: TestSystems, token_id: u128, expected_token_id: u128, owner: ContractAddress, prefix: ByteArray) -> felt252 {
        assert_eq!(token_id, expected_token_id, "[{}]: token_id", prefix);
        assert_eq!(sys.token.total_supply(), token_id.into(), "[{}]: total_supply", prefix);
        assert_eq!(sys.token.owner_of(token_id.into()), owner, "[{}]: owner_of", prefix);
        let seed: Seed = sys.store.get_seed(sys.token.contract_address, token_id);
        assert_ne!(seed.seed, 0, "[{}]: seed", prefix);
        (seed.seed)
    }

    fn _assert_can_mint(sys: TestSystems, prefix: ByteArray) {
        let can_mint: Option<ByteArray> = sys.minter.can_mint(sys.token.contract_address);
        assert!(can_mint.is_none(), "[{}]: can_mint: {}", prefix, can_mint.unwrap());
    }
    fn _assert_cannot_mint(sys: TestSystems, reason: ByteArray) {
        let can_mint: Option<ByteArray> = sys.minter.can_mint(sys.token.contract_address);
        assert!(can_mint.is_some(), "[{}]: cannot_mint (can mint)", reason);
        assert_eq!(can_mint.unwrap(), reason, "cannot_mint (wrong reason)");
    }

    //---------------------------------------
    // admin
    //

    #[test]
    fn test_initialized() {
        let sys: TestSystems = tester::setup_world(FLAGS::NONE);
        let (purchase_coin_address, purchase_price) = sys.minter.get_price(sys.token.contract_address);
        assert_ne!(purchase_coin_address, ZERO(), "purchase_coin_address");
        assert_ne!(purchase_price, 0, "purchase_price: !0");
        assert_eq!(purchase_price, WEI(constants::DEFAULT_STRK_PRICE_ETH.into()), "purchase_price: 50");
    }

    #[test]
    #[should_panic(expected:('MINTER: unavailable','ENTRYPOINT_FAILED'))]
    fn test_not_available() {
        let sys: TestSystems = tester::setup_world(FLAGS::NONE);
        tester::impersonate(RECIPIENT());
        sys.minter.mint(sys.token.contract_address);
    }

    #[test]
    fn test_admin_set_paused() {
        let sys: TestSystems = tester::setup_world(FLAGS::NONE);
        assert!(!sys.token.is_minting_paused(), "paused:START");
        tester::impersonate(OWNER());
        sys.minter.set_paused(sys.token.contract_address, false);
        assert!(!sys.token.is_minting_paused(), "paused:false");
        sys.minter.set_paused(sys.token.contract_address, true);
        assert!(sys.token.is_minting_paused(), "paused:true");
    }

    #[test]
    #[should_panic(expected:('MINTER: caller is not owner','ENTRYPOINT_FAILED'))]
    fn test_admin_set_paused_not_owner() {
        let sys: TestSystems = tester::setup_world(FLAGS::NONE);
        tester::impersonate(RECIPIENT());
        sys.minter.set_paused(sys.token.contract_address, false);
    }


    //---------------------------------------
    // mint
    //

    #[test]
    fn test_not_available_owner_can_mint() {
        let sys: TestSystems = tester::setup_world(FLAGS::NONE);
        tester::impersonate(OWNER());
        sys.minter.mint(sys.token.contract_address);
    }

    #[test]
    #[should_panic(expected:('KARAT: caller is not minter','ENTRYPOINT_FAILED'))]
    fn test_not_minter() {
        let sys: TestSystems = tester::setup_world(FLAGS::NONE);
        // direct karat minting is not possible
        tester::impersonate(RECIPIENT());
        sys.token.mint_next(RECIPIENT());
    }

    #[test]
    fn test_mint_ok() {
        let sys: TestSystems = tester::setup_world(FLAGS::NONE);
        assert_eq!(sys.token.total_supply(), 0, "supply = 0");
        // release...
        tester::impersonate(OTHER());
        _assert_cannot_mint(sys, "Unavailable");
        _start_presale(sys);
        // approve...
        tester::impersonate(OTHER());
        _assert_cannot_mint(sys, "Insufficient balance");
        _approve(sys, OTHER(), 2);
        // mint...
        tester::impersonate(OTHER());
        _assert_can_mint(sys, "presale");
        let token_id_1: u128 = sys.minter.mint(sys.token.contract_address);
        _assert_cannot_mint(sys, "Already minted");
        // minted...
        let seed_1: felt252 = _assert_minted(sys, token_id_1, 1, OTHER(), "TOKEN_1");
        // not whitelisted
        tester::impersonate(BUMMER());
        _assert_cannot_mint(sys, "Ineligible");
        //
        // after presale...
        _end_presale(sys);
        tester::impersonate(BUMMER());
        _assert_cannot_mint(sys, "Insufficient balance");
        _approve(sys, BUMMER(), 2);
        _assert_can_mint(sys, "post-presale");
        // mint...
        tester::impersonate(BUMMER());
        let token_id_2: u128 = sys.minter.mint(sys.token.contract_address);
        _assert_can_mint(sys, "could mint again 1");
        // minted...
        let seed_2: felt252 = _assert_minted(sys, token_id_2, 2, BUMMER(), "TOKEN_2");
        assert_ne!(seed_2, seed_1, "seed_2_1");
        //
        // mint to... 
        tester::impersonate(OTHER());
        _assert_can_mint(sys, "mint_to");
        let token_id_3: u128 = sys.minter.mint_to(sys.token.contract_address, BUMMER());
        _assert_can_mint(sys, "could mint again 2");
        // minted...
        let seed_3: felt252 = _assert_minted(sys, token_id_3, 3, BUMMER(), "TOKEN_3");
        assert_ne!(seed_3, seed_1, "seed_3_1");
        assert_ne!(seed_3, seed_2, "seed_3_2");
    }

    #[test]
    fn test_purchase_balance() {
        let sys: TestSystems = tester::setup_world(FLAGS::NONE);
        _start_presale(sys);
        // approve...
        tester::impersonate(OTHER());
        let amount_approved: u256 = _approve(sys, OTHER(), 4);
        let balance_other: u256 = sys.coin.balance_of(OTHER());
        assert_gt!(amount_approved, 0, "amount_approved_BEFORE");
        assert_gt!(balance_other, amount_approved, "balance_other_BEFORE");
        assert_eq!(sys.coin.balance_of(TREASURY()), 0, "balance_treasury_BEFORE");
        // mint all...
        tester::impersonate(OTHER());
        sys.minter.mint(sys.token.contract_address);
        _end_presale(sys);
        tester::impersonate(OTHER());
        sys.minter.mint(sys.token.contract_address);
        sys.minter.mint_to(sys.token.contract_address, SPENDER());
        sys.minter.mint_to(sys.token.contract_address, RECIPIENT());
        // balance moved to treasury
        assert_eq!(sys.coin.balance_of(OTHER()), (balance_other - amount_approved), "balance_approved_AFTER");
        assert_eq!(sys.coin.balance_of(TREASURY()), amount_approved, "balance_treasury_AFTER");
    }

    #[test]
    #[should_panic(expected:('MINTER: unavailable','ENTRYPOINT_FAILED'))]
    fn test_mint_unavailable() {
        let sys: TestSystems = tester::setup_world(FLAGS::NONE);
        tester::impersonate(OTHER());
        _assert_cannot_mint(sys, "Unavailable");
        sys.minter.mint(sys.token.contract_address);
    }

    #[test]
    #[should_panic(expected:('MINTER: ineligible to presale','ENTRYPOINT_FAILED'))]
    fn test_mint_presale_ineligible() {
        let sys: TestSystems = tester::setup_world(FLAGS::NONE);
        _start_presale(sys);
        tester::impersonate(BUMMER());
        _assert_cannot_mint(sys, "Ineligible");
        sys.minter.mint(sys.token.contract_address);
    }

    #[test]
    #[should_panic(expected:('MINTER: insufficient balance','ENTRYPOINT_FAILED'))]
    fn test_mint_presale_insufficient_balance() {
        let sys: TestSystems = tester::setup_world(FLAGS::NONE);
        _start_presale(sys);
        tester::impersonate(OTHER());
        _assert_cannot_mint(sys, "Insufficient balance");
        sys.minter.mint(sys.token.contract_address);
    }

    #[test]
    #[should_panic(expected:('MINTER: insufficient allowance','ENTRYPOINT_FAILED'))]
    fn test_mint_presale_insufficient_allowance() {
        let sys: TestSystems = tester::setup_world(FLAGS::NONE);
        _start_presale(sys);
        tester::impersonate(OTHER());
        sys.coin.faucet();
        _assert_can_mint(sys, "mint");
        sys.minter.mint(sys.token.contract_address);
    }

    #[test]
    #[should_panic(expected:('MINTER: already minted presale','ENTRYPOINT_FAILED'))]
    fn test_mint_presale_already_minted() {
        let sys: TestSystems = tester::setup_world(FLAGS::NONE);
        _start_presale(sys);
        tester::impersonate(OTHER());
        _approve(sys, OTHER(), 1);
        sys.minter.mint(sys.token.contract_address);
        _assert_cannot_mint(sys, "Already minted");
        sys.minter.mint(sys.token.contract_address);
    }

    #[test]
    #[should_panic(expected:('MINTER: presale to other','ENTRYPOINT_FAILED'))]
    fn test_presale_mint_to_not_allowed() {
        let sys: TestSystems = tester::setup_world(FLAGS::NONE);
        _start_presale(sys);
        _approve(sys, OTHER(), 2);
        // mint...
        tester::impersonate(OTHER());
        _assert_can_mint(sys, "mint");
        sys.minter.mint_to(sys.token.contract_address, BUMMER());
    }

    #[test]
    #[should_panic(expected:('MINTER: minting is paused','ENTRYPOINT_FAILED'))]
    fn test_presale_mint_paused() {
        let sys: TestSystems = tester::setup_world(FLAGS::NONE);
        _start_presale(sys);
        // pause
        assert!(!sys.token.is_minting_paused(), "paused:START");
        tester::impersonate(OWNER());
        sys.minter.set_paused(sys.token.contract_address, true);
        assert!(sys.token.is_minting_paused(), "paused:true");
        // mint...
        tester::impersonate(OTHER());
        _assert_cannot_mint(sys, "Paused");
        sys.minter.mint(sys.token.contract_address);
    }

    #[test]
    #[should_panic(expected:('MINTER: minting is paused','ENTRYPOINT_FAILED'))]
    fn test_mint_paused() {
        let sys: TestSystems = tester::setup_world(FLAGS::NONE);
        _start_presale(sys);
        _end_presale(sys);
        // pause
        assert!(!sys.token.is_minting_paused(), "paused:START");
        tester::impersonate(OWNER());
        sys.minter.set_paused(sys.token.contract_address, true);
        assert!(sys.token.is_minting_paused(), "paused:true");
        // mint...
        tester::impersonate(OTHER());
        _assert_cannot_mint(sys, "Paused");
        sys.minter.mint(sys.token.contract_address);
    }



    //---------------------------------------
    // admin
    //

    #[test]
    fn test_admin_set_purchase_price_ok() {
        let sys: TestSystems = tester::setup_world(FLAGS::NONE);
        tester::impersonate(OWNER());
        // initial state
        let config: TokenConfig = sys.store.get_token_config(sys.token.contract_address);
        assert_ne!(config.purchase_coin_address, ZERO(), "purchase_coin_address_INIT");
        assert_ne!(config.purchase_price_wei, 0, "purchase_price_wei_INIT");
        // config...
        sys.minter.set_purchase_price(sys.token.contract_address, OTHER(), 222);
        let config: TokenConfig = sys.store.get_token_config(sys.token.contract_address);
        assert_eq!(config.purchase_coin_address, OTHER(), "purchase_coin_address_AFTER");
        assert_eq!(config.purchase_price_wei, WEI(222), "purchase_price_wei_AFTER");
        // get price...
        let (purchase_coin_address, purchase_price) = sys.minter.get_price(sys.token.contract_address);
        assert_eq!(purchase_coin_address, config.purchase_coin_address, "purchase_coin_address_GET");
        assert_eq!(purchase_price, config.purchase_price_wei, "purchase_price_GET");
    }

    #[test]
    #[should_panic(expected:('MINTER: invalid token address','ENTRYPOINT_FAILED'))]
    fn test_admin_set_purchase_price_invalid_token() {
        let sys: TestSystems = tester::setup_world(FLAGS::NONE);
        sys.minter.set_purchase_price(sys.minter.contract_address, OTHER(), 255);
    }

    #[test]
    #[should_panic(expected:('MINTER: caller is not owner','ENTRYPOINT_FAILED'))]
    fn test_admin_set_purchase_price_not_owner() {
        let sys: TestSystems = tester::setup_world(FLAGS::NONE);
        tester::impersonate(OTHER());
        sys.minter.set_purchase_price(sys.token.contract_address, OTHER(), 255);
    }


}
