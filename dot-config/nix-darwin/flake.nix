{
  description = "Patrick's nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    mac-app-util.url = "github:hraban/mac-app-util";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew, mac-app-util,... }:
  let
    configuration = { pkgs, config, ... }: {

      nixpkgs.config.allowUnfree = true;

      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages =
        [ 
            # Ansible - Configuration management tool
            pkgs.ansible
            # Azure CLI - Next generation multi-platform command line experience for Azure
            pkgs.azure-cli
            # Rust build tool
            pkgs.cargo
            # GNU coreutils - the ones that come with MacOS are outdated
            pkgs.coreutils
            # Feh lightweight image viewer
            # Used for displaying PlantUML diagrams
            pkgs.feh
            # Simple, fast and user-friendly alternative to find
            pkgs.fd
            # Fast Node Manager - Fast and simple Node.js version manager
            pkgs.fnm
            # fzf - Command-line fuzzy finder
            pkgs.fzf
            # Ghostty Terminal Emulator
            # This package in version 1.1.3 is currently broken. For now I use homebrew.
            # pkgs.ghostty
            # Git - Distributed version control tool
            pkgs.git
            # Git extension for versioning large files
            pkgs.git-lfs
            # GNU Privacy Guard
            # e.g., used to sign git commits
            pkgs.gnupg
            # Google Cloud SDK - GCP command line utilities
            pkgs.google-cloud-sdk
            # Go programming language
            pkgs.go
            # Software suite to create, edit, compose, or convert bitmap images
            # Needed for some Neovim plugins
            pkgs.imagemagick
            # jq commandline JSON parser
            pkgs.jq
            # kubectl - kubernetes CLI
            pkgs.kubectl
            # Fast way to switch between clusters and namespaces in kubectl
            pkgs.kubectx
            # Kubernetes credential plugin implementing Azure authentication
            pkgs.kubelogin
            # Helm - Package manager for Kubernetes
            pkgs.kubernetes-helm
            # Simple terminal UI for git commands 
            pkgs.lazygit
            # LogSeq PKM tool
            pkgs.logseq
            # Quick'n'dirty tool to make APFS aliases
            # Used for making GUI apps installed with nix available in Spotlight search
            pkgs.mkalias
            # Build automation tool (used primarily for Java projects) 
            pkgs.maven
            # Mac App Store command line interface
            pkgs.mas
            # Tool that makes it easy to run Kubernetes locally
            pkgs.minikube
            # NeoVim - Text editor
            pkgs.neovim
            # Obsidian PKM tool
            pkgs.obsidian
            # Prompt theme engine for any shell
            pkgs.oh-my-posh
            # PlantUML diagrams-as-code tool
            pkgs.plantuml
            # prettier as a daemon, for improved formatting speed
            pkgs.prettierd
            # Utility that combines the usability of The Silver Searcher with the raw speed of grep
            # Needed by NeoVim plugins
            pkgs.ripgrep
            # Fast incremental file transfer utility
            pkgs.rsync
            # Easy and Repeatable Kubernetes Development
            pkgs.skaffold
            # smartmontools - Tools for monitoring the health of hard drives
            pkgs.smartmontools
            # stow symlink farm manger
            # Used for my dotfiles
            pkgs.stow
            # Adoptium Temurin OpenJDK 23
            pkgs.temurin-bin-23
            # tenv - OpenTofu, Terraform, Terragrunt and Atmos version manager written in Go 
            pkgs.tenv
            # Command to produce a depth indented directory listing 
            pkgs.tree
            # Visual Studio Code
            pkgs.vscode
            # Tool for retrieving files using HTTP, HTTPS, and FTP
            pkgs.wget
            # Fast cd command that learns your habits
            pkgs.zoxide
        ];

      fonts.packages = [
          pkgs.nerd-fonts.fira-code
        ]; 

      homebrew = {
          enable = true;
          casks = [
            "ghostty" # Replace with nix package as soon as it is fixed
            "gpg-suite"
            "nextcloud"
            "onedrive"
            "setapp"
            "signal"
            "veracrypt"
            "zen"
          ];
          masApps = {
            "Daisydisk" = 411643860;
            "Pixea" = 1507782672;
            "Magnet" = 441258766;
            "Bitwarden" = 1352778147;
          };
          onActivation.cleanup = "zap";
          onActivation.autoUpdate = true;
          onActivation.upgrade = true;
        };

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Enable alternative shell support in nix-darwin.
      # programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 6;

      system.primaryUser = "patrick.podbregar";

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";

    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#macbookbe
      darwinConfigurations = {
        "ATGRZM4042139B" = nix-darwin.lib.darwinSystem {
          modules = [
            configuration
            mac-app-util.darwinModules.default
            nix-homebrew.darwinModules.nix-homebrew
            {
              nix-homebrew = {
                # Install Homebrew under the default prefix
                enable = true;

                # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
                enableRosetta = true;

                # User owning the Homebrew prefix
                user = "patrick.podbregar";

              };
            }
          ];
        };
      };
  };
}
