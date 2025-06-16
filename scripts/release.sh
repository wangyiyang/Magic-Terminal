#!/bin/bash

# Magic Terminal 发布脚本
# 用法: ./scripts/release.sh v1.0.0

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

# 检查参数
if [ $# -eq 0 ]; then
    error "请提供版本号，例如: ./scripts/release.sh v1.0.0"
fi

VERSION=$1

# 验证版本号格式
if [[ ! $VERSION =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    error "版本号格式不正确，应该是 vX.Y.Z 格式，例如 v1.0.0"
fi

info "准备发布 Magic Terminal $VERSION"

# 检查是否在 git 仓库中
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    error "当前目录不是 git 仓库"
fi

# 检查工作目录是否干净
if [[ $(git status --porcelain) ]]; then
    warning "工作目录有未提交的更改"
    read -p "是否继续？(y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        error "发布已取消"
    fi
fi

# 确保在主分支
CURRENT_BRANCH=$(git branch --show-current)
if [[ $CURRENT_BRANCH != "main" && $CURRENT_BRANCH != "master" ]]; then
    warning "当前不在主分支 ($CURRENT_BRANCH)"
    read -p "是否继续？(y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        error "发布已取消"
    fi
fi

# 拉取最新代码
info "拉取最新代码..."
git pull origin $CURRENT_BRANCH

# 运行测试
info "运行测试..."
if ! make test; then
    error "测试失败，请修复后重试"
fi

success "测试通过"

# 检查是否已存在该标签
if git tag -l | grep -q "^$VERSION$"; then
    error "标签 $VERSION 已存在"
fi

# 更新 FyneApp.toml 中的 Build 号
info "更新 FyneApp.toml Build 号..."
CURRENT_BUILD=$(grep "Build = " cmd/fyneterm/FyneApp.toml | cut -d' ' -f3)
NEW_BUILD=$((CURRENT_BUILD + 1))

# 使用 sed 更新 Build 号（兼容 macOS 和 Linux）
if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s/Build = $CURRENT_BUILD/Build = $NEW_BUILD/" cmd/fyneterm/FyneApp.toml
else
    sed -i "s/Build = $CURRENT_BUILD/Build = $NEW_BUILD/" cmd/fyneterm/FyneApp.toml
fi

success "Build 号已更新: $CURRENT_BUILD -> $NEW_BUILD"

# 提交 Build 号更新
if [[ $(git status --porcelain cmd/fyneterm/FyneApp.toml) ]]; then
    info "提交 Build 号更新..."
    git add cmd/fyneterm/FyneApp.toml
    git commit -m "chore: bump build number to $NEW_BUILD for release $VERSION"
fi

# 创建标签
info "创建标签 $VERSION..."
git tag -a $VERSION -m "Release $VERSION"

# 推送标签和代码
info "推送到远程仓库..."
git push origin $CURRENT_BRANCH
git push origin $VERSION

success "标签 $VERSION 已创建并推送"

# 等待 GitHub Actions
info "GitHub Actions 将自动构建和发布制品"
info "你可以在以下地址查看构建状态:"
echo "https://github.com/wangyiyang/Magic-Terminal/actions"

info "发布完成后，制品将在以下地址可用:"
echo "https://github.com/wangyiyang/Magic-Terminal/releases/tag/$VERSION"

success "发布流程已启动！"

# 提示后续步骤
echo
info "后续步骤:"
echo "1. 等待 GitHub Actions 完成构建"
echo "2. 检查发布的制品是否正确"
echo "3. 测试下载的制品"
echo "4. 更新文档（如需要）"
