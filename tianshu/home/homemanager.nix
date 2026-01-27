{ config, home-manager, pkgs, ... }:
{
  home-manager.useUserPackages = true;
  home-manager.users.ylagr = import ./ylagr.nix {
    username = "ylagr";
    homedir = "/home/ylagr";
  };
}
