# Magic Terminal 构建和部署指南

## 🏗️ 构建系统概览

Magic Terminal 使用 Go 语言构建系统和 Make 脚本，支持多平台交叉编译和自动化部署。

### 构建工具链
- **Go 1.23+**: 主要编译器
- **Make**: 构建脚本管理
- **CGO**: C 语言绑定支持
- **Fyne**: GUI 框架和打包工具
- **Docker**: 容器化构建环境

## 📋 系统要求

### 开发环境要求

| 组件 | 版本要求 | 说明 |
|------|----------|------|
| Go | 1.23.0+ | 支持泛型和最新特性 |
| Make | 任意版本 | 构建脚本管理 |
| GCC/Clang | 支持 C11 | CGO 编译需要 |
| Git | 2.0+ | 版本控制和依赖管理 |

### 平台特定要求

#### Linux
```bash
# Ubuntu/Debian
sudo apt install build-essential libgl1-mesa-dev xorg-dev

# CentOS/RHEL/Fedora
sudo yum groupinstall "Development Tools"
sudo yum install mesa-libGL-devel libX11-devel libXcursor-devel libXrandr-devel
```

#### macOS
```bash
# 安装 Xcode Command Line Tools
xcode-select --install

# 或安装完整的 Xcode
```

#### Windows
```bash
# 使用 Chocolatey 安装工具链
choco install golang mingw make

# 或使用 MSYS2
pacman -S mingw-w64-x86_64-toolchain mingw-w64-x86_64-go
```

## 🔧 本地构建

### 快速构建

```bash
# 克隆项目
git clone https://github.com/wangyiyang/Magic-Terminal.git
cd Magic-Terminal

# 安装依赖
go mod download

# 构建应用程序
make build

# 运行应用程序
./bin/magic-terminal
```

### 详细构建选项

#### 开发构建
```bash
# 带调试信息的构建
make build-dev

# 启用竞态检测
make build-race

# 开发模式运行
make dev
```

#### 生产构建
```bash
# 优化构建（去除调试信息，压缩二进制）
make build-release

# 静态链接构建
make build-static

# 最小化构建
make build-minimal
```

### 构建配置

#### Makefile 主要变量

```makefile
# 应用程序信息
APP_NAME := magic-terminal
VERSION := $(shell git describe --tags --always --dirty)
BUILD_TIME := $(shell date -u '+%Y-%m-%d_%H:%M:%S')
COMMIT_HASH := $(shell git rev-parse --short HEAD)

# 构建标志
LDFLAGS := -ldflags "-X main.version=$(VERSION) \
                     -X main.buildTime=$(BUILD_TIME) \
                     -X main.commitHash=$(COMMIT_HASH)"

# 优化标志
RELEASE_FLAGS := $(LDFLAGS) -ldflags "-s -w" -trimpath
DEBUG_FLAGS := $(LDFLAGS) -gcflags "all=-N -l"
```

#### 环境变量配置

```bash
# 设置构建环境
export CGO_ENABLED=1
export GO111MODULE=on
export GOPROXY=https://proxy.golang.org,direct

# 优化设置
export GOMAXPROCS=$(nproc)
export CGO_CFLAGS="-O2 -g"
export CGO_LDFLAGS="-O2"
```

## 🌐 交叉编译

### 支持的平台

```bash
# 查看支持的平台
go tool dist list | grep -E "(linux|darwin|windows|freebsd|openbsd)"
```

### 单平台构建

```bash
# Linux AMD64
GOOS=linux GOARCH=amd64 make build-cross

# macOS ARM64 (Apple Silicon)
GOOS=darwin GOARCH=arm64 make build-cross

# Windows AMD64
GOOS=windows GOARCH=amd64 make build-cross
```

### 批量交叉编译

```bash
# 构建所有支持的平台
make build-all

# 构建主要平台
make build-main-platforms

# 构建特定平台组合
make build-desktop    # Linux, macOS, Windows
make build-unix       # Linux, macOS, FreeBSD, OpenBSD
```

#### 交叉编译脚本

