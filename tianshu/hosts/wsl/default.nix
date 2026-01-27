# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, username, modulesPath, pkgs, ... }:

{
  imports =
    [
      # ../hardware-configuration/x1c.nix	#wsl no need hardware config	#comment by ylagr
      (modulesPath + "/installer/scan/not-detected.nix")     #add by ylagr
      ../../cachix.nix
    ];
  wsl = {
    enable = true;
    defaultUser = "${username}";
    startMenuLaunchers = true;
  };
  # Enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Use the systemd-boot EFI boot loader.
  # boot.loader.systemd-boot.enable = true;	#comment by ylagr
  # boot.loader.efi.canTouchEfiVariables = true;	 #comment by ylagr

  # Use latest kernel.
  # boot.kernelPackages = pkgs.linuxPackages_latest;	#comment by ylagr

  networking.hostName = "wsl"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.	#comment by ylagr

  # Set your time zone.
  time.timeZone = "Asia/Shanghai";

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

  documentation = {
    dev.enable = true;
  };

  services.xserver.desktopManager.runXdgAutostartIfNone = true;

  console.useXkbConfig = true;

  # Enable the X11 windowing system.
  # services.xserver.enable = true;

  # Configure keymap in X11
  services.xserver.xkb.layout = "us";
  services.xserver.xkb.variant = "";	#source value is "dvp"	#comment by ylagr

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # services.pulseaudio.enable = true;
  # OR
  services.pipewire = {
    enable = false;  #底层多媒体框架	#source value is true	#comment by ylagr
    pulse.enable = true;
  };

  # hardware.bluetooth.enable = true; # enables support for Bluetooth	#comment by ylagr
  # hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot	#comment by ylagr

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.ylagr = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  };

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    tree
    file
    wslu                        # add by ylagr
    wsl-open                    # add by ylagr
    mg
    git
    wget
    tmux
    btop
    # waybar	#wayland 状态栏	#comment by ylagr
    # podman-tui	#docker 轻量方案	 #comment by ylagr
    # podman-compose	#comment by ylagr
  ];

  qt = {
    enable = false;	#source value is true	#comment by ylagr
    style = "kvantum";
  };

  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  fonts.packages = with pkgs; [
    # font-awesome #comment by ylagr
    noto-fonts
    ubuntu_font_family
    # nerd-fonts.arimo	#comment by ylagr
    # nerd-fonts.ubuntu-mono	 #add by ylagr
    # lxgw-wenkai			 #add by ylagr
    # wqy_microhei		 #comment by ylagr
    nerd-fonts.bigblue-terminal
  ];

  # virtualisation.containers.enable = true;	#comment by ylagr
  virtualisation.podman = {
    enable = false;	#source value is true	#comment by ylagr
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };


  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Nekoray VPN
  programs.nekoray = {
    enable = false;  #source value is true	#comment by ylagr
    tunMode.enable = false;  #source value is true	 #comment by ylagr
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  programs.labwc = {
    enable = false;	#source value is true	#wayland 合成器	#comment by ylagr
  };

  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };

  hardware.graphics = {
    enable = true; #source value is true	#comment by ylagr
    # extraPackages = with pkgs; [ #comment by ylagr
    # intel-vaapi-driver
    # vpl-gpu-rt
    # ];
  };

  services.tlp.enable = true;	#笔记本电池节省工具	#comment by ylagr

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

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
  system.stateVersion = "25.05"; # Did you read the comment?
}
