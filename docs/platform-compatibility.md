# Magic Terminal 平台兼容性文档

## 🖥️ 支持平台总览

Magic Terminal 设计为跨平台终端模拟器，支持主流操作系统和架构。

### 完全支持的平台

| 操作系统 | 架构 | 状态 | 特殊说明 |
|----------|------|------|----------|
| Linux | amd64 | ✅ 完全支持 | 主要开发平台 |
| Linux | arm64 | ✅ 完全支持 | 包括 Raspberry Pi |
| macOS | amd64 | ✅ 完全支持 | Intel Mac |
| macOS | arm64 | ✅ 完全支持 | Apple Silicon (M1/M2) |
| Windows | amd64 | ✅ 完全支持 | Windows 10+ |
| FreeBSD | amd64 | ⚠️ 基础支持 | 社区维护 |
| OpenBSD | amd64 | ⚠️ 基础支持 | 社区维护 |

### 实验性支持

| 平台 | 状态 | 说明 |
|------|------|------|
| Windows ARM64 | 🧪 实验性 | Windows on ARM |
| Linux RISC-V | 🧪 实验性 | 新兴架构 |
| Android | 📋 计划中 | Termux 环境 |
| iOS | 📋 计划中 | 受限环境 |

## 🐧 Linux 平台

### 支持的发行版

#### 主流发行版
- **Ubuntu**: 18.04 LTS+
- **Debian**: 10 (Buster)+
- **CentOS/RHEL**: 7+
- **Fedora**: 30+
- **openSUSE**: Leap 15+
- **Arch Linux**: 滚动发布

#### 嵌入式发行版
- **Raspberry Pi OS**: Buster+
- **Alpine Linux**: 3.10+
- **Buildroot**: 自定义构建

### 依赖要求

#### 运行时依赖
```bash
# Debian/Ubuntu
sudo apt install libgl1-mesa-glx libxi6 libxrandr2 libxcursor1

# RHEL/CentOS/Fedora
sudo yum install mesa-libGL libXi libXrandr libXcursor

# Arch Linux
sudo pacman -S mesa libxi libxrandr libxcursor
```

#### 开发依赖
```bash
# Debian/Ubuntu
sudo apt install build-essential libgl1-mesa-dev xorg-dev

# RHEL/CentOS/Fedora
sudo yum groupinstall "Development Tools"
sudo yum install mesa-libGL-devel libX11-devel libXcursor-devel libXrandr-devel libXinerama-devel libXi-devel

# Arch Linux
sudo pacman -S base-devel mesa xorg-dev
```

### 桌面环境支持

| 桌面环境 | 支持状态 | 特殊说明 |
|----------|----------|----------|
| GNOME | ✅ 完全支持 | 包括 Wayland |
| KDE Plasma | ✅ 完全支持 | X11 和 Wayland |
| XFCE | ✅ 完全支持 | 轻量级环境 |
| i3/sway | ✅ 完全支持 | 平铺窗口管理器 |
| Unity | ✅ 完全支持 | Ubuntu 经典桌面 |
| Cinnamon | ✅ 完全支持 | Linux Mint |
| MATE | ✅ 完全支持 | GNOME 2 分支 |

### 显示协议支持

#### X11
- ✅ 完全支持所有功能
- ✅ 硬件加速渲染
- ✅ 高 DPI 显示支持
- ✅ 多显示器支持

#### Wayland
- ✅ 基本功能支持
- ⚠️ 部分高级功能受限
- ✅ 原生 Wayland 应用
- ⚠️ 剪贴板访问限制

```go
// 检测显示协议
func detectDisplayProtocol() string {
    if os.Getenv("WAYLAND_DISPLAY") != "" {
        return "wayland"
    }
    if os.Getenv("DISPLAY") != "" {
        return "x11"
    }
    return "unknown"
}
```

## 🍎 macOS 平台

### 系统要求

#### 最低版本
- **macOS 10.14** (Mojave) 或更高版本
- **Xcode Command Line Tools** 或 Xcode

#### 推荐版本
- **macOS 12.0** (Monterey) 或更高版本
- 最新版本的开发工具

### 架构支持

#### Intel Mac (x86_64)
```bash
# 构建 Intel 版本
GOARCH=amd64 go build ./cmd/fyneterm
```

#### Apple Silicon (arm64)
```bash
# 构建 Apple Silicon 版本
GOARCH=arm64 go build ./cmd/fyneterm

# 通用二进制文件
lipo -create \
    magic-terminal-amd64 \
    magic-terminal-arm64 \
    -output magic-terminal-universal
```

