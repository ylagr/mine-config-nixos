{ pkgs, ... }:

let
  # 内部定义字体包
  version = "V2.9.5792";
  
  cjkfont-plangothic-p1-pkg = pkgs.stdenv.mkDerivation rec {
    pname = "cjkfont-plangothic-p1";
    # version = ${version};
    inherit version;
    src = pkgs.fetchurl {
      url = "https://github.com/Fitzgerald-Porthmouth-Koenigsegg/Plangothic_Project/releases/download/${version}/PlangothicP1-Regular.ttf";
      # 建议使用 nix-prefetch-url 提前获取 hash，或填空后根据报错更新
      hash = "sha256:ac2d45bcd91953f291cfaf437f5a6498b55aa4358dca76f1a6edac37c7ebca63"; 
    };

    dontUnpack = true;

    installPhase = ''
      install -Dm644 $src $out/share/fonts/truetype/PlangothicP1-Regular.ttf
    '';
  };
  cjkfont-plangothic-p2-pkg = pkgs.stdenv.mkDerivation rec {
    pname = "cjkfont-plangothic-p2";
    # version = ${version};
    inherit version;
    src = pkgs.fetchurl {
      url = "https://github.com/Fitzgerald-Porthmouth-Koenigsegg/Plangothic_Project/releases/download/${version}/PlangothicP2-Regular.ttf";
      # 建议使用 nix-prefetch-url 提前获取 hash，或填空后根据报错更新
      hash = "sha256:3ab368be64602826e82622658ef36bc59248f2432169a77d614832f9cba1c0c9"; 
    };

    dontUnpack = true;

    installPhase = ''
      install -Dm644 $src $out/share/fonts/truetype/PlangothicP2-Regular.ttf
    '';
  };
in
{
  # 模块核心：直接在这里声明启用
  fonts.packages = [ cjkfont-plangothic-p1-pkg cjkfont-plangothic-p2-pkg ];
  
  # 可选：如果需要，还可以顺便配置 fontconfig 让系统默认首选此字体
  fonts.fontconfig.defaultFonts.sansSerif = [ "Plangothic" ];
}
