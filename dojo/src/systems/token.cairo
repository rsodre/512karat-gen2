use starknet::{ContractAddress};
use dojo::world::IWorldDispatcher;

#[starknet::interface]
pub trait IToken<TState> {
    // IWorldProvider
    fn world_dispatcher(self: @TState) -> IWorldDispatcher;

    //-----------------------------------
    // IERC721ComboABI start
    //
    // (ISRC5)
    fn supports_interface(self: @TState, interface_id: felt252) -> bool;
    // (IERC721)
    fn balance_of(self: @TState, account: ContractAddress) -> u256;
    fn owner_of(self: @TState, token_id: u256) -> ContractAddress;
    fn safe_transfer_from(ref self: TState, from: ContractAddress, to: ContractAddress, token_id: u256, data: Span<felt252>);
    fn transfer_from(ref self: TState, from: ContractAddress, to: ContractAddress, token_id: u256);
    fn approve(ref self: TState, to: ContractAddress, token_id: u256);
    fn set_approval_for_all(ref self: TState, operator: ContractAddress, approved: bool);
    fn get_approved(self: @TState, token_id: u256) -> ContractAddress;
    fn is_approved_for_all(self: @TState, owner: ContractAddress, operator: ContractAddress) -> bool;
    // (IERC721Metadata)
    fn name(self: @TState) -> ByteArray;
    fn symbol(self: @TState) -> ByteArray;
    fn token_uri(self: @TState, token_id: u256) -> ByteArray;
    fn tokenURI(self: @TState, tokenId: u256) -> ByteArray;
    //-----------------------------------
    // IERC721Minter
    fn max_supply(self: @TState) -> u256;
    fn total_supply(self: @TState) -> u256;
    fn last_token_id(self: @TState) -> u256;
    fn is_minting_paused(self: @TState) -> bool;
    fn is_owner_of(self: @TState, address: ContractAddress, token_id: u256) -> bool;
    fn token_exists(self: @TState, token_id: u256) -> bool;
    fn totalSupply(self: @TState) -> u256;
    //-----------------------------------
    // IERC7572ContractMetadata
    fn contract_uri(self: @TState) -> ByteArray;
    fn contractURI(self: @TState) -> ByteArray;
    //-----------------------------------
    // IERC4906MetadataUpdate
    //-----------------------------------
    // IERC2981RoyaltyInfo
    fn royalty_info(self: @TState, token_id: u256, sale_price: u256) -> (ContractAddress, u256);
    fn default_royalty(self: @TState) -> (ContractAddress, u128, u128);
    fn token_royalty(self: @TState, token_id: u256) -> (ContractAddress, u128, u128);
    // IERC721ComboABI end
    //-----------------------------------

    // karat_gen2
    fn mint_next(ref self: TState, recipient: ContractAddress) -> u128;
    fn burn(ref self: TState, token_id: u256);
    fn get_token_svg(ref self: TState, token_id: u128) -> ByteArray;
    fn set_paused(ref self: TState, is_paused: bool);
    fn update_token_metadata(ref self: TState, token_id: u256);
    fn update_tokens_metadata(ref self: TState, from_token_id: u256, to_token_id: u256);
    fn update_contract_metadata(ref self: TState);
}

#[starknet::interface]
pub trait ITokenPublic<TState> {
    fn mint_next(ref self: TState, recipient: ContractAddress) -> u128;
    fn burn(ref self: TState, token_id: u256);
    fn get_token_svg(ref self: TState, token_id: u128) -> ByteArray;
    // admin
    fn set_paused(ref self: TState, is_paused: bool);
    fn update_token_metadata(ref self: TState, token_id: u256);
    fn update_tokens_metadata(ref self: TState, from_token_id: u256, to_token_id: u256);
    fn update_contract_metadata(ref self: TState);
}

#[dojo::contract]
pub mod token {
    use starknet::ContractAddress;
    use dojo::world::{WorldStorage, IWorldDispatcherTrait};

