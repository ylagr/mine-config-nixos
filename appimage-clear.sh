#!/bin/bash

GEAR_DIR="$HOME/AppImages"
CACHE_ROOT="$HOME/.cache/appimage-run"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # 无颜色

echo -e "${YELLOW}🔍 正在同步 Gear Lever 管理的应用哈希...${NC}"

# 1. 预先获取 Gear Lever 中所有文件的 SHA256 列表
declare -A gear_hashes
if [ -d "$GEAR_DIR" ]; then
    while read -r line; do
        hash=$(echo "$line" | awk '{print $1}')
        gear_hashes["$hash"]=1
    done < <(sha256sum "$GEAR_DIR"/*.appimage 2>/dev/null)
fi

echo -e "----------------------------------------------------------------"
echo -e "检查状态\t哈希(前8位)\t应用名称\t版本号"
echo -e "----------------------------------------------------------------"

# 2. 遍历缓存目录
for cache_dir in "$CACHE_ROOT"/*; do
    [ ! -d "$cache_dir" ] && continue
    
    hash_name=$(basename "$cache_dir")
    short_hash=${hash_name:0:8}
    
    # 尝试从缓存内部提取应用信息
    desktop_file=$(find "$cache_dir" -maxdepth 2 -name "*.desktop" | head -n 1)
    app_name="未知应用"
    app_ver="未知版本"
    
    if [ -f "$desktop_file" ]; then
        app_name=$(grep -m 1 "^Name=" "$desktop_file" | cut -d'=' -f2)
        app_ver=$(grep -m 1 "^X-AppImage-Version=" "$desktop_file" | cut -d'=' -f2)
        [ -z "$app_ver" ] && app_ver="N/A"
    fi

    # 3. 对比哈希
    if [[ ${gear_hashes[$hash_name]} ]]; then
        echo -e "${GREEN}[当前使用]${NC}\t$short_hash\t$app_name\t$app_ver"
    else
        echo -e "${RED}[冗余缓存]${NC}\t$short_hash\t$app_name\t$app_ver"
        
        # 4. 交互式删除提示
        read -p "❓ 发现旧版本或残留缓存，是否删除？(y/N): " confirm
        if [[ "$confirm" =~ ^[Yy]$ ]]; then
            rm -rf "$cache_dir"
            echo -e "  ✨ 已清理: $short_hash"
        else
            echo -e "  ⏭️ 已跳过"
        fi
    fi
done

echo -e "----------------------------------------------------------------"
echo "扫描完成。"
