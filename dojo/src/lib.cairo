mod systems {
    pub mod token;
    pub mod minter;
    pub mod renderer;
}
mod models {
    pub mod class;
    pub mod constants;
    pub mod events;
    pub mod seed;
    pub mod token_config;
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
    pub mod misc;
}

#[cfg(test)]
mod tests {
    pub mod tester;
    pub mod test_token;
    pub mod test_minter;
    pub mod mock_coin;
    pub mod mock_token;
}