    //-----------------------------------
    // ERC721 start
    //
    use openzeppelin_introspection::src5::SRC5Component;
    use openzeppelin_token::erc721::ERC721Component;
    use nft_combo::erc721::erc721_combo::ERC721ComboComponent;
    use nft_combo::erc721::erc721_combo::ERC721ComboComponent::{ERC721HooksImpl};
    use nft_combo::utils::renderer::{ContractMetadata, TokenMetadata};
    use nft_combo::utils::encoder::{EncoderTrait};
    component!(path: SRC5Component, storage: src5, event: SRC5Event);
    component!(path: ERC721Component, storage: erc721, event: ERC721Event);
    component!(path: ERC721ComboComponent, storage: erc721_combo, event: ERC721ComboEvent);
    impl ERC721InternalImpl = ERC721Component::InternalImpl<ContractState>;
    impl ERC721ComboInternalImpl = ERC721ComboComponent::InternalImpl<ContractState>;
    #[abi(embed_v0)]
    impl ERC721ComboMixinImpl = ERC721ComboComponent::ERC721ComboMixinImpl<ContractState>;
    #[storage]
    struct Storage {
        #[substorage(v0)]
        src5: SRC5Component::Storage,
        #[substorage(v0)]
        erc721: ERC721Component::Storage,
        #[substorage(v0)]
        erc721_combo: ERC721ComboComponent::Storage,
    }
    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        SRC5Event: SRC5Component::Event,
        #[flat]
        ERC721Event: ERC721Component::Event,
        #[flat]
        ERC721ComboEvent: ERC721ComboComponent::Event,
    }
    //
    // ERC721 end
    //-----------------------------------

    use karat_gen2::models::token_config::{TokenConfig, TokenConfigTrait};
    use karat_gen2::models::seed::{Seed, SeedTrait};
    use karat_gen2::models::gen2::props::{Gen2Props, Gen2PropsTrait};
    use karat_gen2::systems::renderer::{Gen2RendererTrait};
    use karat_gen2::libs::store::{Store, StoreTrait};
    use karat_gen2::libs::dns::{SELECTORS};
    use karat_gen2::models::gen2::{constants};

    mod Errors {
        pub const CALLER_IS_NOT_OWNER: felt252      = 'KARAT: caller is not owner';
        pub const CALLER_IS_NOT_MINTER: felt252     = 'KARAT: caller is not minter';
    }

    fn dojo_init(ref self: ContractState,
        treasury_address: ContractAddress,
    ) {
        self.erc721_combo.initializer(
            constants::TOKEN_NAME(),
            constants::TOKEN_SYMBOL(),
            Option::None, // use hooks
            Option::None, // use hooks
            Option::Some(constants::MAX_SUPPLY),
        );
        self.erc721_combo._set_default_royalty(treasury_address, constants::DEFAULT_ROYALTY);
        // self.erc721_combo._set_minting_paused(true); // no need, using presale state
    }

    #[generate_trait]
    impl WorldDefaultImpl of WorldDefaultTrait {
        #[inline(always)]
        fn world_default(self: @ContractState) -> WorldStorage {
            (self.world(@"karat_gen2"))
        }
    }


    //-----------------------------------
    // ITokenPublic
    //
    #[abi(embed_v0)]
    impl ITokenPublicImpl of super::ITokenPublic<ContractState> {
        fn mint_next(ref self: ContractState, recipient: ContractAddress) -> u128 {
            let mut store: Store = StoreTrait::new(self.world_default());
            self._assert_caller_is_minter(@store);

            // mint
            let token_id: u128 = self.erc721_combo._mint_next(recipient).low;

            // generate seed
            let token_contract_address: ContractAddress = starknet::get_contract_address();
            let seed: Seed = SeedTrait::new(token_contract_address, token_id);
            store.set_seed(@seed);

            // event...
            store.emit_token_minted_event(token_contract_address, token_id, recipient, seed.seed);

            (token_id)
        }

        fn burn(ref self: ContractState, token_id: u256) {
            let owner: ContractAddress = self.owner_of(token_id);
            self.erc721.burn(token_id);
            // event...
            let mut store: Store = StoreTrait::new(self.world_default());
            store.emit_token_burned_event(starknet::get_contract_address(), token_id.low, owner);
        }

        // fn get_token_props(self: @ContractState, token_id: u128) -> Gen2Props {
        //     let mut store: Store = StoreTrait::new(self.world_default());
        //     let seed: Seed = store.get_seed(starknet::get_contract_address(), token_id);
        //     (seed.generate_props())
        // }

        fn get_token_svg(ref self: ContractState, token_id: u128) -> ByteArray {
            let mut store: Store = StoreTrait::new(self.world_default());
            let seed: Seed = store.get_seed(starknet::get_contract_address(), token_id);
            (Gen2RendererTrait::render_svg(@seed.generate_props()))
        }

        //
        // admin
        //
        fn set_paused(ref self: ContractState, is_paused: bool) {
            let mut store: Store = StoreTrait::new(self.world_default());
            self._assert_caller_is_minter(@store);
            self.erc721_combo._set_minting_paused(is_paused);
        }
        fn update_token_metadata(ref self: ContractState, token_id: u256) {
            // self._assert_caller_is_owner();
            self.erc721_combo._emit_metadata_update(token_id);
        }
        fn update_tokens_metadata(ref self: ContractState, from_token_id: u256, to_token_id: u256) {
            self._assert_caller_is_owner();
            self.erc721_combo._emit_batch_metadata_update(from_token_id, to_token_id);
        }
        fn update_contract_metadata(ref self: ContractState) {
            // self._assert_caller_is_owner();
            self.erc721_combo._emit_contract_uri_updated();
        }
    }


    //-----------------------------------
    // Internal
    //
    #[generate_trait]
    impl InternalImpl of InternalTrait {
        #[inline(always)]
        fn _assert_caller_is_owner(self: @ContractState) {
            assert(self._caller_is_owner(), Errors::CALLER_IS_NOT_OWNER);
        }
        #[inline(always)]
        fn _caller_is_owner(self: @ContractState) -> bool {
            (self.world_default().dispatcher.is_owner(SELECTORS::TOKEN, starknet::get_caller_address()))
        }
        #[inline(always)]
        fn _assert_caller_is_minter(self: @ContractState, store: @Store) {
            let token_contract_address: ContractAddress = starknet::get_contract_address();
            let config: TokenConfig = store.get_token_config(token_contract_address);
            assert(config.is_minter(starknet::get_caller_address()), Errors::CALLER_IS_NOT_MINTER);
        }
    }


    //-----------------------------------
    // ERC721ComboHooksTrait
    //
    pub impl ERC721ComboHooksImpl of ERC721ComboComponent::ERC721ComboHooksTrait<ContractState> {
        fn render_contract_uri(self: @ERC721ComboComponent::ComponentState<ContractState>) -> Option<ContractMetadata> {
            // https://docs.opensea.io/docs/contract-level-metadata
            let metadata = ContractMetadata {
                name: self.name(),
                symbol: self.symbol(),
                description: constants::METADATA_DESCRIPTION(),
                image: Option::Some(constants::CONTRACT_IMAGE()),
                banner_image: Option::Some(constants::BANNER_IMAGE()),
                featured_image: Option::None,
                external_link: Option::Some(constants::EXTERNAL_LINK()),
                collaborators: Option::None,
            };
            (Option::Some(metadata))
        }

        fn render_token_uri(self: @ERC721ComboComponent::ComponentState<ContractState>, token_id: u256) -> Option<TokenMetadata> {
            let self = self.get_contract(); // get the component's contract state
            let mut store: Store = StoreTrait::new(self.world_default());
            // gather data
            let seed: Seed = store.get_seed(starknet::get_contract_address(), token_id.low);
            let token_props: Gen2Props = seed.generate_props();
            let svg: ByteArray = Gen2RendererTrait::render_svg(@token_props);
            // return the metadata to be rendered by the component
            // https://docs.opensea.io/docs/metadata-standards#metadata-structure
            let metadata = TokenMetadata {
                token_id,
                name: format!("Karat II #{}", token_id.low),
                description: constants::METADATA_DESCRIPTION(),
                image: Option::Some(EncoderTrait::encode_svg(svg, true)),
                image_data: Option::None,
                external_url: Option::Some(constants::EXTERNAL_LINK()), // TODO: format external token link
                background_color: Option::Some("000000"),
                animation_url: Option::None,
                youtube_url: Option::None,
                attributes: Option::Some(token_props.attributes),
                additional_metadata: Option::None,
            };
            (Option::Some(metadata))
        }
    }

}
