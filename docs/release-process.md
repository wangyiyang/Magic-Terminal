# Magic Terminal 发布流程指南

## 🎯 概述

本文档详细描述了 Magic Terminal 项目的完整发布流程，包括版本规划、构建、测试、发布和后发布监控的所有步骤。

## 📋 发布类型

### 1. 版本分类

#### 🔥 Major Release (主版本发布)
- **版本格式**: `v2.0.0`
- **发布周期**: 6-12 个月
- **内容**: 重大功能更新、架构变更、破坏性变更
- **示例**: 全新 UI 设计、新的插件系统、API 重构

#### ⭐ Minor Release (次版本发布)
- **版本格式**: `v1.1.0`
- **发布周期**: 1-3 个月
- **内容**: 新功能、功能增强、向后兼容的 API 变更
- **示例**: 新的主题支持、标签页功能、快捷键自定义

#### 🔧 Patch Release (补丁发布)
- **版本格式**: `v1.0.1`
- **发布周期**: 1-4 周
- **内容**: Bug 修复、安全补丁、小的改进
- **示例**: 性能优化、崩溃修复、兼容性改进

#### 🚨 Hotfix Release (热修复发布)
- **版本格式**: `v1.0.1-hotfix.1`
- **发布周期**: 紧急情况下立即发布
- **内容**: 严重 Bug 修复、安全漏洞修复
- **示例**: 数据丢失修复、安全漏洞补丁

### 2. 发布渠道

#### 🧪 Pre-release (预发布)
```bash
# Alpha 版本 - 内部测试
v1.1.0-alpha.1
v1.1.0-alpha.2

# Beta 版本 - 公开测试
v1.1.0-beta.1
v1.1.0-beta.2

# Release Candidate - 发布候选
v1.1.0-rc.1
v1.1.0-rc.2
```

#### 🚀 Stable Release (稳定发布)
```bash
# 正式版本
v1.1.0
```

## 🗓️ 发布计划

### 1. 发布时间表

#### 年度发布规划
```markdown
## 2025 年发布计划

### Q1 (1-3月)
- **v1.3.0** (Minor) - 标签页功能、主题增强
- **v1.3.1** (Patch) - Bug 修复和性能优化

### Q2 (4-6月)
- **v1.4.0** (Minor) - 插件系统、自定义快捷键
- **v1.4.1** (Patch) - 稳定性改进

### Q3 (7-9月)
- **v2.0.0** (Major) - 新架构、现代化 UI
- **v2.0.1** (Patch) - 发布后修复

### Q4 (10-12月)
- **v2.1.0** (Minor) - 功能完善、社区反馈
- **v2.1.1** (Patch) - 年末稳定版本
```

### 2. 里程碑管理

#### GitHub 里程碑配置
```markdown
## 里程碑模板

### v1.3.0 - 标签页功能
**目标日期**: 2025-03-15
**功能列表**:
- [ ] 多标签页支持 (#101)
- [ ] 标签页拖拽排序 (#102)
- [ ] 标签页右键菜单 (#103)
- [ ] 标签页主题适配 (#104)

**测试要求**:
- [ ] 功能测试完成
- [ ] 性能测试通过
- [ ] 平台兼容性验证
- [ ] 文档更新完成

**发布标准**:
- [ ] 所有 Issue 关闭
- [ ] CI/CD 流水线通过
- [ ] 代码审查完成
- [ ] 发布说明准备就绪
```

## 🔄 发布流程

### 1. 发布前准备

#### 代码冻结检查
```bash
#!/bin/bash
# pre-release-check.sh

echo "🔍 Pre-release checklist..."

# 1. 检查分支状态
echo "Checking branch status..."
git fetch origin
BEHIND=$(git rev-list --count HEAD..origin/main)
if [ $BEHIND -gt 0 ]; then
    echo "❌ Branch is behind origin/main by $BEHIND commits"
    exit 1
fi

# 2. 检查未提交的更改
echo "Checking for uncommitted changes..."
if [ -n "$(git status --porcelain)" ]; then
    echo "❌ Uncommitted changes found"
    git status --short
    exit 1
fi

# 3. 运行完整测试套件
echo "Running full test suite..."
make test-all

# 4. 检查代码质量
echo "Running code quality checks..."
make lint
make security-scan

# 5. 检查依赖安全性
echo "Checking dependency security..."
go list -json -deps ./... | nancy sleuth

# 6. 构建所有平台
echo "Building all platforms..."
make build-all

echo "✅ Pre-release checks completed!"
```

