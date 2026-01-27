{ config, home-manager, pkgs, ... }:
{
  home-manager.useUserPackages = true;
  home-manager.users.ylagr = {
    home.username = "ylagr";
    home.homeDirectory = "/home/ylagr";

    home.packages = with pkgs; [
      # acpi			#电源管理	#comment by ylagr
      # bluetui			#蓝牙工具	#comment by ylagr
      # brave			#浏览器		#comment by ylagr
      # chromium		#浏览器		#comment by ylagr
      # emacs-igc-pgtk		#comment by ylagr
      # emacs-igc-pgtk.pkgs.withPackages (epkgs: with epkgs; [telega])
      # emacs-igc			# add by ylagr
      # emacs
      emacs-lsp-booster
      fastfetch			#系统查看器	#comment by ylagr
      # ffmpeg			#视频解码软件	#comment by ylagr
      file
      # firefox			#comment by ylagr
      # foot			#终端模拟器 #comment by ylagr
      # fuzzel			#wayland app luncher	#comment by ylagr
      gcc			#
      gdb
      gh			#github cli	#comment by ylagr
      git
      global			#ctags 相关
      gnumake
      cmake
      
      # grim			#截图	#comment by ylagr
      # guile			#脚本语言	#comment by ylagr
      # guile.info		#comment by ylagr
      inetutils			#网络工具，telnet 等
      # inkscape		#画图		  #comment by ylagr
      # iw			#无线管理	  #comment by ylagr
      killall			#like kill
      # libnotify			#桌面通知	#comment by ylagr
      # libresprite		#开源像素图画编辑器 like aseprite	#comment by ylagr
      libwebp			#解码webp文件
      libtool     #vterm deps #add by ylagr
      
      fd
      lshw  			#硬件查看器
      # mako			#桌面通知	#comment by ylagr
      man-pages			#man 手册
      man-pages-posix
      mg			#emacs like text editor but	#comment by ylagr
      mpv			#视频软件
      # mypaint			#画图软件	#comment by ylagr
      # obs-studio		#录屏软件	#comment by ylagr
      pass			#密码管理工具	
      pciutils			#pci utils to listing-pci 、show pci status
      ripgrep			#modern grep
      # simple-http-server	#简易httpserver	#comment by ylagr
      # slack			#聊天工具	#comment by ylagr
      # slurp			#wayland 区域选择工具	 #comment by ylagr
      # solana-cli		#区块链账户管理工具	 #comment by ylagr
      # telegram-desktop	#telegram		 #comment by ylagr
      tmux			#终端復用工具		 #comment by ylagr
      # tokei			#code statistics utils	 #comment by ylagr
      tree			
      unzip
      # wineWowPackages.waylandFull	#wine wayland 驱动？	#comment by ylagr
      usb-modeswitch			#自动切换usb工具	#comment by ylagr
      usb-modeswitch-data		#
      usbutils				#usb工具
      # wev				#wayland show input event util	#comment by ylagr
      wget				#
      # wl-clipboard			#wayland copy/paste utils	#comment by ylagr
      # wlr-randr				#屏幕参数调整（wayland？）	#comment by ylagr
      # wtype				#simulating keyboard input in wayland	 #comment by ylagr
      # yt-dlp				#音视频下载工具	     #comment by ylagr
      # zip				#repeat？	     #comment by ylagr
      zip
      # swww				#动态壁纸	#comment by ylagr
      # (writeScriptBin "fuzzel-pass" (builtins.readFile ../dotfiles/bash/fuzzel-pass.sh))	#comment by ylagr

      # font
      ubuntu_font_family
      lxgw-wenkai
      
    ];
    fonts.fontconfig.enable = true;
    home.sessionVariables = {
      EDITOR = "emacs";
      ALL_PROXY="http://127.0.0.1:7897";
      HTTPS_PROXY="http://127.0.0.1:7897";
    };
    
    home.pointerCursor = {
      name = "XCursor-Pro-Red";
      package = pkgs.xcursor-pro;
      size = 32;
      gtk.enable = true;
    };

    programs.git = {
      enable = true;
      userName = "ylagr";
      userEmail = "ylagr@hotmail.com";
    };
    # programs.rime = { enable = true };
    programs.emacs = {
      enable = true;
      package = pkgs.emacs-igc-pgtk.pkgs.withPackages (epkgs: with epkgs; [ 
        # (eaf.withApplications [ eaf-browser eaf-pdf-viewer ])
        telega
        rime
      ]);
    };
    programs = {
      direnv = {
        enable = true;
        enableBashIntegration = true; # see note on other shells below
        nix-direnv.enable = true;
      };

      bash = {
        enable = true;
        bashrcExtra = ''
          PROMPT_COMMAND=__bash_prompt
          source ${../dotfiles/bash/prompt.sh}
          source ${../dotfiles/bash/osc7_cwd.sh}
        '';
      };
    };

    # programs.firefox.enable = true;	#comment by ylagr

    home.file = {
      ".config/zellij" = { source = ../dotfiles/zellij; };
      ".config/containers" = { source = ../dotfiles/containers; };
      ".config/sway" = { source = ../dotfiles/sway; };
      ".config/waybar" = { source = ../dotfiles/waybar; };
      ".config/foot" = { source = ../dotfiles/foot; };
      ".config/fuzzel" = { source = ../dotfiles/fuzzel; };
      ".config/labwc" = { source = ../dotfiles/labwc; };
      ".tmux.conf" = { source = ../dotfiles/tmux/.tmux.conf; };
      ".guile" = { source = ../dotfiles/guile/.guile; };
    };

    # services.kanshi.enable = true;	#wayland daemon automatically configures outputs	#comment by ylagr

    home.stateVersion = "25.05";

    # Let Home Manager install and manage itself.
    programs.home-manager.enable = true;
  };
}
