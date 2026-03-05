
{
  nixConfig = {
    extra-substituters = [ "https://nix-community.cachix.org" ];
    extra-trusted-public-keys = [ "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="];
    
  };
  # description = "NixOS flake-configuration with Noctalia";
  inputs = {
    # nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-sys.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    quickshell = {
      url = "github:outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.quickshell.follows = "quickshell";
    };
    nixpkgs-new = {
      url =  "github:nixos/nixpkgs/nixos-unstable";
      
    };
    nur = {
      url = "github:nix-community/nur";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      # url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

      # 添加这一行
    nix-alien = {
      url = "github:thiagokokada/nix-alien";
      inputs.nixpkgs.follows = "nixpkgs";
    };
        
    emacs-overlay = {
      url = "github:nix-community/emacs-overlay";
      inputs.nixpkgs.follows = "nixpkgs-new";
      inputs.nixpkgs-stable.follows = "nixpkgs-new";
    };
    chinese-fonts-overlay = {
      url = "github:brsvh/chinese-fonts-overlay/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # ➕ 添加 NUR
    # nur = {
    # url =  "github:nix-community/NUR";
    # inputs.nixpkgs.follows = "nixpkgs";
    # };
  }; 


  outputs = inputs@{ self, nixpkgs-stable, nixpkgs,nixpkgs-sys, home-manager, emacs-overlay, chinese-fonts-overlay, nixpkgs-new, nur,  ... }:
    let
      system = "x86_64-linux";
      # pkgs = import inputs.nixpkgs-stable {
      pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [nur.overlays.default];
      };
      pkgs-new = import inputs.nixpkgs-new {
        config.allowUnfree = true;
        inherit system;
        overlays = [emacs-overlay.overlays.emacs];
      };
      pkgs-sys = import inputs.nixpkgs-sys {
        config.allowUnfree = true;
        inherit system;
        overlays = [chinese-fonts-overlay.overlays.default];
      };
      pkgs-stable = import inputs.nixpkgs-stable {
        config.allowUnfree = true;
        inherit system;
      };

      
      # inputs.nixpkgs.overlays = ( inputs.nixpkgs.overlays or [] ) ++ ([inputs.chinese-fonts-overlay.overlays.default]);
      # nixpkgs-new-unfree = import inputs.nixpkgs-new {
      # config.allowUnfree = true;
      # inherit system;
      # overlays = [
      # inputs.nur.overlay
      # ];
      # };
      suiwp = "suiwp";
      suiwphome = "/home/${suiwp}";
    in {
      nix.settings.experimental-features = [ "nix-command" "flakes" ];
      # packages.${system}.sys = pkgs-sys;
      legacyPackages.${system}.sys = pkgs-sys;
      nixosConfigurations = {
        nixos = let
          system = "x86_64-linux";
          username = suiwp;
          homedir = suiwphome;
        in nixpkgs.lib.nixosSystem {
          inherit system pkgs;
          specialArgs = {
            inherit system inputs pkgs-new pkgs-sys pkgs-stable username homedir;
            
            # pkgs-new = import inputs.nixpkgs-new {
            #   config.allowUnfree = true;
            #   inherit system;
            #   overlays = [emacs-overlay.overlays.emacs];
            # };
          };
          modules = [
            ./host/ykworkpc/configuration.nix
            ./module/font-plangothic.nix
            ./module/font-iosevkaylagr-1.1.0.nix
            ./module/nix-alien.nix
            # ./noctalia.nix
            # home-manager.nixosModules.home-manager
            # {
            #   home-manager.useUserPackages = true;
            #   home-manager.useGlobalPkgs = true;
            #   home-manager.extraSpecialArgs = {inherit inputs pkgs-new pkgs-sys;};
            # }
            # ({ config, lib, ... }: {   _module.args.pkgs-new = pkgs-new;})

          ];
        };
        
      };
      home-manager.userUserpackages = true;
      home-manager.useGlobalPkgs = true;
      homeConfigurations.suiwp =
          let
            username = suiwp;
            homedir = suiwphome;
          in
            home-manager.lib.homeManagerConfiguration {
              inherit pkgs;
              extraSpecialArgs = { inherit inputs username homedir pkgs-new pkgs-sys; };
              modules = [
                ./home/home.nix
              ];
            };
      # nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      #   # system = "x86_64-linux";
      #   inherit system ;
      #   specialArgs = {
      #     inherit inputs;
      #     # pkgs-new = nixpkgs-new-unfree.legacyPackages.${system};
      #     pkgs-new = nixpkgs-new-unfree;
      #   };
      #   modules = [
      #     ./host/ykworkpc/configuration.nix
      
      #     ./noctalia.nix
      #     # ./chinese.nix
      #   ];
      # }; 
    };
}