#### 版本号确定
```bash
#!/bin/bash
# determine-version.sh

CURRENT_VERSION=$(git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0")
echo "Current version: $CURRENT_VERSION"

# 分析提交类型
COMMITS_SINCE=$(git rev-list ${CURRENT_VERSION}..HEAD --count)
echo "Commits since last tag: $COMMITS_SINCE"

# 检查是否有破坏性变更
BREAKING_CHANGES=$(git log ${CURRENT_VERSION}..HEAD --grep="BREAKING CHANGE" --oneline | wc -l)

# 检查是否有新功能
NEW_FEATURES=$(git log ${CURRENT_VERSION}..HEAD --grep="feat:" --oneline | wc -l)

# 检查是否有修复
BUG_FIXES=$(git log ${CURRENT_VERSION}..HEAD --grep="fix:" --oneline | wc -l)

if [ $BREAKING_CHANGES -gt 0 ]; then
    echo "📈 Suggested version bump: MAJOR (breaking changes detected)"
elif [ $NEW_FEATURES -gt 0 ]; then
    echo "📈 Suggested version bump: MINOR (new features detected)"
elif [ $BUG_FIXES -gt 0 ]; then
    echo "📈 Suggested version bump: PATCH (bug fixes detected)"
else
    echo "ℹ️ No significant changes detected"
fi
```

### 2. 版本标记和构建

#### 创建发布分支
```bash
#!/bin/bash
# create-release-branch.sh

VERSION=${1:?"Version is required (e.g., v1.3.0)"}

echo "Creating release branch for $VERSION..."

# 创建发布分支
git checkout -b "release/$VERSION"

# 更新版本信息
echo "Updating version information..."
sed -i "s/Version.*=.*/Version = \"$VERSION\"/" cmd/fyneterm/main.go

# 更新 CHANGELOG
echo "Updating CHANGELOG.md..."
./scripts/update-changelog.sh $VERSION

# 提交版本更新
git add .
git commit -m "chore: prepare release $VERSION"

# 推送发布分支
git push origin "release/$VERSION"

echo "✅ Release branch created: release/$VERSION"
```

#### 自动化构建脚本
```bash
#!/bin/bash
# build-release.sh

VERSION=${1:?"Version is required"}
BUILD_DIR="build/$VERSION"

echo "🔨 Building Magic Terminal $VERSION..."

# 清理之前的构建
rm -rf $BUILD_DIR
mkdir -p $BUILD_DIR

# 设置构建变量
export CGO_ENABLED=1
export BUILD_TIME=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
export GIT_COMMIT=$(git rev-parse HEAD)

# 构建标志
LDFLAGS="-X main.Version=$VERSION -X main.BuildTime=$BUILD_TIME -X main.GitCommit=$GIT_COMMIT"

# 构建所有平台的 CLI 版本
platforms=(
    "linux/amd64"
    "linux/arm64"
    "darwin/amd64"
    "darwin/arm64"
    "windows/amd64"
)

for platform in "${platforms[@]}"; do
    IFS='/' read -r GOOS GOARCH <<< "$platform"
    binary_name="magic-terminal-$GOOS-$GOARCH"
    
    if [ "$GOOS" = "windows" ]; then
        binary_name="$binary_name.exe"
    fi
    
    echo "Building for $GOOS/$GOARCH..."
    env GOOS=$GOOS GOARCH=$GOARCH go build \
        -ldflags="$LDFLAGS" \
        -o "$BUILD_DIR/$binary_name" \
        ./cmd/fyneterm/
done

# 构建 GUI 应用程序
echo "Building GUI applications..."

# macOS App Bundle
echo "Building macOS app..."
fyne package -os darwin -o "$BUILD_DIR/Magic-Terminal.app" ./cmd/fyneterm/

# Windows 可执行文件
echo "Building Windows executable..."
fyne package -os windows -o "$BUILD_DIR/Magic-Terminal.exe" ./cmd/fyneterm/

# Linux AppImage
echo "Building Linux AppImage..."
fyne package -os linux -o "$BUILD_DIR/Magic-Terminal.AppImage" ./cmd/fyneterm/

echo "✅ Build completed: $BUILD_DIR"
```

