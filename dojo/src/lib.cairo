mod systems {
    pub mod token;
    pub mod minter;
    pub mod renderer;
}
mod models {
    pub mod events;
    pub mod seed;
    pub mod token_config;
    pub mod gen2 {
        pub mod constants;
        pub mod props;
        pub mod class;
        pub mod palette;
    }
}
mod interfaces {
    pub mod ierc20;
    pub mod ierc721;
}
mod libs {
    pub mod dns;
    pub mod store;
}
mod utils {
    pub mod hash;
    pub mod math;
    pub mod misc;
    pub mod short_string;
}

#[cfg(test)]
mod tests {
    pub mod tester;
    pub mod test_token;
    pub mod test_minter;
    pub mod mock_coin;
    pub mod mock_token;
}
