# Magic Terminal 开发环境配置

## 📋 系统要求

### 最低要求
- **操作系统**: Linux, macOS, Windows, 或 BSD
- **Go 版本**: Go 1.23.0 或更高版本
- **内存**: 最少 2GB RAM
- **存储**: 至少 500MB 可用空间

### 推荐配置
- **Go 版本**: Go 1.24.x (最新稳定版)
- **内存**: 4GB+ RAM
- **存储**: 2GB+ 可用空间
- **网络**: 稳定的互联网连接（用于下载依赖）

## 🔧 开发工具安装

### 1. Go 语言环境

#### Linux (Ubuntu/Debian)
```bash
# 使用官方包管理器
sudo apt update
sudo apt install golang-go

# 或下载最新版本
wget https://go.dev/dl/go1.24.1.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.24.1.linux-amd64.tar.gz
echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
source ~/.bashrc
```

#### macOS
```bash
# 使用 Homebrew
brew install go

# 或下载官方安装包
# 访问 https://golang.org/dl/ 下载 .pkg 文件
```

#### Windows
```powershell
# 使用 Chocolatey
choco install golang

# 或使用 Scoop
scoop install go

# 或下载官方安装程序
# 访问 https://golang.org/dl/ 下载 .msi 文件
```

### 2. C 编译器 (必需)

Magic Terminal 依赖 CGO，需要 C 编译器：

#### Linux
```bash
# Ubuntu/Debian
sudo apt install build-essential

# CentOS/RHEL/Fedora
sudo yum groupinstall "Development Tools"
# 或
sudo dnf groupinstall "Development Tools"
```

#### macOS
```bash
# 安装 Xcode Command Line Tools
xcode-select --install
```

#### Windows
```powershell
# 安装 TDM-GCC 或 MinGW
choco install mingw

# 或安装 Visual Studio Build Tools
```

### 3. 图形库依赖

#### Linux
```bash
# Ubuntu/Debian
sudo apt install libgl1-mesa-dev xorg-dev

# CentOS/RHEL
sudo yum install mesa-libGL-devel libX11-devel libXcursor-devel libXrandr-devel libXinerama-devel libXi-devel

# Fedora
sudo dnf install mesa-libGL-devel libX11-devel libXcursor-devel libXrandr-devel libXinerama-devel libXi-devel
```

#### macOS 和 Windows
图形库通常已包含在系统中，无需额外安装。

## 🚀 项目设置

### 1. 克隆项目
```bash
# 克隆主仓库
git clone https://github.com/wangyiyang/Magic-Terminal.git
cd Magic-Terminal

# 或克隆你的 fork
git clone https://github.com/YOUR_USERNAME/Magic-Terminal.git
cd Magic-Terminal
```

### 2. 安装依赖
```bash
# 下载并安装依赖
go mod download

# 验证依赖
go mod verify

# 整理依赖（可选）
go mod tidy
```

### 3. 验证安装
```bash
# 检查 Go 版本
go version

# 检查环境变量
go env GOPATH
go env GOROOT

# 运行基础测试
go test ./...
```

## 🔨 开发工具配置

### 1. 推荐的 IDE/编辑器

#### Visual Studio Code
```bash
# 安装 Go 扩展
# 扩展 ID: golang.go
```

**推荐设置 (settings.json)**:
```json
{
    "go.toolsManagement.checkForUpdates": "local",
    "go.useLanguageServer": true,
    "go.formatTool": "goimports",
    "go.lintTool": "golangci-lint",
    "go.testFlags": ["-v"],
    "editor.formatOnSave": true,
    "editor.codeActionsOnSave": {
        "source.organizeImports": true
    }
}
```

#### GoLand
- 开箱即用的 Go 开发环境
- 内置调试器和测试支持
- 代码重构功能强大

#### Vim/Neovim
```bash
# 安装 vim-go 插件
git clone https://github.com/fatih/vim-go.git ~/.vim/pack/plugins/start/vim-go

# 安装 Go 工具
:GoInstallBinaries
```

### 2. 开发工具安装

#### golangci-lint (代码检查)
```bash
# Linux/macOS
curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b $(go env GOPATH)/bin v1.55.2

# Windows (PowerShell)
# 下载并安装 golangci-lint.exe 到 PATH 中
```

#### Go 工具包
```bash
# 安装常用工具
go install golang.org/x/tools/cmd/goimports@latest
go install golang.org/x/tools/cmd/godoc@latest
go install golang.org/x/tools/cmd/goyacc@latest
go install github.com/go-delve/delve/cmd/dlv@latest
```

## 🏗️ 构建和运行

### 1. 使用 Makefile

```bash
# 查看所有可用命令
make help

# 安装开发依赖
make dev-setup

# 构建应用程序
make build

# 运行测试
make test

# 代码检查
make lint

# 开发模式运行
make dev

# 清理构建文件
make clean
```

### 2. 直接使用 Go 命令