### 3. 测试验证

#### 发布测试套件
```bash
#!/bin/bash
# release-test-suite.sh

VERSION=${1:?"Version is required"}
BUILD_DIR="build/$VERSION"

echo "🧪 Running release test suite for $VERSION..."

# 1. 基本功能测试
echo "Running basic functionality tests..."
for binary in $BUILD_DIR/magic-terminal-*; do
    if [[ $binary == *.exe ]]; then
        continue # Skip Windows binaries on non-Windows
    fi
    
    echo "Testing $binary..."
    timeout 10s $binary --version
    if [ $? -eq 0 ]; then
        echo "✅ $binary version check passed"
    else
        echo "❌ $binary version check failed"
        exit 1
    fi
done

# 2. GUI 应用测试
echo "Testing GUI applications..."
if [ -f "$BUILD_DIR/Magic-Terminal.app/Contents/MacOS/Magic-Terminal" ]; then
    echo "✅ macOS app bundle structure verified"
fi

# 3. 安装包测试
echo "Running installation tests..."
./scripts/test-installation.sh $VERSION

# 4. 回归测试
echo "Running regression tests..."
make test-regression

# 5. 性能基准测试
echo "Running performance benchmarks..."
make benchmark

echo "✅ Release test suite completed!"
```

#### 用户验收测试
```markdown
## 用户验收测试清单

### 基本功能验证
- [ ] 应用程序正常启动
- [ ] 终端会话创建成功
- [ ] 文本输入输出正常
- [ ] 颜色显示正确
- [ ] 快捷键功能正常

### 平台特定测试
#### Linux
- [ ] AppImage 可以运行
- [ ] 系统集成正常
- [ ] 包管理器安装测试

#### macOS
- [ ] .app 包可以启动
- [ ] 代码签名验证通过
- [ ] macOS 通知中心集成

#### Windows
- [ ] .exe 文件可以运行
- [ ] Windows 防火墙通过
- [ ] 开始菜单集成

### 性能测试
- [ ] 启动时间 < 3 秒
- [ ] 内存使用 < 100MB
- [ ] CPU 使用率正常
- [ ] 大量输出处理流畅

### 兼容性测试
- [ ] 各种 Shell 兼容 (bash, zsh, fish)
- [ ] Unicode 字符显示
- [ ] 不同分辨率适配
- [ ] 主题切换正常
```

### 4. 发布执行

#### 自动发布脚本
```bash
#!/bin/bash
# release.sh - 完整发布脚本

VERSION=${1:?"Version is required (e.g., v1.3.0)"}
RELEASE_TYPE=${2:-"stable"} # stable, alpha, beta, rc

echo "🚀 Releasing Magic Terminal $VERSION ($RELEASE_TYPE)..."

# 1. 发布前检查
echo "Step 1: Pre-release checks..."
./scripts/pre-release-check.sh

# 2. 创建发布分支
echo "Step 2: Creating release branch..."
./scripts/create-release-branch.sh $VERSION

# 3. 构建所有平台
echo "Step 3: Building release..."
./scripts/build-release.sh $VERSION

# 4. 运行测试套件
echo "Step 4: Running tests..."
./scripts/release-test-suite.sh $VERSION

# 5. 创建发布说明
echo "Step 5: Generating release notes..."
./scripts/generate-release-notes.sh $VERSION

# 6. 创建 Git 标签
echo "Step 6: Creating Git tag..."
git tag -a $VERSION -m "Release $VERSION"
git push origin $VERSION

# 7. 创建 GitHub Release
echo "Step 7: Creating GitHub release..."
gh release create $VERSION \
    --title "Magic Terminal $VERSION" \
    --notes-file "release-notes/$VERSION.md" \
    build/$VERSION/*

# 8. 发布到包管理器
echo "Step 8: Publishing to package managers..."
./scripts/publish-packages.sh $VERSION

# 9. 发布后检查
echo "Step 9: Post-release verification..."
./scripts/post-release-check.sh $VERSION

echo "✅ Release $VERSION completed successfully!"
```

