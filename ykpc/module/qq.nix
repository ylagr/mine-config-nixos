{pkgs, config, lib, options,  ...}:

let 
originalQQ = pkgs.qq;
qqWrapper = pkgs.writeShellScriptBin "qq" ''
  export QT_IM_MODULE=fcitx
  export GTK_IM_MODULE=fcitx
  export XMODIFIERS='@im=fcitx'
  rm -rf ~/.config/QQ/versions
  exec ${originalQQ}/bin/qq --disable-gpu "$@" 
'';
# qqWrapper use appimage appimage有问题，还是用回原生qq吧
qqDesktop = pkgs.makeDesktopItem {
  name = "QQDesktop";
  desktopName = "QQDesktop";
  genericName = "QQDesktop";
  exec = "${qqWrapper}/bin/qq %U";
  icon = "${originalQQ}/share/icons/hicolor/512x512/apps/qq.png"; # 或者指定一个本地图标路径
  terminal = false;
  categories = [ "Network" "Chat" ];
  comment = "qq desktop";
};
commonPackages = [ qqDesktop ];
  # 1. 在这里统一定义你的配置内容
  commonConfig = {
    # 针对 NixOS 的键
    environment.systemPackages = [ qqDesktop ];
    
    # 针对 Home Manager 的键
    home.packages = [ qqDesktop ];
    
    # 你甚至可以加更多的通用配置
    # programs.zsh.enable = true;
  };
in
{
  # 2. 这里的 magic：只把当前环境“认识”的选项合并进去
  # 如果是 HM，它不认识 environment，intersectAttrs 就会把 environment 删掉
  config = builtins.intersectAttrs options commonConfig;
}
