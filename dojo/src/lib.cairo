mod systems {
    pub mod main;
}
mod libs {
    pub mod dns;
    pub mod misc;
}

#[cfg(test)]
mod tests {
    pub mod test_main;
    pub mod tester;
}
