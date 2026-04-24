# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, pkgs-new, nixpkgs-new, pkgs-sys, pkgs-stable, username, homedir, inputs, pkgs-s, ... }:
let
  
  librime-lua-with-lua5_4_compat = pkgs.librime-lua.override {
    lua = pkgs.lua5_4_compat;
  };
  librime-with-lua5_4_compat = pkgs.librime.override {
    librime-lua =  librime-lua-with-lua5_4_compat;
  };
  fcitx5-rime-with-lua5_4_compat = pkgs.replaceDependencies{
    drv = pkgs.fcitx5-rime;
    replacements = [
      ({oldDependency = pkgs.librime; newDependency = librime-with-lua5_4_compat;})
    ];
  };
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.initrd.availableKernelModules = [ "usb_storage" "sd_mod" ];
  boot.kernelModules = [
    "kvm-intel"
    "pktcdvd"
    "kvmfr"
    "dm-mirror" # use to pvmove detact device-mapper target
    "dm-thin-pool" # use lvcreate --thin 创建快照
  ];
  boot.extraModulePackages = [
    config.boot.kernelPackages.kvmfr
  ];
  boot.extraModprobeConfig= ''
     options kvmfr static_size_mb=32
  '';
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.windows = {
    "nvme0n1p3" = {
      title = "window";
      efiDeviceHandle = "BLK1";
    };

  };
  boot.initrd.systemd.settings.Manager = {
    DefaultTimeoutStopSec="15s";
  };

  boot.initrd.services.lvm = {
    enable = true;
  };
  systemd.user.extraConfig = ''
    "DefaultTimeoutStartSec=15"
    "DefaultTimeoutStopSec=15"
