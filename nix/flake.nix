#
# git clone https://github.com/zs-dima/fresh.git ~/fresh
# cd ~/fresh/nix
# home-manager switch --flake . --impure
# wsl --shutdown
#
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    neovim.url = "github:purplenoodlesoop/neovim";
  };

  outputs = { nixpkgs, home-manager, neovim, ... }:
    let
      system = builtins.currentSystem;
      pkgs = nixpkgs.legacyPackages.${system};
      isDarwin = builtins.match ".*darwin" system != null;
      username = builtins.getEnv "USER";
    in {
      homeConfigurations.${username} = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          neovim.homeManagerModules.default
          {
            home.username = username;
            home.homeDirectory = if isDarwin then "/Users/${username}" else "/home/${username}";
            home.stateVersion = "24.11";
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
            home.packages = with pkgs; [
              git gh jq eza bat fd ripgrep lazygit fzf
            ];

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

            # ── Chrome ──
            home.sessionVariables = {
              CHROME_EXECUTABLE =
                if isDarwin
                then "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
                else "/mnt/c/Program Files/Google/Chrome/Application/chrome.exe";
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

            programs.lazyvim.extras.lang.rust = {
              enable = true;
              installDependencies = true;
            };
          }
        ];
      };
    };
}