#### GitHub Release 自动化
```yaml
# .github/workflows/release.yml
name: Release

on:
  push:
    tags:
      - 'v*'

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
      with:
        fetch-depth: 0
    
    - name: Set up Go
      uses: actions/setup-go@v4
      with:
        go-version: '1.23'
    
    - name: Install dependencies
      run: |
        sudo apt-get update
        sudo apt-get install -y libgl1-mesa-dev xorg-dev
    
    - name: Build release
      run: |
        make build-all
        make package-all
    
    - name: Generate release notes
      run: |
        ./scripts/generate-release-notes.sh ${GITHUB_REF#refs/tags/}
    
    - name: Create Release
      uses: softprops/action-gh-release@v1
      with:
        files: |
          dist/*
        body_path: release-notes/latest.md
        draft: false
        prerelease: ${{ contains(github.ref, 'alpha') || contains(github.ref, 'beta') || contains(github.ref, 'rc') }}
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
    
    - name: Publish to package managers
      run: ./scripts/publish-packages.sh
      env:
        HOMEBREW_TOKEN: ${{ secrets.HOMEBREW_TOKEN }}
        CHOCOLATEY_API_KEY: ${{ secrets.CHOCOLATEY_API_KEY }}
```

### 5. 包管理器发布

#### Homebrew 发布
```ruby
# Formula/magic-terminal.rb
class MagicTerminal < Formula
  desc "Modern terminal emulator built with Fyne"
  homepage "https://github.com/wangyiyang/Magic-Terminal"
  url "https://github.com/wangyiyang/Magic-Terminal/archive/v1.3.0.tar.gz"
  sha256 "abc123..."
  license "MIT"

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w"), "./cmd/fyneterm"
  end

  test do
    assert_match "Magic Terminal v1.3.0", shell_output("#{bin}/magic-terminal --version")
  end
end
```

#### Chocolatey 发布
```xml
<!-- magic-terminal.nuspec -->
<?xml version="1.0" encoding="utf-8"?>
<package xmlns="http://schemas.microsoft.com/packaging/2015/06/nuspec.xsd">
  <metadata>
    <id>magic-terminal</id>
    <version>1.3.0</version>
    <title>Magic Terminal</title>
    <authors>Magic Terminal Team</authors>
    <projectUrl>https://github.com/wangyiyang/Magic-Terminal</projectUrl>
    <description>Modern terminal emulator built with Fyne</description>
    <tags>terminal emulator console cli fyne go</tags>
    <licenseUrl>https://github.com/wangyiyang/Magic-Terminal/blob/main/LICENSE</licenseUrl>
  </metadata>
  <files>
    <file src="tools\**" target="tools" />
  </files>
</package>
```

#### APT 仓库发布
```bash
#!/bin/bash
# publish-apt.sh

VERSION=${1:?"Version is required"}

echo "Publishing to APT repository..."

# 构建 DEB 包
fpm -s dir -t deb \
    --name magic-terminal \
    --version ${VERSION#v} \
    --description "Modern terminal emulator" \
    --license MIT \
    --vendor "Magic Terminal Team" \
    --maintainer "team@magic-terminal.com" \
    --url "https://github.com/wangyiyang/Magic-Terminal" \
    --depends "libc6" \
    --depends "libgl1-mesa-glx" \
    build/$VERSION/magic-terminal-linux-amd64=/usr/bin/magic-terminal

# 上传到 APT 仓库
curl -F package=@magic-terminal_${VERSION#v}_amd64.deb \
     -H "Authorization: Bearer $APT_TOKEN" \
     https://apt.magic-terminal.com/upload
```

