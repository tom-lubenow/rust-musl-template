# Rust MUSL Template

A Nix flake template for building statically linked Rust binaries and libraries using MUSL.

## Features

- Cargo workspace setup
- MUSL toolchain for static linking
- Cross-compilation support (x86_64 and aarch64)
- Example binary and library crates
- Development shell with Rust tooling

## Usage

### Development Shell

Enter the development environment:

```bash
nix develop
```

This provides:
- Rust toolchain with MUSL target
- cargo-watch for auto-rebuilding
- rust-analyzer for IDE support
- Proper environment variables for static linking

### Building

On macOS (cross-compilation with cargo-zigbuild):

```bash
# Enter development shell
nix develop

# Build for aarch64 Linux MUSL
cargo zigbuild --release --target aarch64-unknown-linux-musl

# Build for x86_64 Linux MUSL
cargo zigbuild --release --target x86_64-unknown-linux-musl
```

On Linux (native compilation):

```bash
# Enter development shell
nix develop

# Build for native architecture
cargo build --release
```

Using Nix directly:

```bash
# Build default package
nix build

# Cross-compile for specific targets
nix build '.#cross-x86_64-linux'
nix build '.#cross-aarch64-linux'
```

### Verify Static Linking

Check that binaries are statically linked:

```bash
# On Linux
ldd result/bin/example-bin
# Should output: "not a dynamic executable"

# On macOS (for Linux binaries)
file result/bin/example-bin
# Should show: "statically linked"
```

## Structure

```
.
├── Cargo.toml          # Workspace configuration
├── flake.nix           # Nix flake with MUSL toolchain
├── crates/
│   ├── example-bin/    # Example binary crate
│   └── example-lib/    # Example library crate
└── rust-toolchain.toml # Rust version pinning
```

## Customization

To use this template for your project:

1. Update workspace members in `Cargo.toml`
2. Replace example crates with your own
3. Modify `flake.nix` if you need additional dependencies
4. Update package metadata in workspace configuration

## Notes

- Static binaries will be larger than dynamically linked ones
- Some crates may require additional configuration for static linking
- Cross-compilation from macOS uses Linux toolchains via Nix