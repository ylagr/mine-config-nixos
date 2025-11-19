# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:
let
  originalQQ = pkgs.qq;
  qqWrapper = pkgs.writeShellScriptBin "qq" ''
    export QT_IM_MODULE=fcitx
    export GTK_IM_MODULE=fcitx
    export XMODIFIERS='@im=fcitx'
    rm -rf ~/.config/QQ/versions
    exec ${originalQQ}/bin/qq "$@"
  '';
  librime-lua5_3_compat = pkgs.librime-lua.override {
    lua = pkgs.lua5_3_compat;
  };
  # librime-with-lua5_3_compat = pkgs.librime.overrideAttrs (oldAttrs: {
    # buildInputs = (oldAttrs.buildInputs or []) ++ [ librime-lua5_3_compat ];
  # });
  librime-with-lua5_3_compat = pkgs.librime.override {
    librime-lua = librime-lua5_3_compat;
  };
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.windows = {
    "nvme0n1p3" = {
      title = "window";
      efiDeviceHandle = "BLK3";
    };

  };
  # support graphic
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    # ⚠️ 关键！
  };
  # 启用 OpenGL（32 位 + 64 位）
  # hardware.opengl = {
  #   enable = true;
  #   driSupport = true;
  #   driSupport32Bit = true;
  #   # ⚠️ 关键！Steam 是 32 位应用
  # };
  # Enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.substituters = [ 
    "https://mirrors.ustc.edu.cn/nix-channels/store"
    "https://mirror.sjtu.edu.cn/nix-channels/store"
    "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store" 
    "https://cache.nixos.org/"
  ];
  #emacs-overlay = {
  #   url = "github:nix-community/emacs-overlay";
  #   inputs.nixpkgs.follows = "nixpkgs";
  # };
  #pkgs.overlays = [
  #	emacs-overlay.overlays.emacs
  #];

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Shanghai";

  # Select internationalisation properties.
  i18n.defaultLocale = "zh_CN.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "zh_CN.UTF-8";
    LC_IDENTIFICATION = "zh_CN.UTF-8";
    LC_MEASUREMENT = "zh_CN.UTF-8";
    LC_MONETARY = "zh_CN.UTF-8";
    LC_NAME = "zh_CN.UTF-8";
    LC_NUMERIC = "zh_CN.UTF-8";
    LC_PAPER = "zh_CN.UTF-8";
    LC_TELEPHONE = "zh_CN.UTF-8";
    LC_TIME = "zh_CN.UTF-8";
  };

  i18n.inputMethod = {
    type = "fcitx5";
    enable = true;
    fcitx5.waylandFrontend = true;
    fcitx5.addons = with pkgs; [
      rime-data
      (fcitx5-rime.override{librime=librime-with-lua5_3_compat;})
      fcitx5-gtk
    ];
  };
  

  documentation = {
    dev.enable = true;
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
  # 貌似是给托盘图标提供服务
  services.udev.packages = with pkgs; [ gnome-settings-daemon ];
  
  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "cn";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  security.sudo = {
  	enable = true;
  	execWheelOnly = false;
  	wheelNeedsPassword = false;
  };
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;
  virtualisation.waydroid.enable = true;
  # enable kvm
  programs.virt-manager.enable = true;
  
  virtualisation.libvirtd.enable = true;
  # 启用 ARM 转译（Houdini）  
  #virtualisation.waydroid.enableHoudini = true;
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    # 基础 C 库
    glibc
    # Java 通常还需要这些
    zlib
    xorg.libX11
    xorg.libXext
    xorg.libXrender
    xorg.libXtst
    xorg.libXi
    alsa-lib
    e2fsprogs
    freetype
    fontconfig    # 如果用 GUI 或 AWT/Swing，可能还需要更多
  ];

  programs.gamescope = {
    enable = true;
    capSysNice = true;
  };
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.suiwp = {
    isNormalUser = true;
    description = "suiwp";
    extraGroups = [ "networkmanager" "wheel" "cdrom" "disk" "libvirtd" "kvm" "video" "audio" ];
    packages = with pkgs; [
      # gamescope
      wl-clipboard # 解决剪贴板问题
      gpaste
      multimarkdown
      nix-tree
      chezmoi
      logseq
      kitty
      wemeet
      virtiofsd # 解决kvm虚拟机挂载目录问题
      lazarus
      siyuan
      pnpm
      nodejs_24
      helix
      brasero
      #  thunderbird
      jetbrains.idea-ultimate
      jdk8
      telegram-desktop
      onedrive
      wpsoffice-cn
      fastfetch
      steam
      podman-compose
      wechat
      appimage-run
      gopeed
      kdePackages.kdeconnect-kde
      waydroid
      waydroid-helper
      android-tools
      qqWrapper
      emacs-pgtk
      podman-tui
      # gifgen    #这个是转换的工具，不是实时录制
      snipaste
      (flameshot.override { enableWlrSupport = true; })
      # support both 32-bit and 64-bit applications
      wineWowPackages.stable
      wineWowPackages.waylandFull
      # support 32-bit only
      #wine

      # support 64-bit only
      #(wine.override { wineBuild = "wine64"; })

      # support 64-bit only
      #wine64

      # wine-staging (version with experimental features)
      #wineWowPackages.staging

      # winetricks (all versions)
      winetricks

      # native wayland support (unstable)
      #wineWowPackages.waylandFull
      samba
    ];
  };
  
  environment.variables = {    
	  QT_IM_MODULE = "fcitx";
    # 通常，为了确保 fcitx 正常工作，建议同时设置以下变量：  
	  GTK_IM_MODULE = "fcitx";
	  XMODIFIERS = "@im=fcitx";  
  };
  #programs.emacs = {
  #  enable = false;
  #  package = pkgs.emacs-igc-pgtk.pkgs.withPackages (epkgs: with epkgs; [ 
  # (eaf.withApplications [ eaf-browser eaf-pdf-viewer ])
  #    telega
  #    rime
  #  ]);
  #};
  virtualisation.containers.enable = true;
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };
  # Install firefox.
  programs.firefox.enable = true;
  qt = {
    enable = true;	#source value is true	#comment by ylagr
    style = "kvantum";
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    #  wget
    # 光盘刻录
    kdePackages.k3b
    cdrtools
    xorriso
    dvdplusrwtools
    udftools
    # 光盘刻录end
    uv
    opencc
    gnumake
    git
    net-tools
    vim
    btop
    wget
    bash-completion
    tree
    # waybar
    fuzzel
    #不兼容#gnomeExtensions.workspace-buttons-with-app-icons
    gnomeExtensions.worksets
    gnomeExtensions.window-title-is-back
    #不兼容#gnomeExtensions.window-list-in-panel
    gnomeExtensions.workspaces-indicator-by-open-apps
    #和window-list重复#gnomeExtensions.workspace-indicator
    gnomeExtensions.window-list
    gnomeExtensions.kimpanel
    gnomeExtensions.appindicator
    gnomeExtensions.indicator
    gnomeExtensions.fuzzy-app-search
    gnome-extension-manager
    subversion
    home-manager
    looking-glass-client
  ] ++ (with gnomeExtensions; [
    dash-to-dock
    night-theme-switcher
    clipboard-history
    # gnome-shell-extension-desktop-icons
    gsconnect
  ]);
  
  # Nekoray VPN
  programs.nekoray = {
    enable = false;  #source value is true	#comment by ylagr
    tunMode.enable = true;  #source value is true	 #comment by ylagr
  };
  programs.clash-verge = {
  	enable = true;
	  autoStart = true;
	  serviceMode = true;
  }; 
  programs.niri.enable = true;
  fonts.packages = with pkgs; [
    font-awesome
    adwaita-fonts
    noto-fonts
    ubuntu_font_family
    #nerd-fonts.arimo
    wqy_microhei
    noto-fonts-color-emoji
    # noto-fonts-cjk-sans
    # noto-fonts-cjk-serif
    nerd-fonts.bigblue-terminal
    # babelstone-han
    nerd-fonts.symbols-only
    unifont
  ];
  fonts.fontconfig = {
    enable = true;
    # 启用抗锯齿、自动微调、子像素渲染（LCD 屏）
    antialias = true;
    hinting = {
      enable = true;
      style = "slight";  # 可选: "none", "slight", "medium", "full"
    };
    # subpixel = {
    # rgba = "rgb";  # 通常为 "rgb"，若字体发彩边可试 "none"
    # enable = true;
    # };
    defaultFonts = {
      sansSerif = [ "WenQuanYi Micro Hei"];
      monospace = [ "ubuntu mono" "unifont" "WenQuanYi Micro Hei" ];
      serif = ["WenQuanYi Micro Hei"];
    };
  };
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };
  #programs.jetbrains.idea-ultimate = {
  #	enable = true;
  #};
  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?

}



  
