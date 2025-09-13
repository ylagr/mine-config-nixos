# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];
    # Enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.substituters = [ 
    "https://mirror.sjtu.edu.cn/nix-channels/store"
    "https://mirrors.ustc.edu.cn/nix-channels/store"
    "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store" 
    "https://cache.nixos.org/"
  ];
  nixpkgs.config.allowUnfree = true; 
  # Use the systemd-boot EFI boot loader.
  # boot.loader.systemd-boot.enable = true;
  # boot.loader.grub.enable = true;
  boot.loader = {
	efi = {
    		canTouchEfiVariables = true;
		efiSysMountPoint = "/boot";
		
    	};
	grub = {
		enable = true;
		device = "nodev";  # install grub in current esp
		default = "1"; # 选择第二个引导项，从0开始计数
      		# osprober  会自动检测 windows 或其它 linux 系统并生成配置
      		# 由于经常输出无关信息，我现在不用了
     		# useOSProber = true;
     		      # 不用 osprober，自己手动添加启动项（通用配置，与实际分区无关）
     		 extraEntries = ''
    		    menuentry "Windows" {
     		      search --file --no-floppy --set=root /EFI/Microsoft/Boot/bootmgfw.efi
      		      chainloader (''${root})/EFI/Microsoft/Boot/bootmgfw.efi
    		    }
 		 '';
		efiSupport = true;  # efi enable
		gfxmodeEfi = "1024 * 768"; # grub start gui window size
	};
  };

  # boot.loader.efi.canTouchEfiVariables = true;
  # boot.loader.efi.efiSysMountPoint = "/boot";
  
  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.initrd.systemd.enable = true;
  swapDevices = [
    {
      device = "/var/swapfile";
      size = 1024 * 24;
    }
  ];
  # networking.hostName = "nixos"; # Define your hostname.
  networking.hostName = "homepc";
  # Configure network connections interactively with nmcli or nmtui.
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Shanghai";
  # time.timeZone = "Europe/Amsterdam";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.inputMethod = {
    type = "fcitx5";
    enable = true;
    fcitx5.waylandFrontend = true;
    fcitx5.addons = with pkgs; [
      rime-data
      fcitx5-rime
      fcitx5-gtk
    ];
  };
   console = {
   #  font = "Lat2-Terminus16";
   #  keyMap = "us";
     useXkbConfig = true; # use xkb.options in tty.
   };

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.desktopManager.runXdgAutostartIfNone = true;
  

  # Enable the GNOME Desktop Environment.
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
  

  # Configure keymap in X11
  services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";
  services.xserver.xkb.options = "caps:ctrl_modifier";
  
  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # services.pulseaudio.enable = true;
  # OR
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };
  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  # users.users.alice = {
  #   isNormalUser = true;
  #   extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  #   packages = with pkgs; [
  #     tree
  #   ];
  # };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.ylagr = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  };
  programs.xwayland.enable = true;
  programs.firefox.enable = true;

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  # environment.systemPackages = with pkgs; [
  #   vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #   wget
  # ];
  # sound.enable = true;
  environment.systemPackages = with pkgs; [
    vim
    git
    wget
    tmux
    btop
    waybar
    podman-tui
    podman-compose
    tree
    fastfetch
    bash-completion
    rxvt-unicode
    alacritty
    parted
  ];

  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  fonts.packages = with pkgs; [
    font-awesome
    noto-fonts
    nerd-fonts.arimo
    wqy_microhei
    nerd-fonts.bigblue-terminal
  ];

  virtualisation.containers.enable = true;
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };
  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    ports = [ 22 ];
    settings = {
      PasswordAuthentication = true;
      AllowUsers = [ "ylagr" ];
      UseDns = true;
      X11Forwarding = false;
    };
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  programs.labwc = {
    enable = true;
  };

  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };
  programs.steam = {
    enable = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
  };
  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;
  hardware.graphics.extraPackages = with pkgs; [ rocmPackages.clr.icd ];
  services.xserver.videoDrivers = [
    "amdgpu"
    # "nvidia"
  ];
  #hardware.amdgpu = {
  #enable = true;
    # open = true;
    # modesetting.enable = true;
    #prime = {
    #  offload.enable = true;
    #  offload.enableOffloadCmd = true;
      # sync.enable = false;

    #   nvidiaBusId = "PCI:1:0:0";
    #   amdgpuBusId = "PCI:74:0:0";
    #};
  ##};

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.11"; # Did you read the comment?

}
