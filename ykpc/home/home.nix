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
    # kdePackages.spectacle
    # kdePackages.dolphin  # 影响gopeed了
    super-productivity  # gtd soft
    nodenv # node manager version
    dbeaver-bin
    lazarus # Pascal编辑器
    pkgs-new.zed-editor
    peek
    zsh
    syncthing
    opencode
    claude-code
    lazyssh
    yazi
    termscp # 太卡了，试试lzsyssh  可能是网络导致的卡
    # gitstatus # 10x faster impl of `git status` command # 不能加速gitstatus命令，只能用于shell的prompt
    sublime-merge # git merge工具
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
    (makeDesktopItem {
    name = "dingtalk-x11";
    desktopName = "dingtalk-x11";
    genericName = "dingtalk-x11";
    # 注意：Wayland 下全屏建议加上 /f
    exec = "env GDK_BACKEND=x11 dingtalk %u";
    icon = "dingtalk"; # 或者指定一个本地图标路径
    terminal = false;
    keywords = ["dingtalk"];
    categories = [ "Chat" ];
    mimeTypes=["x-scheme-handler/dingtalk"];
    comment = "Dingtalk  work chat";
    type = "Application";
  })
  ];
  xfconf.settings = {
    xfce4-session = {
      # 有hyprlock的话
      # "general/LockCommand" = "hyprlock"; 用x11的话就不能用hyprlock了
      # "sessions/Failsafe/Client0_Command" = [ "openbox" ];
    };
  };

  home.stateVersion = "25.11";
  
}
