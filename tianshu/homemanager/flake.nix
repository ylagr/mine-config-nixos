{
  nixConfig = {
    experimental-features = [ "nix-command" "flakes" ];
    substituters = [
      # replace official cache with a mirror located in China
      "https://mirrors.ustc.edu.cn/nix-channels/store"
      "https://cache.nixos.org/"
    ];

    # nix community's cache server
    extra-substituters = [
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nixos-wsl = {
    	url = "github:nix-community/NixOS-WSL";
    	inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-utils.url = "github:numtide/flake-utils";
    
    emacs-overlay = {
      url = "github:nix-community/emacs-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # emacs-igc-overlay = {
    # url = "github:naveen-seth/emacs-igc-overlay"
    # inputs.nixpkgs.follows = "nixpkgs"
    # };
  };

  outputs = inputs@{ self, nixpkgs, flake-utils, nixos-wsl, nixos-hardware, home-manager, emacs-overlay, ... }:
    flake-utils.lib.eachDefaultSystemPassThrough (sys:
      let
        pkgs = import nixpkgs {
          # system = "x86_64-linux";
          system = sys;
          
          config.allowUnfree = true;
          overlays = [ emacs-overlay.overlays.emacs ];
	        # overlays = [ emacs-igc-overlay.overlays.default ];
        };
        
      in {
        home-manager.useUserPackages = true;
        nix.settings.experimental-features = [ "nix-command" "flakes" ];
        homeConfigurations.ylagr = 
          let
            username = "ylagr";
            homedir  = "/home/ylagr";
          in
            
            home-manager.lib.homeManagerConfiguration {
              inherit pkgs;
              extraSpecialArgs = { inherit inputs username homedir; };
              modules = [
                # ../home/tianshu.nix
                ../home/ylagr.nix 
                
                
              ];
              
            };
      }
    );
}