```bash
#!/bin/bash
# scripts/cross-compile.sh

set -e

PLATFORMS=(
    "linux/amd64"
    "linux/arm64"
    "darwin/amd64" 
    "darwin/arm64"
    "windows/amd64"
    "freebsd/amd64"
    "openbsd/amd64"
)

DIST_DIR="dist"
mkdir -p "$DIST_DIR"

for platform in "${PLATFORMS[@]}"; do
    IFS='/' read -r GOOS GOARCH <<< "$platform"
    
    output_name="magic-terminal-${GOOS}-${GOARCH}"
    if [[ "$GOOS" == "windows" ]]; then
        output_name="${output_name}.exe"
    fi
    
    echo "🔨 构建 $GOOS/$GOARCH..."
    
    CGO_ENABLED=1 \
    GOOS=$GOOS \
    GOARCH=$GOARCH \
    go build \
        -ldflags="-s -w -X main.version=${VERSION}" \
        -trimpath \
        -o "${DIST_DIR}/${output_name}" \
        ./cmd/fyneterm
    
    echo "✅ 完成: ${output_name}"
done

echo "🎉 所有平台构建完成！"
```

### 交叉编译优化

#### CGO 交叉编译

```bash
# 安装交叉编译工具链
# Ubuntu/Debian
sudo apt install gcc-aarch64-linux-gnu gcc-mingw-w64

# 设置交叉编译环境
export CC_linux_arm64=aarch64-linux-gnu-gcc
export CC_windows_amd64=x86_64-w64-mingw32-gcc

# 执行交叉编译
make build-cross-cgo
```

#### Docker 交叉编译

```dockerfile
# Dockerfile.cross-compile
FROM golang:1.24-alpine AS builder

RUN apk add --no-cache \
    gcc g++ musl-dev \
    libx11-dev libxcursor-dev libxrandr-dev \
    libgl1-mesa-dev

WORKDIR /app
COPY . .

RUN make build-all

FROM scratch
COPY --from=builder /app/dist/* /dist/
```

```bash
# 使用 Docker 进行交叉编译
docker build -f Dockerfile.cross-compile -t magic-terminal-builder .
docker run --rm -v $(pwd)/dist:/output magic-terminal-builder cp -r /dist/* /output/
```

## 📦 应用程序打包

### GUI 应用打包

#### 使用 Fyne 工具

```bash
# 安装 Fyne 打包工具
go install fyne.io/fyne/v2/cmd/fyne@latest

# 打包当前平台
fyne package -o magic-terminal.app

# 打包指定平台
fyne package -os darwin -o magic-terminal.app
fyne package -os windows -o magic-terminal.exe
fyne package -os linux -o magic-terminal.tar.gz
```

#### 平台特定打包

##### macOS 应用包

```bash
# 创建 .app 包结构
make package-macos

# 生成的结构
Magic\ Terminal.app/
├── Contents/
│   ├── Info.plist
│   ├── MacOS/
│   │   └── magic-terminal
│   └── Resources/
│       └── icon.icns
```

```xml
<!-- Contents/Info.plist -->
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>magic-terminal</string>
    <key>CFBundleIdentifier</key>
    <string>com.magic-terminal.app</string>
    <key>CFBundleName</key>
    <string>Magic Terminal</string>
    <key>CFBundleVersion</key>
    <string>1.0.0</string>
    <key>LSMinimumSystemVersion</key>
    <string>10.14</string>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
```

##### Windows 安装包

```bash
# 使用 Inno Setup 创建安装程序
make package-windows

# 或使用 WiX Toolset
make package-msi
```

```ini
; magic-terminal.iss (Inno Setup 脚本)
[Setup]
AppName=Magic Terminal
AppVersion=1.0.0
DefaultDirName={pf}\Magic Terminal
DefaultGroupName=Magic Terminal
OutputDir=dist
OutputBaseFilename=magic-terminal-setup

[Files]
Source: "magic-terminal.exe"; DestDir: "{app}"
Source: "README.md"; DestDir: "{app}"
Source: "LICENSE"; DestDir: "{app}"

[Icons]
Name: "{group}\Magic Terminal"; Filename: "{app}\magic-terminal.exe"
Name: "{commondesktop}\Magic Terminal"; Filename: "{app}\magic-terminal.exe"
```

