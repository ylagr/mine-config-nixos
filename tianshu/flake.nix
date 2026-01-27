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

    emacs-overlay = {
      url = "github:nix-community/emacs-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # emacs-igc-overlay = {
    # url = "github:naveen-seth/emacs-igc-overlay"
    # inputs.nixpkgs.follows = "nixpkgs"
    # };
  };

  outputs = inputs@{ self, nixpkgs, nixos-wsl, nixos-hardware, home-manager, emacs-overlay, ... }:
    let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        config.allowUnfree = true;
        overlays = [ emacs-overlay.overlays.emacs ];
	      # overlays = [ emacs-igc-overlay.overlays.default ];
      };
    in
      {
        nixosConfigurations.wsl = let
	        username = "ylagr";
	      in
          nixpkgs.lib.nixosSystem {
	          system = "x86_64-linux";
	          specialArgs = {inherit inputs username;};
	          inherit pkgs;
	          modules = [
	            nixos-wsl.nixosModules.wsl
	            home-manager.nixosModules.home-manager
	            {
	              home-manager.useGlobalPkgs = true;
		            home-manager.useUserPackages = true;
		            home-manager.extraSpecialArgs = {inherit inputs;};
	              #	home-manager.users.${username}.imports = [
		            
	              #	];
	            }
	            ./hosts/wsl
	            ./home/tianshu.nix
	            
	          ];
	        };

        nixosConfigurations.x1c = nixpkgs.lib.nixosSystem {
          inherit pkgs;
          modules = [
            home-manager.nixosModules.home-manager
            ./hosts/x1c.nix
            ./home/tianshu.nix
          ];
        };

        nixosConfigurations.desktop = nixpkgs.lib.nixosSystem {
          inherit pkgs;
          modules = [
            home-manager.nixosModules.home-manager
            ./hosts/desktop.nix
            ./home/tianshu.nix
          ];
        };
      };
}