## 📊 发布后监控

### 1. 发布验证

#### 自动化验证脚本
```bash
#!/bin/bash
# post-release-check.sh

VERSION=${1:?"Version is required"}

echo "📋 Post-release verification for $VERSION..."

# 1. 检查 GitHub Release
echo "Checking GitHub release..."
RELEASE_STATUS=$(gh release view $VERSION --json state --jq .state)
if [ "$RELEASE_STATUS" = "published" ]; then
    echo "✅ GitHub release is published"
else
    echo "❌ GitHub release issue: $RELEASE_STATUS"
fi

# 2. 检查下载链接
echo "Checking download links..."
for asset in $(gh release view $VERSION --json assets --jq '.assets[].browserDownloadUrl'); do
    HTTP_STATUS=$(curl -s -I "$asset" | head -n1 | awk '{print $2}')
    if [ "$HTTP_STATUS" = "200" ]; then
        echo "✅ $asset - OK"
    else
        echo "❌ $asset - $HTTP_STATUS"
    fi
done

# 3. 检查包管理器
echo "Checking package managers..."

# Homebrew
if brew search magic-terminal | grep -q "magic-terminal"; then
    echo "✅ Homebrew package available"
else
    echo "⏳ Homebrew package pending"
fi

# Chocolatey
if choco search magic-terminal | grep -q "magic-terminal"; then
    echo "✅ Chocolatey package available"
else
    echo "⏳ Chocolatey package pending"
fi

echo "✅ Post-release verification completed!"
```

### 2. 发布指标监控

#### 下载统计
```bash
#!/bin/bash
# download-stats.sh

VERSION=${1:-"latest"}

echo "📊 Download statistics for $VERSION..."

# GitHub Release 下载统计
gh release view $VERSION --json assets \
    --jq '.assets[] | "\(.name): \(.downloadCount) downloads"'

# 总下载量
TOTAL=$(gh release view $VERSION --json assets \
    --jq '.assets | map(.downloadCount) | add')
echo "Total downloads: $TOTAL"

# 平台分布
echo -e "\nPlatform distribution:"
gh release view $VERSION --json assets \
    --jq '.assets[] | select(.name | contains("linux")) | "\(.name): \(.downloadCount)"' | \
    awk -F: '{linux+=$2} END {print "Linux: " linux}'

gh release view $VERSION --json assets \
    --jq '.assets[] | select(.name | contains("darwin")) | "\(.name): \(.downloadCount)"' | \
    awk -F: '{darwin+=$2} END {print "macOS: " darwin}'

gh release view $VERSION --json assets \
    --jq '.assets[] | select(.name | contains("windows")) | "\(.name): \(.downloadCount)"' | \
    awk -F: '{windows+=$2} END {print "Windows: " windows}'
```

#### 用户反馈监控
```python
#!/usr/bin/env python3
# monitor-feedback.py

import requests
import json
from datetime import datetime, timedelta

def monitor_github_issues():
    """监控 GitHub Issues 中的用户反馈"""
    url = "https://api.github.com/repos/wangyiyang/Magic-Terminal/issues"
    params = {
        "state": "open",
        "labels": "bug,feedback",
        "since": (datetime.now() - timedelta(days=7)).isoformat()
    }
    
    response = requests.get(url, params=params)
    issues = response.json()
    
    print(f"📋 New issues in the last 7 days: {len(issues)}")
    
    for issue in issues:
        print(f"- #{issue['number']}: {issue['title']}")
        print(f"  Created: {issue['created_at']}")
        print(f"  Labels: {[label['name'] for label in issue['labels']]}")

def monitor_social_media():
    """监控社交媒体提及"""
    # Twitter API 监控
    # Reddit API 监控
    # HackerNews API 监控
    pass

if __name__ == "__main__":
    monitor_github_issues()
    monitor_social_media()
```