##### Linux 包管理

```bash
# 创建 .deb 包
make package-deb

# 创建 .rpm 包
make package-rpm

# 创建 AppImage
make package-appimage

# 创建 Flatpak
make package-flatpak

# 创建 Snap
make package-snap
```

### 容器化构建

#### Dockerfile

```dockerfile
# Dockerfile
FROM golang:1.24-alpine AS builder

# 安装构建依赖
RUN apk add --no-cache \
    gcc g++ musl-dev \
    libx11-dev libxcursor-dev libxrandr-dev \
    libgl1-mesa-dev git make

WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN make build-release

# 运行时镜像
FROM alpine:latest
RUN apk add --no-cache \
    libx11 libxcursor libxrandr \
    mesa-gl ca-certificates

WORKDIR /app
COPY --from=builder /app/bin/magic-terminal /usr/local/bin/

ENTRYPOINT ["magic-terminal"]
```

#### Docker Compose

```yaml
# docker-compose.yml
version: '3.8'

services:
  magic-terminal:
    build: .
    environment:
      - DISPLAY=${DISPLAY}
    volumes:
      - /tmp/.X11-unix:/tmp/.X11-unix:rw
      - ${HOME}:/home/user
    network_mode: host
    stdin_open: true
    tty: true
```

## 🚀 自动化部署

### GitHub Actions CI/CD

#### 构建工作流

```yaml
# .github/workflows/build.yml
name: Build and Release

on:
  push:
    tags:
      - 'v*'
  workflow_dispatch:
    inputs:
      version:
        description: 'Version to build'
        required: true

jobs:
  build:
    strategy:
      matrix:
        os: [ubuntu-latest, macos-latest, windows-latest]
        go-version: [1.23, 1.24]
    
    runs-on: ${{ matrix.os }}
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Set up Go
      uses: actions/setup-go@v3
      with:
        go-version: ${{ matrix.go-version }}
    
    - name: Install dependencies (Linux)
      if: matrix.os == 'ubuntu-latest'
      run: |
        sudo apt-get update
        sudo apt-get install -y libgl1-mesa-dev xorg-dev
    
    - name: Build
      run: make build-release
    
    - name: Test
      run: make test
    
    - name: Package
      run: make package
    
    - name: Upload artifacts
      uses: actions/upload-artifact@v3
      with:
        name: magic-terminal-${{ matrix.os }}
        path: dist/*
```