### 平台特性

#### 原生集成
- ✅ 原生 macOS 外观
- ✅ 系统菜单栏集成
- ✅ Dock 图标支持
- ✅ 全屏模式支持
- ✅ Mission Control 集成

#### 性能优化
- ✅ Metal 渲染支持 (Apple Silicon)
- ✅ 硬件加速
- ✅ 电池优化
- ✅ 后台应用管理

```go
// macOS 特定配置
type macOSConfig struct {
    UseMetalRenderer   bool
    EnableRetina       bool
    FullscreenMode     bool
    HideFromDock       bool
}
```

### 已知问题

#### Intel Mac
- 某些老旧 GPU 可能存在渲染问题
- 建议更新到最新的 macOS 版本

#### Apple Silicon
- Rosetta 2 兼容性：Intel 构建的版本可以运行，但性能不如原生版本
- 某些第三方库可能需要原生 ARM64 版本

## 🪟 Windows 平台

### 系统要求

#### 最低版本
- **Windows 10** Build 1903 或更高版本
- **ConPTY API** 支持

#### 推荐版本
- **Windows 11** 或 Windows 10 最新版本
- **Windows Terminal** 作为默认终端

### Windows 特性支持

#### ConPTY 集成
```go
// Windows ConPTY 实现
type WindowsConPTY struct {
    hPC      syscall.Handle
    hPipeIn  syscall.Handle
    hPipeOut syscall.Handle
    process  *os.Process
}

func (w *WindowsConPTY) Start(shell string, args []string) error {
    // 创建 ConPTY
    var hPC syscall.Handle
    ret, _, err := procCreatePseudoConsole.Call(
        uintptr(w.size.X), uintptr(w.size.Y),
        uintptr(w.hPipeIn),
        uintptr(&hPC),
    )
    // ... 实现细节
}
```

#### 系统集成
- ✅ Windows 10/11 原生外观
- ✅ 任务栏集成
- ✅ 系统托盘支持
- ✅ Windows Terminal 集成
- ✅ 右键菜单注册

### 已知限制

#### ConPTY 限制
- 需要 Windows 10 Build 1903+
- 某些老版本可能存在兼容性问题
- 部分 ANSI 序列支持可能有差异

#### 性能考虑
- Windows Defender 可能影响启动速度
- 某些杀毒软件可能误报

```go
// 检测 ConPTY 支持
func hasConPTYSupport() bool {
    version := windows.RtlGetVersion()
    return version.MajorVersion > 10 || 
           (version.MajorVersion == 10 && version.BuildNumber >= 18362)
}
```

## 🔧 BSD 系统

### FreeBSD 支持

#### 系统要求
- **FreeBSD 12.0** 或更高版本
- **pkg** 包管理器

#### 安装依赖
```bash
# 安装开发依赖
sudo pkg install go git mesa-libs libX11 libXcursor libXrandr libXinerama libXi

# 编译安装
git clone https://github.com/wangyiyang/Magic-Terminal.git
cd Magic-Terminal
make build
```

#### 已知问题
- GPU 驱动兼容性可能存在问题
- 某些现代 GPU 功能可能不可用

### OpenBSD 支持

#### 系统要求
- **OpenBSD 6.8** 或更高版本
- **ports/packages** 系统

#### 安装依赖
```bash
# 安装依赖包
sudo pkg_add go git

# 手动编译依赖库（如需要）
```

## 📱 移动平台 (实验性)

### Android 支持

#### Termux 环境
```bash
# 在 Termux 中安装
pkg update
pkg install golang git
git clone https://github.com/wangyiyang/Magic-Terminal.git
cd Magic-Terminal
go build ./cmd/fyneterm
```

#### 限制
- 受限的文件系统访问
- 无法访问某些系统功能
- 性能可能受限

### iOS 支持

#### 计划功能
- 通过 iSH 或类似环境运行
- 受 iOS 沙盒限制影响
- 需要特殊的构建配置

## 🏗️ 交叉编译支持

### 构建脚本

```bash
#!/bin/bash
# scripts/build-cross-platform.sh

PLATFORMS=(
    "linux/amd64"
    "linux/arm64"
    "darwin/amd64"
    "darwin/arm64"
    "windows/amd64"
    "freebsd/amd64"
    "openbsd/amd64"
)

for platform in "${PLATFORMS[@]}"; do
    IFS='/' read -r GOOS GOARCH <<< "$platform"
    output="dist/magic-terminal-${GOOS}-${GOARCH}"
    
    if [[ "$GOOS" == "windows" ]]; then
        output="${output}.exe"
    fi
    
    echo "Building for $GOOS/$GOARCH..."
    CGO_ENABLED=1 GOOS=$GOOS GOARCH=$GOARCH go build \
        -ldflags="-s -w" \
        -o "$output" \
        ./cmd/fyneterm
done
```