### 3. 问题响应

#### 问题分类和优先级
```markdown
## 发布后问题分类

### 🔴 P0 - 严重问题 (2小时内响应)
- 应用程序无法启动
- 数据丢失或损坏
- 安全漏洞
- 系统崩溃

### 🟡 P1 - 重要问题 (24小时内响应)
- 核心功能异常
- 性能严重下降
- 平台兼容性问题
- 用户体验影响

### 🟢 P2 - 一般问题 (72小时内响应)
- 小功能缺陷
- UI/UX 问题
- 文档问题
- 功能增强请求

### 🔵 P3 - 低优先级 (一周内响应)
- 美化建议
- 边界情况
- 非关键功能
```

#### 热修复流程
```bash
#!/bin/bash
# hotfix-release.sh

ISSUE=${1:?"Issue description is required"}
BASE_VERSION=${2:?"Base version is required (e.g., v1.3.0)"}

echo "🚨 Creating hotfix for: $ISSUE"

# 生成热修复版本号
HOTFIX_VERSION="${BASE_VERSION}-hotfix.$(date +%Y%m%d%H%M)"

# 创建热修复分支
git checkout $BASE_VERSION
git checkout -b "hotfix/$HOTFIX_VERSION"

echo "Created hotfix branch: hotfix/$HOTFIX_VERSION"
echo "Please make your changes and then run:"
echo "  git add ."
echo "  git commit -m 'hotfix: $ISSUE'"
echo "  ./scripts/build-release.sh $HOTFIX_VERSION"
echo "  ./scripts/release.sh $HOTFIX_VERSION hotfix"
```

## 📋 发布清单

### 发布前清单
```markdown
## 发布前检查清单

### 🔍 代码质量
- [ ] 所有测试通过
- [ ] 代码审查完成
- [ ] 静态分析无严重问题
- [ ] 安全扫描通过
- [ ] 性能基准测试通过

### 📝 文档更新
- [ ] README 更新
- [ ] CHANGELOG 更新
- [ ] API 文档更新
- [ ] 用户指南更新
- [ ] 发布说明准备

### 🏗️ 构建验证
- [ ] 所有平台构建成功
- [ ] 包依赖验证
- [ ] 安装测试通过
- [ ] 签名和公证完成

### 🎯 发布准备
- [ ] 版本号确认
- [ ] 发布分支创建
- [ ] 标签准备就绪
- [ ] 发布说明审核
- [ ] 团队通知发送
```

### 发布后清单
```markdown
## 发布后检查清单

### 📊 发布验证
- [ ] GitHub Release 可访问
- [ ] 下载链接正常
- [ ] 安装包可用
- [ ] 版本信息正确

### 📢 通知发布
- [ ] 官方博客更新
- [ ] 社交媒体发布
- [ ] 邮件列表通知
- [ ] Discord/Slack 通知
- [ ] 合作伙伴通知

### 📈 监控设置
- [ ] 下载统计监控
- [ ] 错误报告监控
- [ ] 用户反馈监控
- [ ] 性能指标监控
- [ ] 社区讨论监控

### 🔄 后续计划
- [ ] 下个版本规划
- [ ] 热修复准备
- [ ] 用户支持准备
- [ ] 文档维护计划
```

## 📚 参考资源

### 工具和服务
- **GitHub Actions**: CI/CD 自动化
- **GoReleaser**: Go 项目发布工具
- **Fyne Package**: GUI 应用打包
- **Docker**: 容器化部署
- **Homebrew**: macOS 包管理
- **Chocolatey**: Windows 包管理

### 最佳实践
- [语义化版本](https://semver.org/)
- [常规提交](https://www.conventionalcommits.org/)
- [Keep a Changelog](https://keepachangelog.com/)
- [GitHub Release 最佳实践](https://docs.github.com/en/repositories/releasing-projects-on-github/managing-releases-in-a-repository)

通过遵循这个系统化的发布流程，Magic Terminal 项目能够确保高质量、可靠的软件发布，为用户提供稳定的产品体验。
