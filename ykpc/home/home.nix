{ config, home-manager, username, homedir, pkgs, pkgs-new, pkgs-sys, ...}:
{

  home.username = "${username}";
  home.homeDirectory = "${homedir}";
  xdg.enable = true;

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [
    # enable dingtalk can use
    "openssl-1.1.1w"
  ];
  home.packages = with pkgs;[
    gearlever #appimage管理工具
    # warehouse #flatpak gui #无法识别flatpak
    # thunderbird
    virtualbox
    freerdp
    (makeDesktopItem {
    name = "Winboat-RDP";
    desktopName = "Winboat Remote Desktop";
    genericName = "Remote Desktop Client";
    # 注意：Wayland 下全屏建议加上 /f
    exec = "${freerdp}/bin/wlfreerdp /v:127.0.0.1:47300 /u:suiwp /p:suiwp +clipboard /dynamic-resolution";
    icon = "rdp"; # 或者指定一个本地图标路径
    terminal = false;
    categories = [ "Network" "RemoteAccess" ];
    comment = "Connect to Winboat via wlfreerdp";
  })
    winboat
    nur.repos.xddxdd.dingtalk
  ];

  home.stateVersion = "25.11";
  
}





























  
