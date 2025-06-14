#!/bin/bash

# 创建 DMG 背景图片
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
ASSETS_DIR="$PROJECT_DIR/assets"
BACKGROUND_FILE="$ASSETS_DIR/dmg-background.png"

echo "🎨 创建 DMG 背景图片..."

mkdir -p "$ASSETS_DIR"

# 检查是否有 ImageMagick 或其他工具可用
if command -v convert >/dev/null 2>&1; then
    # 使用 ImageMagick 创建渐变背景
    echo "使用 ImageMagick 创建背景..."
    convert -size 600x400 gradient:'#f0f0f0-#e0e0e0' "$BACKGROUND_FILE"
    echo "✅ 使用 ImageMagick 创建了渐变背景"
elif command -v sips >/dev/null 2>&1; then
    # 使用 macOS sips 创建纯色背景
    echo "使用 macOS sips 创建背景..."
    # 创建一个临时的白色图片
    python3 -c "
from PIL import Image
import sys
try:
    img = Image.new('RGB', (600, 400), color = (240, 240, 240))
    img.save('$BACKGROUND_FILE')
    print('✅ 使用 PIL 创建了背景图片')
except ImportError:
    sys.exit(1)
" 2>/dev/null || {
    # 如果 PIL 不可用，创建一个占位符
    echo "⚠️  无法创建自定义背景，将使用系统默认背景"
    touch "$BACKGROUND_FILE"
}
else
    echo "⚠️  未找到图像处理工具，将使用系统默认背景"
    echo "可以安装 ImageMagick (brew install imagemagick) 来创建自定义背景"
    # 创建空文件作为占位符
    touch "$BACKGROUND_FILE"
fi

# 如果文件存在且不为空，显示信息
if [ -s "$BACKGROUND_FILE" ]; then
    echo "📁 背景文件已创建: $BACKGROUND_FILE"
    if command -v file >/dev/null 2>&1; then
        echo "📊 文件信息: $(file "$BACKGROUND_FILE")"
    fi
else
    echo "📝 已创建占位符文件，DMG 将使用系统默认背景"
fi

echo "✅ 背景图片准备完成"
