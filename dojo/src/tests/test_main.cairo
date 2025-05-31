#[cfg(test)]
mod tests {
    // use starknet::{ContractAddress};

    use karat_v2::tests::tester::{
        tester,
        tester::{
            TestSystems,
            // ZERO, OWNER, OTHER, BUMMER, TREASURY,
            // StoreTrait,
            IMainDispatcherTrait,
        }
    };

    //
    // Initialize
    //

    #[test]
    fn test_validate() {
        let mut sys: TestSystems = tester::setup_world();
        sys.main.validate();
        assert!(true, "validated");
    }
}
