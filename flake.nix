{
  description = "Rust MUSL template for static binaries";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
    naersk = {
      url = "github:nix-community/naersk";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, fenix, flake-utils, naersk }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        
        # Get the Rust toolchain
        toolchain = with fenix.packages.${system};
          combine [
            stable.rustc
            stable.cargo
            stable.clippy
            stable.rustfmt
            stable.rust-src
            targets.x86_64-unknown-linux-musl.stable.rust-std
            targets.aarch64-unknown-linux-musl.stable.rust-std
          ];

        # Build for native MUSL target
        muslTarget = 
          if system == "x86_64-linux" then "x86_64-unknown-linux-musl"
          else if system == "aarch64-linux" then "aarch64-unknown-linux-musl"
          else if system == "x86_64-darwin" then "x86_64-unknown-linux-musl"
          else if system == "aarch64-darwin" then "aarch64-unknown-linux-musl"
          else throw "Unsupported system: ${system}";

        # Naersk lib with our toolchain
        naersk-lib = naersk.lib.${system}.override {
          cargo = toolchain;
          rustc = toolchain;
        };

        # Build configuration for static linking
        buildInputs = with pkgs; [
          pkgsStatic.stdenv.cc
        ];

        nativeBuildInputs = with pkgs; [
          pkg-config
          toolchain
        ];

      in
      {
        # Development shell
        devShells.default = pkgs.mkShell {
          inherit nativeBuildInputs;
          buildInputs = buildInputs ++ (with pkgs; [
            cargo-watch
            cargo-edit
            rust-analyzer
            zig
            cargo-zigbuild
          ]);

          RUST_BACKTRACE = 1;
          
          shellHook = ''
            echo "Rust MUSL development environment"
            echo "Platform: ${system}"
            echo "Target: ${muslTarget}"
            
            if [[ "${system}" == *"darwin"* ]]; then
              echo "Using cargo-zigbuild for cross-compilation from macOS"
              echo ""
              echo "Build commands:"
              echo "  cargo zigbuild --release --target aarch64-unknown-linux-musl"
              echo "  cargo zigbuild --release --target x86_64-unknown-linux-musl"
              echo ""
              echo "Note: First build may take time while Zig downloads required files"
            else
              export CARGO_BUILD_RUSTFLAGS="-C target-feature=+crt-static -C link-args=-static"
              echo ""
              echo "Build command:"
              echo "  cargo build --release"
            fi
          '';
        };

        # Package builder function
        packages = {
          # Build all workspace members
          default = naersk-lib.buildPackage {
            src = ./.;
            doCheck = true;
            copyLibs = true;
            
            CARGO_BUILD_TARGET = muslTarget;
            CARGO_BUILD_RUSTFLAGS = "-C target-feature=+crt-static -C link-args=-static";
            
            nativeBuildInputs = nativeBuildInputs;
            buildInputs = buildInputs;
          };
        };

        # Cross-compilation targets
        packages.cross-x86_64-linux = naersk-lib.buildPackage {
          src = ./.;
          CARGO_BUILD_TARGET = "x86_64-unknown-linux-musl";
          CARGO_BUILD_RUSTFLAGS = "-C target-feature=+crt-static -C link-args=-static";
          
          nativeBuildInputs = nativeBuildInputs;
          buildInputs = buildInputs;
        };

        packages.cross-aarch64-linux = naersk-lib.buildPackage {
          src = ./.;
          CARGO_BUILD_TARGET = "aarch64-unknown-linux-musl";
          CARGO_BUILD_RUSTFLAGS = "-C target-feature=+crt-static -C link-args=-static";
          
          nativeBuildInputs = nativeBuildInputs;
          buildInputs = buildInputs;
        };
      });
}
