# Magic Terminal CI/CD 系统

## 概述

Magic Terminal 项目配置了完整的 CI/CD 流水线，使用 GitHub Actions 实现自动化构建、测试和发布。

## 工作流说明

### 1. CI 工作流 (`.github/workflows/ci.yml`)

**触发条件：**

- 推送到 `main` 或 `develop` 分支
- 对 `main` 或 `develop` 分支的 Pull Request

**功能：**

- 跨平台测试 (Linux, macOS, Windows)
- 代码质量检查 (golangci-lint)
- 测试覆盖率报告
- 安全扫描 (gosec)
- 构建验证

### 2. 构建和发布工作流 (`.github/workflows/build-and-release.yml`)

**触发条件：**

- 推送版本标签 (格式: `v*.*.*`)
- 手动触发 (workflow_dispatch)

**功能：**

- 测试验证
- 跨平台二进制构建 (Linux/macOS/Windows, amd64/arm64)
- GUI 应用打包 (使用 Fyne)
- 自动创建 GitHub Release
- 上传构建制品

### 3. 平台测试工作流 (`.github/workflows/platform-tests.yml`)

**触发条件：**

- 推送到 `main` 分支
- 对 `main` 分支的 Pull Request
- 每日定时执行 (UTC 2:00 AM)

**功能：**

- 多 Go 版本测试 (1.23.0, 1.24.x)
- Fyne 打包测试
- 深度平台兼容性验证

## 发布流程

### 方式一：使用发布脚本（推荐）

```bash
# 快速发布
make quick-release VERSION=v1.0.0

# 或直接运行脚本
./scripts/release.sh v1.0.0
```

### 方式二：手动发布

```bash
# 1. 发布前检查
make pre-release

# 2. 创建并推送标签
make tag VERSION=v1.0.0
make push-tag VERSION=v1.0.0

# 3. GitHub Actions 自动构建和发布
```

### 方式三：通过 GitHub 界面

1. 访问 [Actions 页面](https://github.com/wangyiyang/Magic-Terminal/actions)
2. 选择 "Build and Release" 工作流
3. 点击 "Run workflow"
4. 输入版本号 (如 `v1.0.0`)

## 构建制品

每次发布会生成以下制品：

### 命令行二进制文件

- `magic-terminal-linux-amd64`
- `magic-terminal-linux-arm64`
- `magic-terminal-darwin-amd64`
- `magic-terminal-darwin-arm64`
- `magic-terminal-windows-amd64.exe`

### GUI 应用程序

- `Magic-Terminal-darwin.tar.gz` (macOS .app 包)
- `Magic-Terminal-windows.exe` (Windows 可执行文件)
- `Magic-Terminal-linux.tar.gz` (Linux 应用包)

## 本地开发

### 设置开发环境

```bash
# 安装开发工具
make dev-setup

# 运行测试
make test

# 代码检查
make lint

# 构建应用
make build

# 开发模式运行
make dev
```

### 代码质量

项目配置了 golangci-lint 进行代码质量检查：

```bash
# 运行 lint 检查
make lint

# 格式化代码
make fmt

# 运行所有检查
make check
```

## 版本管理

项目遵循 [语义化版本](https://semver.org/) 规范：

- **主版本号 (MAJOR)**：不兼容的 API 更改
- **次版本号 (MINOR)**：向后兼容的功能增加
- **修订号 (PATCH)**：向后兼容的问题修复

## 监控和日志

- **构建状态**：<https://github.com/wangyiyang/Magic-Terminal/actions>
- **发布页面**：<https://github.com/wangyiyang/Magic-Terminal/releases>
- **代码覆盖率**：通过 Codecov 报告

## 故障排除

### 常见问题

1. **构建失败**
   - 检查 Go 版本兼容性
   - 确认所有依赖已正确安装

2. **测试失败**
   - 检查平台特定的依赖 (libgl1-mesa-dev, xorg-dev)
   - 确认测试环境配置

3. **发布失败**
   - 检查标签格式是否正确 (`v*.*.*`)
   - 确认 GitHub Token 权限

### 调试命令

```bash
# 模拟 CI 环境测试
make ci-test

# 检查 Git 状态
make git-status

# 查看分支信息
make branch-info

# 查看发布历史
make releases
```

## 配置文件

- `.github/workflows/` - GitHub Actions 工作流
- `.golangci.yml` - 代码质量检查配置
- `Makefile` - 构建脚本
- `scripts/release.sh` - 发布脚本
- `CHANGELOG.md` - 版本更新日志
