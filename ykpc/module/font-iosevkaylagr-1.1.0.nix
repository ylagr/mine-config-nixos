{ pkgs, lib,  ... }:

let
  # 内部定义字体包， 增加字体占空高度
  version = "v1.1.0";
  
  font-iosevka-ylagr = pkgs.stdenv.mkDerivation rec {
    pname = "font-iosevka-ylagr";
    # version = ${version};
    inherit version;
    src = pkgs.fetchurl {
      url = "https://github.com/ylagr/Iosevka/releases/download/v20260303.153000/IosevkaYlagr-ttf.zip";
      # 建议使用 nix-prefetch-url 提前获取 hash，或填空后根据报错更新
      hash = "sha256:c0e40e968dfed2b0485dd9e2e40c6378a95f7e37ef000f1192a9222486037497"; 
    };

    nativeBuildInputs = [ pkgs.unzip ];
    unpackPhase = ''
      unzip $src
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out/share/fonts/truetype
      # 递归寻找当前目录下所有 ttf 并安装
      find . -name "*.ttf" -exec cp {} $out/share/fonts/truetype/ \;

      runHook postInstall
    '';
  };

in
{
  # 模块核心：直接在这里声明启用
  fonts.packages = [ font-iosevka-ylagr ];
  
  # 可选：如果需要，还可以顺便配置 fontconfig 让系统默认首选此字体
  fonts.fontconfig.defaultFonts.monospace =  lib.mkBefore [ "IosevkaYlagr" ];
}
