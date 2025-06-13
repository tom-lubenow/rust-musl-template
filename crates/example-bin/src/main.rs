use example_lib::greet;
use serde::{Deserialize, Serialize};

#[derive(Debug, Serialize, Deserialize)]
struct Message {
    text: String,
    timestamp: u64,
}

fn main() {
    println!("{}", greet("MUSL Static Binary"));
    
    let msg = Message {
        text: "Hello from statically linked Rust!".to_string(),
        timestamp: 1234567890,
    };
    
    match serde_json::to_string_pretty(&msg) {
        Ok(json) => println!("\nJSON output:\n{}", json),
        Err(e) => eprintln!("Failed to serialize: {}", e),
    }
    
    println!("\nThis binary is statically linked with MUSL!");
}