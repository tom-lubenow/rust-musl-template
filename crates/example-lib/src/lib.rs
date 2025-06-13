pub fn greet(name: &str) -> String {
    format!("Hello, {}!", name)
}

#[no_mangle]
pub extern "C" fn hello_from_rust() -> *const u8 {
    b"Hello from Rust static library!\0".as_ptr()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_greet() {
        assert_eq!(greet("World"), "Hello, World!");
    }
}