```bash
# 构建命令行版本
go build -o magic-terminal ./cmd/fyneterm

# 运行应用程序
go run ./cmd/fyneterm

# 运行测试
go test ./...

# 运行带覆盖率的测试
go test -cover ./...

# 生成测试覆盖率报告
go test -coverprofile=coverage.out ./...
go tool cover -html=coverage.out
```

### 3. 跨平台构建

```bash
# Linux
GOOS=linux GOARCH=amd64 go build -o magic-terminal-linux ./cmd/fyneterm

# macOS
GOOS=darwin GOARCH=amd64 go build -o magic-terminal-darwin ./cmd/fyneterm

# Windows
GOOS=windows GOARCH=amd64 go build -o magic-terminal-windows.exe ./cmd/fyneterm

# 使用 Makefile 构建所有平台
make build-all
```

## 🧪 测试环境配置

### 1. 单元测试
```bash
# 运行所有测试
go test ./...

# 运行特定包的测试
go test ./pkg/terminal

# 运行特定测试
go test -run TestTerminalInit ./...

# 详细输出
go test -v ./...
```

### 2. 集成测试
```bash
# 运行集成测试
go test -tags=integration ./...

# 运行性能测试
go test -bench=. ./...

# 运行竞态条件检测
go test -race ./...
```

### 3. 测试覆盖率
```bash
# 生成覆盖率报告
make test-coverage

# 查看覆盖率详情
make coverage-html
```

## 🐛 调试配置

### 1. 使用 Delve 调试器

```bash
# 安装 Delve
go install github.com/go-delve/delve/cmd/dlv@latest

# 调试应用程序
dlv debug ./cmd/fyneterm

# 调试测试
dlv test ./pkg/terminal
```

### 2. VS Code 调试配置

创建 `.vscode/launch.json`:
```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Launch Terminal",
            "type": "go",
            "request": "launch",
            "mode": "debug",
            "program": "${workspaceFolder}/cmd/fyneterm",
            "env": {},
            "args": []
        },
        {
            "name": "Test Current Package",
            "type": "go",
            "request": "launch",
            "mode": "test",
            "program": "${workspaceFolder}/${relativeFileDirname}"
        }
    ]
}
```

### 3. 日志配置

```go
// 开发环境日志配置
import (
    "log"
    "os"
)

func setupDevelopmentLogging() {
    log.SetFlags(log.LstdFlags | log.Lshortfile)
    log.SetOutput(os.Stdout)
}
```

## 📦 依赖管理

### 1. 添加新依赖
```bash
# 添加依赖
go get github.com/example/package

# 添加特定版本
go get github.com/example/package@v1.2.3

# 更新依赖
go get -u github.com/example/package

# 更新所有依赖
go get -u ./...
```

### 2. 依赖清理
```bash
# 移除未使用的依赖
go mod tidy

# 检查依赖状态
go list -m all

# 查看依赖图
go mod graph
```

## 🔄 Git 工作流配置

### 1. Git Hooks 设置

创建 `.git/hooks/pre-commit`:
```bash
#!/bin/sh
# 提交前检查
make lint
make test
```

### 2. 分支策略
```bash
# 创建功能分支
git checkout -b feature/new-feature

# 创建修复分支
git checkout -b fix/bug-description

# 合并到开发分支
git checkout develop
git merge feature/new-feature
```

## 🚀 快速开始指南

对于新开发者，推荐按以下步骤开始：

```bash
# 1. 克隆项目
git clone https://github.com/wangyiyang/Magic-Terminal.git
cd Magic-Terminal

# 2. 安装依赖和工具
make dev-setup

# 3. 运行测试确保环境正常
make test

# 4. 构建应用程序
make build

# 5. 运行应用程序
./bin/magic-terminal

# 6. 开始开发
make dev
```

## 🔧 故障排除

### 常见问题

#### 1. CGO 编译错误
```bash
# 确认 C 编译器已安装
gcc --version

# 检查 CGO 是否启用
go env CGO_ENABLED
```

#### 2. 图形库依赖问题
```bash
# Linux: 安装开发库
sudo apt install libgl1-mesa-dev xorg-dev

# 检查 X11 forwarding (SSH)
echo $DISPLAY
```

#### 3. 模块下载问题
```bash
# 设置 Go 代理
go env -w GOPROXY=https://proxy.golang.org,direct

# 清理模块缓存
go clean -modcache
```

### 性能调优

#### 1. 开发模式优化
```bash
# 使用 race detector
go build -race ./cmd/fyneterm

# 禁用 CGO (如果不需要)
CGO_ENABLED=0 go build ./cmd/fyneterm
```

#### 2. 构建优化
```bash
# 优化构建大小
go build -ldflags="-s -w" ./cmd/fyneterm

# 静态链接
go build -a -installsuffix cgo ./cmd/fyneterm
```

---

更多信息请参考：
- [编码规范](./coding-standards.md)
- [测试指南](./testing-guide.md)
- [构建部署](./build-deploy.md)