### Docker 构建

```dockerfile
# Dockerfile.cross
FROM golang:1.24-alpine AS builder

# 安装交叉编译工具
RUN apk add --no-cache gcc g++ musl-dev

# 设置工作目录
WORKDIR /app

# 复制源码
COPY . .

# 构建所有平台
RUN make build-all

FROM scratch
COPY --from=builder /app/dist/* /
```

## 🔍 平台检测和适配

### 运行时检测

```go
package platform

import (
    "runtime"
    "os"
)

type Platform struct {
    OS           string
    Arch         string
    Version      string
    HasGUI       bool
    HasConPTY    bool
    DisplayType  string
}

func Detect() *Platform {
    p := &Platform{
        OS:   runtime.GOOS,
        Arch: runtime.GOARCH,
    }
    
    switch p.OS {
    case "linux":
        p.detectLinux()
    case "darwin":
        p.detectMacOS()
    case "windows":
        p.detectWindows()
    case "freebsd", "openbsd":
        p.detectBSD()
    }
    
    return p
}

func (p *Platform) detectLinux() {
    p.HasGUI = os.Getenv("DISPLAY") != "" || os.Getenv("WAYLAND_DISPLAY") != ""
    p.DisplayType = detectDisplayProtocol()
}

func (p *Platform) detectWindows() {
    p.HasConPTY = hasConPTYSupport()
    p.HasGUI = true // Windows 总是有 GUI
}
```

### 适配策略

```go
// 平台特定的配置适配
func (c *Config) AdaptToPlatform(platform *Platform) {
    switch platform.OS {
    case "darwin":
        c.adaptMacOS()
    case "windows":
        c.adaptWindows()
    case "linux":
        c.adaptLinux(platform.DisplayType)
    }
}

func (c *Config) adaptMacOS() {
    // macOS 特定优化
    c.Font.Family = "SF Mono"
    c.UseMetal = true
    c.EnableRetina = true
}

func (c *Config) adaptWindows() {
    // Windows 特定优化
    c.Font.Family = "Consolas"
    c.UseConPTY = true
    c.EnableDirectWrite = true
}
```

## 📊 性能基准

### 平台性能对比

| 平台 | 启动时间 | 内存使用 | 渲染FPS | CPU使用 |
|------|----------|----------|---------|---------|
| Linux (X11) | ~300ms | ~40MB | 60+ | <5% |
| Linux (Wayland) | ~350ms | ~45MB | 60+ | <5% |
| macOS (Intel) | ~400ms | ~35MB | 60+ | <3% |
| macOS (M1) | ~200ms | ~30MB | 60+ | <2% |
| Windows 10 | ~500ms | ~50MB | 60+ | <8% |
| FreeBSD | ~450ms | ~45MB | 45+ | <7% |

### 优化建议

#### Linux
- 使用最新的 GPU 驱动
- 启用硬件加速
- 优化 X11/Wayland 配置

#### macOS
- 优先使用 Apple Silicon 原生版本
- 启用 Metal 渲染
- 配置显示缩放

#### Windows
- 确保 ConPTY 可用
- 配置 Windows Terminal
- 优化显示设置

## 🧪 兼容性测试

### 自动化测试

```yaml
# .github/workflows/compatibility.yml
name: Platform Compatibility

on: [push, pull_request]

jobs:
  test-linux:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        go-version: [1.23, 1.24]
        
  test-macos:
    runs-on: macos-latest
    strategy:
      matrix:
        go-version: [1.23, 1.24]
        
  test-windows:
    runs-on: windows-latest
    strategy:
      matrix:
        go-version: [1.23, 1.24]
```

### 手动测试清单

#### 基本功能
- [ ] 应用启动和关闭
- [ ] 终端创建和销毁
- [ ] 基本命令执行
- [ ] 文本输入输出

#### 平台特性
- [ ] 原生外观和感觉
- [ ] 系统集成功能
- [ ] 性能表现
- [ ] 资源使用

#### 边界测试
- [ ] 大量文本输出
- [ ] 长时间运行
- [ ] 多终端实例
- [ ] 异常情况处理

---

更多信息请参考：
- [开发环境配置](./development-setup.md)
- [构建和部署](./build-deploy.md)
- [故障排除](./troubleshooting.md)
