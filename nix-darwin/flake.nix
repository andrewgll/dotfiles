{
  description = "MraNano config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager = {
	url = "github:nix-community/home-manager";
        inputs.nixpkgs.follows = "nixpkgs";
	};
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, home-manager }:
  let
    configuration = { pkgs, ... }: {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages = with pkgs;
        [
	vim
	htop
	neovim
	oh-my-zsh
	git
	yabai
	skhd
        
];

      # Auto upgrade nix package and the daemon service.
      services.nix-daemon.enable = true;
      # nix.package = pkgs.nix;

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Create /etc/zshrc that loads the nix-darwin environment.
      programs.zsh.enable = true;  # default shell on catalina
      # programs.fish.enable = true;
      
      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

   
      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 5;
      
      services.yabai.enable = true;
      services.skhd.enable = true;

   
      # The platform the configuration will be used on.

      nixpkgs.hostPlatform = "aarch64-darwin";
      security.pam.enableSudoTouchIdAuth = true;

      nix.useDaemon = true;
      nix.configureBuildUsers = true;

      system.defaults = {
	NSGlobalDomain.AppleICUForce24HourTime = true;
      	NSGlobalDomain.AppleKeyboardUIMode = 3;
        NSGlobalDomain.AppleShowAllExtensions = true;
        NSGlobalDomain.AppleShowAllFiles = true;
        NSGlobalDomain.NSAutomaticCapitalizationEnabled = true;
	NSGlobalDomain.NSDocumentSaveNewDocumentsToCloud = false;
	
      };
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#Mrs-MacBook-Pro
    darwinConfigurations."Nano" = nix-darwin.lib.darwinSystem {
      modules = [ configuration ];
    };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."Nano".pkgs;
  };
}
