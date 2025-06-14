#!/bin/bash

# Magic Terminal DMG 创建脚本
set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印彩色信息
info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

error() {
    echo -e "${RED}❌ $1${NC}"
    exit 1
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
DIST_DIR="$PROJECT_DIR/dist"
DMG_NAME="Magic-Terminal"
APP_NAME="Magic Terminal.app"
DMG_SOURCE_DIR="$DIST_DIR/dmg-source"
BACKGROUND_FILE="$PROJECT_DIR/assets/dmg-background.png"
VERSION=$(git describe --tags --always 2>/dev/null || echo "dev")

info "开始创建 Magic Terminal DMG 安装包..."

# 检查是否在 macOS 上运行
if [[ "$OSTYPE" != "darwin"* ]]; then
    error "DMG 创建只能在 macOS 上运行"
fi

# 检查应用是否存在
if [ ! -d "$DIST_DIR/$APP_NAME" ]; then
    error "找不到应用包 '$APP_NAME'"
    echo "请先运行: make fyne-package"
    exit 1
fi

# 清理已存在的 DMG 文件
info "清理已存在的文件..."
rm -f "$DIST_DIR/${DMG_NAME}.dmg"
rm -f "$DIST_DIR/${DMG_NAME}-temp.dmg"

# 清理并创建临时目录
info "准备临时目录..."
rm -rf "$DMG_SOURCE_DIR"
mkdir -p "$DMG_SOURCE_DIR"

# 复制应用到临时目录
info "复制应用包..."
cp -R "$DIST_DIR/$APP_NAME" "$DMG_SOURCE_DIR/"

# 创建 Applications 快捷方式
info "创建 Applications 链接..."
ln -sf /Applications "$DMG_SOURCE_DIR/Applications"

# 复制背景图片（如果存在）
if [ -f "$BACKGROUND_FILE" ]; then
    info "添加背景图片..."
    mkdir -p "$DMG_SOURCE_DIR/.background"
    cp "$BACKGROUND_FILE" "$DMG_SOURCE_DIR/.background/"
fi

# 创建 README 文件
info "创建安装说明..."
cat > "$DMG_SOURCE_DIR/README.txt" << EOF
Magic Terminal Installation Guide
================================

To install Magic Terminal:
1. Drag "Magic Terminal.app" to the "Applications" folder
2. Open Applications folder and double-click "Magic Terminal"
3. Enjoy your new terminal emulator!

For more information, visit:
https://github.com/wangyiyang/Magic-Terminal

Version: $VERSION
Build Date: $(date '+%Y-%m-%d %H:%M:%S')

Features:
- Cross-platform terminal emulator
- Built with Fyne toolkit
- Support for ANSI colors and Unicode
- Customizable themes
- Modern UI design
EOF

# 创建基础 DMG
info "创建临时 DMG 文件..."
hdiutil create -srcfolder "$DMG_SOURCE_DIR" \
    -volname "$DMG_NAME" \
    -fs HFS+ \
    -fsargs "-c c=64,a=16,e=16" \
    -format UDRW \
    -size 250M \
    "$DIST_DIR/${DMG_NAME}-temp.dmg"

# 挂载 DMG 进行自定义
info "挂载 DMG 进行自定义..."
MOUNT_DIR="/Volumes/$DMG_NAME"

# 确保没有同名卷已挂载
if [ -d "$MOUNT_DIR" ]; then
    warning "卸载已存在的卷: $MOUNT_DIR"
    hdiutil detach "$MOUNT_DIR" 2>/dev/null || true
fi

hdiutil attach "$DIST_DIR/${DMG_NAME}-temp.dmg"

# 等待挂载完成
sleep 3

# 使用 AppleScript 设置 Finder 窗口属性
info "自定义 DMG 布局..."
osascript << EOF
tell application "Finder"
    tell disk "$DMG_NAME"
        open
        set current view of container window to icon view
        set toolbar visible of container window to false
        set statusbar visible of container window to false
        set the bounds of container window to {100, 100, 700, 500}
        
        set viewOptions to the icon view options of container window
        set arrangement of viewOptions to not arranged
        set icon size of viewOptions to 80
        set text size of viewOptions to 12
        
        -- 设置图标位置
        set position of item "$APP_NAME" of container window to {180, 220}
        set position of item "Applications" of container window to {480, 220}
        
        -- 如果有 README 文件，设置位置
        if exists item "README.txt" then
            set position of item "README.txt" of container window to {330, 350}
        end if
        
        -- 如果有背景图片则设置
        try
            if exists file ".background:dmg-background.png" then
                set background picture of viewOptions to file ".background:dmg-background.png"
            end if
        end try
        
        update without registering applications
        delay 2
        
        -- 关闭窗口
        close
    end tell
end tell
EOF

# 等待 AppleScript 完成
sleep 2

# 卸载临时 DMG
info "卸载临时 DMG..."
hdiutil detach "$MOUNT_DIR"

# 等待完全卸载
sleep 2

# 转换为最终的只读 DMG
info "创建最终 DMG 文件..."
rm -f "$DIST_DIR/${DMG_NAME}.dmg"  # 删除已存在的文件
hdiutil convert "$DIST_DIR/${DMG_NAME}-temp.dmg" \
    -format UDBZ \
    -o "$DIST_DIR/${DMG_NAME}.dmg"

# 清理临时文件
info "清理临时文件..."
rm -f "$DIST_DIR/${DMG_NAME}-temp.dmg"
rm -rf "$DMG_SOURCE_DIR"

# 显示结果
DMG_SIZE=$(du -h "$DIST_DIR/${DMG_NAME}.dmg" | cut -f1)
success "DMG 创建完成!"
echo ""
echo "📦 文件: $DIST_DIR/${DMG_NAME}.dmg"
echo "📊 大小: $DMG_SIZE"
echo "🏷️  版本: $VERSION"
echo ""
info "安装包已准备就绪，可以分发给用户!"
echo "用户只需双击 DMG 文件，然后拖拽应用到 Applications 文件夹即可完成安装。"
