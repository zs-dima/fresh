#
# git clone https://github.com/zs-dima/fresh.git ~/fresh
# cd ~/fresh/nix
# home-manager switch --flake . --impure
# wsl --shutdown
#
{
  description = "Cross-platform development environment";

  nixConfig = {
    extra-substituters = [ "https://nix-community.cachix.org" ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    neovim = {
      url = "github:purplenoodlesoop/neovim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, neovim, fenix, ... }:
    let
      system = builtins.currentSystem;
      pkgs = nixpkgs.legacyPackages.${system};
      isDarwin = pkgs.stdenv.isDarwin;
      username = builtins.getEnv "USER";

      rustToolchain = fenix.packages.${system}.stable.withComponents [
        "cargo" "clippy" "rustc" "rustfmt" "rust-src" "rust-analyzer"
      ];
    in {
      homeConfigurations.${username} = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          neovim.homeManagerModules.default
          {
            home = {
              inherit username;
              homeDirectory = if isDarwin then "/Users/${username}" else "/home/${username}";
              stateVersion = "24.11";

              packages = with pkgs; [
                # CLI
                gh jq eza bat fd ripgrep lazygit

                # Build tools
                pkg-config cmake

                # Rust
                rustToolchain
                openssl.dev
                cargo-watch cargo-expand taplo

                # Dart
                dart
              ] ++ lib.optionals (!isDarwin) [
                # Flutter desktop (Linux)
                clang ninja xz
                gtk3 glib pcre2 util-linux libsecret jsoncpp
                xorg.libX11
              ];

              sessionVariables = {
                CHROME_EXECUTABLE =
                  if isDarwin
                  then "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
                  else "/mnt/c/Program Files/Google/Chrome/Application/chrome.exe";
              };
            };

            programs.home-manager.enable = true;

            # ── Shell ──
            programs.bash.enable = true;
            programs.zsh = {
              enable = true;
              autosuggestion.enable = true;
              syntaxHighlighting.enable = true;
              history.ignoreAllDups = true;
              shellAliases = {
                ls = "eza --long --all --no-permissions --no-filesize --no-user --no-time --git";
                cat = "bat --paging never --style plain";
              };
            };

            # ── Tools ──
            programs.fzf = {
              enable = true;
              enableZshIntegration = true;
              enableBashIntegration = true;
            };

            programs.direnv = {
              enable = true;
              nix-direnv.enable = true;
            };

            programs.starship = {
              enable = true;
              enableZshIntegration = true;
              enableBashIntegration = true;
            };
            xdg.configFile."starship.toml".source = ../.config/starship.toml;

            programs.zoxide = {
              enable = true;
              enableZshIntegration = true;
              enableBashIntegration = true;
            };

            programs.git = {
              enable = true;
              delta.enable = true;
            };

            # ── Neovim overrides ──
            programs.lazyvim.plugins.theme = pkgs.lib.mkForce ''
              return {
                {
                  "catppuccin/nvim",
                  name = "catppuccin",
                  lazy = false,
                  priority = 1000,
                  config = function()
                    require("catppuccin").setup({
                      flavour = "mocha",
                      color_overrides = {
                        mocha = {
                          base = "#000000",
                        },
                      },
                      integrations = {
                        cmp = true,
                        gitsigns = true,
                        neo_tree = true,
                        treesitter = true,
                        mini = { enabled = true },
                        indent_blankline = { enabled = true },
                        native_lsp = { enabled = true },
                      },
                    })
                    vim.cmd.colorscheme("catppuccin")
                  end,
                },
              }
            '';

            programs.lazyvim.extras.lang.rust.enable = true;
          }
        ];
      };

      formatter.${system} = pkgs.nixfmt-rfc-style;
    };
}