#### 发布工作流

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
    - uses: actions/checkout@v3
      with:
        fetch-depth: 0
    
    - name: Set up Go
      uses: actions/setup-go@v3
      with:
        go-version: 1.24
    
    - name: Install dependencies
      run: |
        sudo apt-get update
        sudo apt-get install -y libgl1-mesa-dev xorg-dev
    
    - name: Cross compile
      run: make build-all
    
    - name: Package all platforms
      run: make package-all
    
    - name: Generate changelog
      run: make changelog
    
    - name: Create Release
      uses: actions/create-release@v1
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
      with:
        tag_name: ${{ github.ref }}
        release_name: Release ${{ github.ref }}
        body_path: CHANGELOG.md
        draft: false
        prerelease: false
    
    - name: Upload Release Assets
      uses: actions/upload-release-asset@v1
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
      with:
        upload_url: ${{ steps.create_release.outputs.upload_url }}
        asset_path: ./dist/*
```

### 发布脚本

#### 自动发布脚本

```bash
#!/bin/bash
# scripts/release.sh

set -e

VERSION="$1"
if [[ -z "$VERSION" ]]; then
    echo "用法: $0 <version>"
    echo "示例: $0 v1.0.0"
    exit 1
fi

echo "🚀 开始发布 Magic Terminal $VERSION"

# 验证版本格式
if [[ ! "$VERSION" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "❌ 版本格式错误，应该是 vX.Y.Z 格式"
    exit 1
fi

# 检查工作目录是否干净
if [[ -n $(git status --porcelain) ]]; then
    echo "❌ 工作目录不干净，请先提交所有更改"
    exit 1
fi

# 确保在主分支上
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [[ "$CURRENT_BRANCH" != "main" ]]; then
    echo "❌ 必须在 main 分支上进行发布"
    exit 1
fi

# 更新版本信息
echo "📝 更新版本信息..."
sed -i "s/version = \".*\"/version = \"$VERSION\"/" cmd/fyneterm/main.go

# 运行测试
echo "🧪 运行测试..."
make test

# 构建所有平台
echo "🔨 构建所有平台..."
make build-all

# 打包应用程序
echo "📦 打包应用程序..."
make package-all

# 生成变更日志
echo "📋 生成变更日志..."
make changelog

# 创建 Git 标签
echo "🏷️ 创建 Git 标签..."
git add -A
git commit -m "chore: release $VERSION"
git tag -a "$VERSION" -m "Release $VERSION"

# 推送到远程仓库
echo "⬆️ 推送到远程仓库..."
git push origin main
git push origin "$VERSION"

echo "✅ 发布完成！"
echo "🌐 GitHub Actions 将自动创建 Release 和上传文件"
echo "📦 Release 页面: https://github.com/wangyiyang/Magic-Terminal/releases/tag/$VERSION"
```

## 📊 构建优化

### 编译优化

#### 构建标志优化

```makefile
# 基础优化
BASIC_FLAGS := -trimpath -mod=readonly

# 大小优化
SIZE_FLAGS := $(BASIC_FLAGS) -ldflags="-s -w"

# 性能优化
PERF_FLAGS := $(BASIC_FLAGS) -ldflags="-s" -gcflags="all=-l=4"

# 调试优化
DEBUG_FLAGS := $(BASIC_FLAGS) -gcflags="all=-N -l" -race
```

#### CGO 优化

```bash
# CGO 优化环境变量
export CGO_CFLAGS="-O3 -flto -march=native"
export CGO_LDFLAGS="-O3 -flto"
export CGO_CPPFLAGS="-DNDEBUG"
```

### 并行构建

```bash
# 设置并行构建
export GOMAXPROCS=$(nproc)

# 并行测试
go test -parallel $(nproc) ./...

# 并行交叉编译
make -j$(nproc) build-all
```

### 缓存优化

```bash
# 启用构建缓存
export GOCACHE="$(go env GOCACHE)"
export GOMODCACHE="$(go env GOMODCACHE)"

# 预热模块缓存
go mod download

# 预构建标准库
go install -a std
```

## 🔍 构建验证

### 自动化测试

```bash
# 构建验证脚本
#!/bin/bash
# scripts/verify-build.sh

set -e

echo "🔍 验证构建结果..."

# 检查二进制文件
for binary in dist/*; do
    if [[ -f "$binary" ]]; then
        echo "✅ 检查 $binary"
        
        # 检查文件大小
        size=$(stat -f%z "$binary" 2>/dev/null || stat -c%s "$binary")
        if [[ $size -lt 1000000 ]]; then  # 小于 1MB
            echo "⚠️  警告: $binary 文件太小 ($size bytes)"
        fi
        
        # 检查是否为有效的可执行文件
        if [[ "$binary" == *.exe ]]; then
            # Windows 可执行文件检查
            file "$binary" | grep -q "PE32"
        else
            # Unix 可执行文件检查
            file "$binary" | grep -q "executable"
        fi
        
        echo "✅ $binary 验证通过"
    fi
done

echo "🎉 所有构建验证完成！"
```

### 性能基准

```bash
# 构建性能测试
#!/bin/bash
# scripts/benchmark-build.sh

echo "📊 构建性能基准测试..."

# 清理构建缓存
go clean -cache

# 测量构建时间
time make build

# 测量交叉编译时间
time make build-all

# 测量测试时间
time make test

echo "📈 基准测试完成"
```

---

更多信息请参考：
- [开发环境配置](./development-setup.md)
- [CI/CD 系统](./CI-CD.md)
- [平台兼容性](./platform-compatibility.md)
