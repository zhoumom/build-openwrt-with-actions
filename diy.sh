#!/bin/bash
# =====================================================
# ✨ OpenWrt / ImmortalWrt 自动自定义脚本（diy.sh）
# 作者：mo zhou（经 ChatGPT 优化）
# 兼容性：OpenWrt 官方、ImmortalWrt、Lean、Kiddin9 源码
# =====================================================

echo "🚀 开始执行自定义脚本 diy.sh ..."

# 1️⃣ 修改默认 LAN IP 地址
sed -i 's/192.168.1.1/192.168.10.1/g' package/base-files/files/bin/config_generate
echo "✅ 已将默认 LAN IP 修改为 192.168.10.1"

# 2️⃣ 修改默认主题（自动检测 luci Makefile 路径）
LUCIMK=$(find feeds/luci -type f -path "*/collections/*" -name "Makefile" | head -n 1)
if [ -n "$LUCIMK" ]; then
    echo "🎨 检测到 Luci Makefile：$LUCIMK"
    if grep -q "luci-theme-argon" "$LUCIMK"; then
        echo "✅ Luci 已包含 luci-theme-argon，无需修改"
    else
        sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' "$LUCIMK" || true
        echo "✅ 已将默认主题修改为 luci-theme-argon"
    fi
else
    echo "⚠️ 未找到 luci/collections/luci/Makefile，跳过主题修改"
fi

# 3️⃣ 修改登录界面显示固件名称
#if grep -q "ImmortalWrt" package/base-files/files/bin/config_generate; then
#    sed -i 's/ImmortalWrt/ZWRT/g' package/base-files/files/bin/config_generate
#elif grep -q "OpenWrt" package/base-files/files/bin/config_generate; then
#   sed -i 's/OpenWrt/ZWRT/g' package/base-files/files/bin/config_generate
#fi
#echo "✅ 登录界面固件名称已修改为 ZWRT"

# 4️⃣ 自动添加第三方软件源（如果未添加）
FEEDS_CONF="feeds.conf.default"
if ! grep -q "kenzok8" "$FEEDS_CONF"; then
    echo "src-git kenzok8 https://github.com/kenzok8/openwrt-packages" >> "$FEEDS_CONF"
    echo "src-git small https://github.com/kenzok8/small" >> "$FEEDS_CONF"
    echo "✅ 已添加 kenzok8 软件源"
fi

# 5️⃣ 自动克隆额外软件包（仅在未存在时执行）
[ ! -d package/kwrt-packages ] && git clone https://github.com/kiddin9/kwrt-packages.git package/kwrt-packages && echo "✅ 已添加 kiddin9 的 kwrt-packages"
#[ ! -d package/UA3F ] && git clone https://github.com/SunBK201/UA3F.git package/UA3F && echo "✅ 已添加 UA3F"
#[ ! -d package/ADGH ] && git clone https://github.com/stevenjoezhang/luci-app-adguardhome.git package/ADGH && echo "✅ 已添加 AdGuardHome"

# 6️⃣ 清理无效或冲突包（可选）
rm -rf feeds/luci/themes/luci-theme-argon 2>/dev/null
#rm -rf feeds/luci/applications/luci-app-adguardhome 2>/dev/null
echo "🧹 已清理可能冲突的旧主题或插件"

# 7️⃣ 显示确认信息
echo "✅ 自定义步骤执行完成，准备更新 feeds 并编译。"
