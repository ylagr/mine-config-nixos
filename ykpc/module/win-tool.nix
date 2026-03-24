{ pkgs, ... }:

pkgs.writeShellScriptBin "win-tool" ''
  WMCTRL="${pkgs.wmctrl}/bin/wmctrl"
  XWININFO="${pkgs.xorg.xwininfo}/bin/xwininfo"
  XRANDR="${pkgs.xorg.xrandr}/bin/xrandr"
  XPROP="${pkgs.xorg.xprop}/bin/xprop"

  # 1. 获取当前窗口 ID
  ID=$(${pkgs.xdotool}/bin/xdotool getactivewindow)
  [ -z "$ID" ] && exit 1
  HEX_ID=$(printf "0x%x" "$ID")

  # 2. 动态读取外框扩展属性 (这是 Xfce 窗口管理器标记的边框厚度)
  # 格式: left, right, top, bottom
  FRAME_EXTENTS=$($XPROP -id "$ID" _NET_FRAME_EXTENTS | cut -d '=' -f 2 | tr -d ' ')
  B_LEFT=$(echo "$FRAME_EXTENTS" | cut -d ',' -f 1)
  B_TOP=$(echo "$FRAME_EXTENTS" | cut -d ',' -f 3)
  
  # 保底值处理
  [ -z "$B_LEFT" ] || [ "$B_LEFT" = "extentsnotfound" ] && B_LEFT=0
  [ -z "$B_TOP" ] || [ "$B_TOP" = "extentsnotfound" ] && B_TOP=0

  # 3. 获取几何信息 (内容区绝对坐标 WX, WY)
  GEOM=$($XWININFO -id "$ID")
  WW=$(echo "$GEOM" | grep "Width:" | awk '{print $2}')
  WH=$(echo "$GEOM" | grep "Height:" | awk '{print $2}')
  WX=$(echo "$GEOM" | grep "Absolute upper-left X:" | awk '{print $4}')
  WY=$(echo "$GEOM" | grep "Absolute upper-left Y:" | awk '{print $4}')

  # 4. 识别显示器 (基于视觉中心点)
  WC=$((WX + WW / 2))
  MON=$($XRANDR --query | grep " connected" | grep -oP '\d+x\d+\+\d+\+\d+' | while read -r m; do
      W=$(echo "$m" | cut -dx -f1); H=$(echo "$m" | cut -dx -f2 | cut -d+ -f1)
      X=$(echo "$m" | cut -d+ -f2); Y=$(echo "$m" | cut -d+ -f3)
      if [ "$WC" -ge "$X" ] && [ "$WC" -lt "$((X + W))" ]; then echo "$W $H $X $Y"; break; fi
  done)
  [ -z "$MON" ] && MON="1920 1080 0 0"
  read SW SH SX SY <<EOF
$MON
EOF

  # 5. 解除最大化
  $WMCTRL -i -r "$HEX_ID" -b remove,maximized_horz,maximized_vert

  # 6. 计算目标位置 (统一使用 Gravity 1 参考点)
  # TX/TY 是"外框左上角"的目标坐标
  case "$1" in
    "85")
      TW=$((SW * 85 / 100)); TH=$((SH * 85 / 100))
      TX=$((SX + (SW - TW) / 2)); TY=$((SY + (SH - TH) / 2)) ;;
    "center")
      TX=$((SX + (SW - WW) / 2)); TY=$((SY + (SH - WH) / 2))
      TW=$WW; TH=$WH ;;
    "right60")
      TX=$((SX + SW * 60 / 100))
      TY=$((WY - B_TOP)); TW=$WW; TH=$WH ;; # 保持当前外框顶端位置
    "left40")
      TX=$((SX + (SW * 40 / 100) - WW))
      TY=$((WY - B_TOP)); TW=$WW; TH=$WH ;;
  esac

  # 7. 最终执行：强制 Gravity 1 (NorthWest)
  # 参数 1 告诉 xfwm4：这个坐标是给外框顶点的
  $WMCTRL -i -r "$HEX_ID" -e "1,$TX,$TY,$TW,$TH"
''