'';
  # zram swap
  zramSwap.enable = true;
  
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
  # nix.package = pkgs-sys.nix;
  nix.settings.accept-flake-config = true;
  nix.settings.trusted-users = [ "root" "@wheel" ];
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.substituters = [ 
    "https://mirrors.ustc.edu.cn/nix-channels/store"
    "https://mirror.sjtu.edu.cn/nix-channels/store"
    "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store" 
    "https://cache.nixos.org/"
  ];
  # nix.registry = {
    # to enable command ~ nix profile add sys#pkgname ~
    # sys.flake = inputs.nixpkgs-sys;
    # s.flake = inputs.nixpkgs-s;
  # };
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
  # networking.networkmanager.enable = true;
  networking.networkmanager = {
    enable = true;
    plugins = with pkgs; [
      networkmanager-openvpn
    ];
  };

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
      # (fcitx5-rime.override{librime=librime-with-lua5_3_compat;})
      fcitx5-rime-with-lua5_4_compat
      # fcitx5-rime-lua5_3_compat
      # fcitx5-rime
      fcitx5-gtk
      kdePackages.fcitx5-qt
    ];
  };
  environment.etc."xdg/gtk-2.0/gtkrc".text = ''
    gtk-im-module="fcitx"

  '';
  environment.etc."xdg/gtk-3.0/settings.ini".text = ''
    [Settings]
    gtk-im-module=fcitx

  '';
  environment.etc."xdg/gtk-4.0/settings.ini".text = ''
    [Settings]
    gtk-im-module=fcitx

  '';
  # gtk-font-name = Sans Serif 12
  
  documentation = {
    dev.enable = true;
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # 貌似是给托盘图标提供服务
  # services.udev.packages = with pkgs; [ gnome-settings-daemon ];
  # Enable the GNOME Desktop Environment.
  #services.displayManager.gdm.enable = true;
  # services.desktopManager.gnome.enable = true;
  # 轻量替换gnome配套设施
  services.gnome.gnome-keyring.enable = true;
  services.upower.enable = true;  # 自动监控硬件相关
    # 启用 power-profiles-daemon
  services.power-profiles-daemon.enable = true; # 简单性能管理工具
  # programs.dconf.enable = false;
  security.pam.services.login.enableGnomeKeyring = true;

  services.udisks2.enable = true; #硬件发现

  # xfce 配套
  # 1. 启用 Xfconf 核心服务（解决 Thunar 设置和系统配置存储）
  programs.xfconf.enable = true;
  # 启用 GVfs 服务以支持网络挂载、垃圾桶等功能
  services.gvfs.enable = true;
  services.xserver.desktopManager.xfce = {
    enable = true;
    enableWaylandSession = true;
    # enableXfwm = false;
    enableXfwm = true;
    enableScreensaver = true;
  };
  # services.xserver.windowManager.openbox.enable = true;
  # services.gnome.evolution-data-server.enable = true;
  programs.evolution.enable = true;
  xdg = {
    # enable = true;
    # 强制让应用通过 Portal 交互
    
    portal = {
      enable = true;
      xdgOpenUsePortal = false;
      # wlr.enable = true;
      # lxqt.enable = true;
      extraPortals = [
        # pkgs.kdePackages.xdg-desktop-portal-kde
        pkgs.xdg-desktop-portal-gtk
        # pkgs.lxqt.xdg-desktop-portal-lxqt
        # pkgs.xdg-desktop-portal-wlr
      ];
      # config.common.default = "*";
      config.common = {
        default = [
          # "wlr"
          "gtk" "*" ];
        "org.freedesktop.impl.portal.FileChooser" = [
          # "wlr"
                                                      # "kde"
                                                      "gtk" "*" ];
        "org.freedesktop.impl.portal.OpenURI" = [
          # "wlr"
                                                  # "kde"
                                                  "gtk" "*"];
        # "org.freedesktop.impl.portal.FileChooser" = "lxqt";
        # "org.freedesktop.impl.portal.OpenURI" = "lxqt";
      };
      config.labwc = {
        "org.freedesktop.impl.portal.FileChooser" = [ "wlr"
                                                      # "kde"
                                                      "gtk" "*" ];
        "org.freedesktop.impl.portal.OpenURI" = [ "wlr"
                                                  # "kde"
                                                  "gtk" "*"];
      };
      
    };
    # 确保 PCManFM 被设置为目录类型的默认关联
    mime.defaultApplications = {
      # "inode/directory" = "pcmanfm.desktop";
    };
  };
  # 2. 核心：通过 etc 模块化配置 XDG 行为
  environment.etc = {
    # 强制所有用户（无论语言环境）的默认目录名为英文
    "xdg/user-dirs.defaults".text = ''
      DESKTOP=,desktop
      DOWNLOAD=,downloads
      TEMPLATES=,templates
      PUBLICSHARE=,public
      DOCUMENTS=,documents
      MUSIC=,music
      PICTURES=,pictures
      VIDEOS=,videos
    '';

    # 关键：彻底禁用“基于 Locale 自动更新目录”的功能
    # 这样即使 LC_ALL 是中文，程序看到 enabled=false 也会直接退出，不进行翻译
    # "xdg/user-dirs.conf".text = "enabled=false";

    # 伪造 Locale 记录，让系统认为上次和这次都是英文环境
    "xdg/user-dirs.locale".text = "C";

    # rofi 插件添加 #rofi在用户目录有配置的时候，不使用系统的配置，所以使用使用home.nix处理
    "rofi/config.rasi".text = ''
      configuration = {
       plugin-path = "${pkgs.rofi-calc}/lib/rofi";
      }
       
    '';
  };

  # 3. 强制在用户登录时刷新一次（适配 labwc 等不自动刷新的环境）
environment.extraInit = ''
  if [ -x ${pkgs.xdg-user-dirs}/bin/xdg-user-dirs-update ]; then
    ${pkgs.xdg-user-dirs}/bin/xdg-user-dirs-update --force
  fi
    if [ "$XDG_SESSION_TYPE" = "x11" ]; then
      export GTK_IM_MODULE=fcitx
      export QT_IM_MODULE=fcitx
      export XMODIFIERS="@im=fcitx"
      export SDL_IM_MODULE=fcitx
      export GLFW_IM_MODULE=ibus
    fi
'';

  #  labwc的配置需要
  services.xserver.displayManager.sessionCommands = ''
    # ${pkgs.xfce.thunar}/bin/thunar --daemon &
    # dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=wlroot
  '';
  services.displayManager.ly.enable = true;
  services.displayManager.ly.x11Support = true;
  services.displayManager.ly.settings = {
    # animation = "matrix";
    session_log = ".local/state/ly-session.log";
  };

  services.udev.extraRules = ''
    SUBSYSTEM=="kvmfr", OWNER="suiwp", GROUP="kvm", MODE="0660"
  '';
  
  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "cn";
    # variant = "";
  };

  # Enable CUPS to print documents.
  # services.printing.enable = true;
  # services.printing.cups-pdf.enable = true;

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
  services.libinput.enable = true;
  #   virtualisation.waydroid.enable = true;
  # 启用 ARM 转译（Houdini）  
  #virtualisation.waydroid.enableHoudini = true;
  # enable kvm
  programs.virt-manager.enable = true;
  
  virtualisation.libvirtd.enable = true;
  virtualisation.libvirtd.qemu.verbatimConfig=''
        cgroup_device_acl = [
        "/dev/null", "/dev/full", "/dev/zero",
        "/dev/random", "/dev/urandom",
        "/dev/ptmx", "/dev/kvm",
        "/dev/kvmfr0"
                                                         ]
  '';

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
    # lua
    # lua5_3_compat
    ## appimage使用
    fuse3
    fuse
    python3
    perl
    
  ];
  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  programs.gamescope = {
    enable = true;
    capSysNice = true;
  };

  services.flatpak.enable = true;
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.groups.docker = {};
  users.users.suiwp = {
    isNormalUser = true;
    description = "suiwp";
    extraGroups = [ "networkmanager" "wheel" "cdrom" "disk" "libvirtd" "kvm" "video" "audio" "docker" "oracle" "input" ];
    
    packages = with pkgs; [
      android-tools
      bitwarden-desktop
      bottom
      # bottles
      brasero
      chezmoi
      cmake
      cachix
      dconf-editor
      # emacs-nox
      # emacs
      # file-roller
      fzf
      ffmpeg
      fastfetch
      (flameshot.override { enableWlrSupport = true; })
      # gifgen    #这个是转换的工具，不是实时录制
      gcolor3 #颜色选择器
      # gnome-software
      # gnome-text-editor
      # gamescope
      gnome-calendar
      pkgs-new.gopeed
      helix
      # jetbrains.idea-ultimate
      pkgs-new.jetbrains.idea
      jdk8
      kdePackages.kdeconnect-kde
      # kooha                     # 仅支持gnome
      logseq
      librime-with-lua5_4_compat
      lua
      multimarkdown
      nodejs_24
      # nemo-with-extensions
      # nautilus-python
      # nautilus
      # networkmanager-openvpn
      openvpn
      ollama
      onedrive
      podman-tui
      pnpm
      python3
      # qqDesktop
      # qqWrapper
      ripgrep
      snipaste
      slurp #区域选择工具
      scrcpy
      siyuan
      steam
      steam-run
      samba
      #  thunderbird
      telegram-desktop
      universal-ctags
      virtiofsd # 解决kvm虚拟机挂载目录问题
      wf-recorder
      ##      wemeet
      # wechat #使用自动更新的wechat appimage了，nixos的不能实时更新
      pkgs-new.wpsoffice-cn
      #      waydroid
      #      waydroid-helper
      # support both 32-bit and 64-bit applications
      # wineWowPackages.stable
      # wineWowPackages.waylandFull
      ## support 32-bit only
      # wine
      ## support 64-bit only
      # (wine.override { wineBuild = "wine64"; })
      ## support 64-bit only
      # wine64
      ## wine-staging (version with experimental features)
      # wineWowPackages.staging
      ## winetricks (all versions)
      # winetricks
      # wineWow64Packages.stagingFull
      ## native wayland support (unstable)
      # wineWowPackages.waylandFull
      # protontricks

      zoxide

    ] ++ ( with pkgs-new; [
      # pkgs-new.emacs-pgtk
      # pkgs-new.emacs-git
      pkgs-new.emacs-git
    ]);
  };
  environment.variables = {
    # 通常，为了确保 fcitx 正常工作，建议同时设置以下变量：  
	  # GTK_IM_MODULE = "fcitx";
	  #XMODIFIERS = "@im=fcitx";
    # QT_QPA_PLATFORMTHEME = "xdg-desktop-portal";
    NIXPKGS_ALLOW_INSECURE=1;
    # TERMINAL = "kitty";
    TERMINAL = "ghostty";
  };
  
  environment.sessionVariables = {
    # EDITOR = "emacs";
    NIXOS_OZONE_WL=1;
	  QT_IM_MODULE = "fcitx";
    GTK_USE_PORTAL = "1";
    # QT_QPA_PLATFORMTHEME = "xdg-desktop-portal";
    QT_QPA_PLATFORMTHEME = "qt5ct";
    
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
  virtualisation.oci-containers.backend = "podman";
  virtualisation.podman = {
    enable = true;
    # dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };
  virtualisation.docker = {
    enable = true;
  };
  # Install firefox.
  programs.firefox.enable = true;

  programs.labwc = {
    enable = true;
    package = pkgs-new.labwc;
  };
  qt = {
    enable = true;	#source value is true	#comment by ylagr
    # style = "kvantum";
    # platformTheme = "gnome";
    # platformTheme = "qt5ct";
    # style = "adwaita";
  };

  # Allow unfree packages
  # nixpkgs.config.allowUnfree = true;

  programs.thunar = {
    enable = true;
    # packages = pkgs-new.thunar;
    plugins = with pkgs; [ pkgs.xfce.thunar-archive-plugin xfce.thunar-volman
                           (pkgs.xfce.thunar-vcs-plugin.override { withSubversion = true; })
                           # xfce.thunar-vcs-plugin
                           xfce.thunar-dropbox-plugin];
  };
  services.tumbler.enable = true;


  programs.k3b = {
    enable = true;
  };
  programs.command-not-found.enable = false;
  # for home-manager, use programs.bash.initExtra instead
  programs.bash.interactiveShellInit = ''
      source ${pkgs.nix-index}/etc/profile.d/command-not-found.sh
  '';
  # xdg.enable = true;
  services.fprintd.enable = true;
  services.fprintd.tod = {
    enable = true;
    # 尝试使用 libfprint-2-tod1-elan 驱动插件
    driver = pkgs.libfprint-2-tod1-elan;
    # driver = pkgs.libfprint-2-tod1-vfs0090; 
  };
  services.blueman.enable = true;
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = false;
  services.seatd.enable = true;
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    blesh
    chsrc # 切换源镜像使用
    mate.engrampa
    # sort by char
    bat
    gcc
    ncdu
    libsecret
    #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    #  wget
    
    # pkgs-sys.winetricks
    # pkgs-sys.wineWow64Packages.stagingFull
    # lvm2_vdo # should use boot.lvm
    gparted
    
    nix-search-cli
    nix-index
    nix-init
    nix-tree
    
    xeyes
    xdriinfo
    wlrctl # wlroot wayland 工具
    tmux # 终端复用器
    zip
    unzip
    unrar
    p7zip
    steam
    system-config-printer # 打印机 see also https://sspai.com/post/90194 ;; 需要打印机支持，
    wl-clipboard # 解决剪贴板问题
    # lxmenu-data
    lxqt.lxqt-policykit # 使用xfce了，用上gnome的了
    # kdePackages.systemsettings  # useless
    # kdePackages.discover   # soft manager
    # lxqt.lxqt-config #用于图标主题
    # pkgs-new.orage # 功能太少了
    # osmo # 垃圾啊 注入ics之后闪退
    libsForQt5.qt5ct #配置qt外观
    kdePackages.qt6ct #配置qt外观
    pkgs.shared-mime-info # 共享xdg mime
    pkgs.glib
    # webkitgtk_4_1 # 解决tauri白屏问题
    webkitgtk_6_0 # 解决tauri白屏问题
    adwaita-icon-theme #基础图标
    powertop # 查看系统功耗
    xfce.xfce4-panel-profiles
    xfce.xfce4-weather-plugin
    xfce.xfce4-genmon-plugin # 执行脚本并显示到panel里
    # lxqt.pcmanfm-qt
    # pcmanfm
    # xfce.thunar
    # pkgs-new.thunar-archive-plugin # 添加这里没什么用
    # xarchiver  # zip gui
    peazip
    # doublecmd 用的很少  thunar足够好用了
    
    # pkgs-new.xwayland-satellite
    labwc-menu-generator
    dex #自动识别desktop文件开始启动
    waybar
    hyprlock
    # swaylock
    # fuzzel
    rofi
    rofi-calc
    wayidle
    swayidle
    # wofi
    wdisplays #用上 xfce了
    swaynotificationcenter #用上xfce了
    networkmanagerapplet
    # sfwbar
    blueman
    
    wlr-randr
    kanshi # 用上xfce了
    # cliphist # 使用copyq
    # ydotool # need ydotoold running
    # labwc-tweaks

    # emptty
    # pkgs-new.mihomo # 已经使用service配置了
    copyq
    gammastep #wayland色温调节
    
    redshift # x11 色温调节
    wmctrl # x11 窗口控制工具，用于快捷键移动
    xdotool
    xorg.xwininfo # 控制窗口脚本使用，查看窗口信息
    xprop # 控制窗口脚本使用， 查看窗口信息
    
    # busybox # 常用工具集
    coreutils # 比busybox功能多
    usbutils
    distrobox
    distrobox-tui
    podman-compose
    # kupfer
    xdg-utils
    xdg-user-dirs
    desktop-file-utils 
    inetutils
    # 光盘刻录
    # kdePackages.k3b
    # cdrtools
    # xorriso
    # dvdplusrwtools
    # udftools
    # 光盘刻录end
    uv
    opencc
    gnumake
    git
    lazygit
    net-tools
    vim
    kitty
    # pkgs-sys.ghostty
    pkgs-s.ghostty
    btop
    wget
    bash-completion
    tree
    gnome-extension-manager
    subversion
    pkgs-stable.home-manager
    looking-glass-client
    # gpaste

    # window move tool
    (callPackage ../module/win-tool.nix { })

  ] ++ (with gnomeExtensions; [
    # dash-to-dock
    # clipboard-history
    # gsconnect
    # window-list
    # flickernaut
    # edit-desktop-files
    # dash-in-panel
    # fuzzy-app-search
    # appindicator
    # indicator
    # kimpanel
    # network-stats
    # trash
    # worksets
    #不兼容#gnomeExtensions.workspace-buttons-with-app-icons
    #不兼容#gnomeExtensions.window-list-in-panel
    #和window-list重复#gnomeExtensions.workspace-indicator
    # new trash
    # workspaces-indicator-by-open-apps
    # window-title-is-back
    # night-theme-switcher
    # add-to-desktop
    # desktop-icons-ng-ding
    # desktop-lyric
    # gnome-shell-extension-desktop-icons
  ]);
  
  # Nekoray VPN
  # programs.nekoray = {
  # enable = false;  #source value is true	#comment by ylagr
  # tunMode.enable = true;  #source value is true	 #comment by ylagr
  # };
  programs.clash-verge = {
    package = pkgs-new.clash-verge-rev;
  	enable = true;
	  autoStart = false;
	  serviceMode = true;
  };
  services.mihomo = {
    package = pkgs-new.mihomo;
    enable = true;
    tunMode = true;
    configFile="${homedir}/mihomo/config.yaml";
    webui = pkgs-new.metacubexd;
    # extraOpts= "-d /home/suiwp/mihomo";
  };
  # programs.niri = {
  # enable = true;
  # package = pkgs-new.niri;
  # };
  fonts.fontDir.enable = true;
  fonts.packages = with pkgs; [
    iosevka
    # 图标库
    font-awesome
    # gnome 默认字体，比较圆润
    adwaita-fonts
    # google 字体
    noto-fonts
    # ubuntu_font_family # replace to ubuntu-classic
    ubuntu-classic
    fantasque-sans-mono
    unifont
    #nerd-fonts.arimo
    sarasa-gothic
    # source-han-sans #sarasa based on source-han-sans
    wqy_microhei
    noto-fonts-color-emoji
    # noto-fonts-cjk-sans
    # noto-fonts-cjk-serif
    nerd-fonts.bigblue-terminal
    # babelstone-han
    nerd-fonts.symbols-only
    
    # windows-fonts
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
      sansSerif = [
        "ubuntu"
        # "Unifont"
        "Sarasa Gothic SC"
        "Sarasa Gothic TC"
        "Sarasa"
        "WenQuanYi Micro Hei"
        # "Source Han Sans SC"
        "Noto Sans CJK SC"
        "Noto Color Emoji"
      ];
      monospace = [ "Fantasque Sans Mono"  "ubuntu mono" "Unifont"
                    "Sarasa Term SC"
                    "Sarasa Term TC"
                    "Sarasa"
                    "WenQuanYi Micro Hei"
                    "Noto Color Emoji"
                  ];
      # 默认应该使用宋体类型
      serif = [
        "Ubuntu"
        "Unifont"
        "Sarasa Gothic SC"
        "Sarasa Gothic TC"
        "Sarasa"
        # "WenQuanYi Micro Hei"
        # "Source Han Sans SC"
        "Noto Serif CJK SC"
        "Noto Color Emoji"
      ];
      emoji = [ "Noto Color Emoji"
                "Noto Emoji"
              ];
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



  
