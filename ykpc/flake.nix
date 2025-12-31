
{
  description = "NixOS flake-configuration with Noctalia";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
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


  outputs = inputs@{ self, nixpkgs, emacs-overlay, chinese-fonts-overlay, nixpkgs-new,  ... }:
    let
      system = "x86_64-linux";
      pkgs-new = import inputs.nixpkgs-new {
        config.allowUnfree = true;
        inherit system;
        overlays = [emacs-overlay.overlays.emacs];
      };
      pkgs = import inputs.nixpkgs {
        config.allowUnfree = true;
        inherit system;
        overlays = [chinese-fonts-overlay.overlays.default];
      };
      # inputs.nixpkgs.overlays = ( inputs.nixpkgs.overlays or [] ) ++ ([inputs.chinese-fonts-overlay.overlays.default]);
      # nixpkgs-new-unfree = import inputs.nixpkgs-new {
      # config.allowUnfree = true;
      # inherit system;
      # overlays = [
      # inputs.nur.overlay
      # ];
      # };
    in {
      nixosConfigurations = {
        nixos = let
          system = "x86_64-linux";
        in nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit system inputs pkgs-new pkgs;
            
            # pkgs-new = import inputs.nixpkgs-new {
            #   config.allowUnfree = true;
            #   inherit system;
            #   overlays = [emacs-overlay.overlays.emacs];
            # };
          };
          modules = [
            ./host/ykworkpc/configuration.nix
            ./noctalia.nix
            # ({ config, lib, ... }: {   _module.args.pkgs-new = pkgs-new;})

          ];
        };
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
