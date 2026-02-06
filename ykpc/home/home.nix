{ config, home-manager, username, homedir, pkgs, pkgs-new, pkgs-sys, ...}:
{

  home.username = "${username}";
  home.homeDirectory = "${homedir}";
  xdg.enable = true;
  home.packages = with pkgs;[
    # thunderbird
  ];

  home.stateVersion = "25.11";
  
}
