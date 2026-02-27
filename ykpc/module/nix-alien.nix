{inputs,  pkgs, ... }:

# let
#   nix-alien-pkgs = import (
#     builtins.fetchTarball {
#       url = "https://github.com/thiagokokada/nix-alien/tarball/master";
#       sha256 = "1srlgd2a3x9lcvwazrrj19mgnf20dad6s70s8573j502gsx0k17s";
#     }
#   ) {
#     inherit (pkgs)system;
#   };
# in
# {
#   environment.systemPackages = with nix-alien-pkgs; [
#     nix-alien
#   ];

#   # Optional, but this is needed for `nix-alien-ld` command
#   programs.nix-ld.enable = true;
# }


  let
  # 使用 getFlake 直接获取仓库，系统会自动处理纯净性问题
  # nix-alien-flake = builtins.getFlake "github:thiagokokada/nix-alien/master";
  
  # 从 flake 中提取对应你当前系统的 package
  # nix-alien-pkg = nix-alien-flake.packages.${pkgs.system}.nix-alien;
in
{
  environment.systemPackages = [
    inputs.nix-alien.packages.${pkgs.system}.nix-alien
  ];

  # 必须开启，否则 nix-alien 运行后可能找不到库
  programs.nix-ld.enable = true;
}
