# Magic Terminal 项目结构

## 📁 总体目录结构

```
Magic-Terminal/
├── .github/                    # GitHub 相关配置
│   ├── ISSUE_TEMPLATE/         # Issue 模板
│   └── workflows/              # GitHub Actions 工作流
├── assets/                     # 静态资源文件
├── cmd/                        # 命令行程序入口
│   └── fyneterm/               # 主应用程序
├── docs/                       # 项目文档
├── img/                        # 说明文档图片
├── internal/                   # 内部包（不对外暴露）
│   └── widget/                 # 内部组件
├── scripts/                    # 构建和部署脚本
├── test_data/                  # 测试数据文件
├── *.go                        # 核心库文件
├── *_test.go                   # 测试文件
├── go.mod                      # Go 模块定义
├── go.sum                      # 依赖锁定文件
├── Makefile                    # 构建脚本
└── README.md                   # 项目说明
```

## 🔧 核心模块文件

### 主要 Go 文件说明

| 文件名 | 功能描述 | 关键类型/函数 |
|--------|----------|---------------|
| `term.go` | 终端核心逻辑 | `Terminal`, `Config` |
| `term_unix.go` | Unix 平台实现 | PTY 处理, 信号管理 |
| `term_windows.go` | Windows 平台实现 | ConPTY 支持 |
| `input.go` | 输入处理 | 键盘、鼠标事件 |
| `output.go` | 输出处理 | 文本输出、格式化 |
| `render.go` | 渲染引擎 | 显示逻辑、性能优化 |
| `color.go` | 颜色管理 | 颜色解析、ANSI 颜色 |
| `escape.go` | 转义序列 | ANSI/VT100 协议 |
| `osc.go` | OSC 命令 | 操作系统命令处理 |
| `apc.go` | APC 命令 | 应用程序命令处理 |
| `mouse.go` | 鼠标处理 | 鼠标事件、选择操作 |
| `select.go` | 文本选择 | 选择逻辑、复制粘贴 |
| `position.go` | 位置管理 | 光标位置、坐标转换 |

### 测试文件结构

每个核心模块都有对应的测试文件：
- `*_test.go`: 单元测试
- 测试覆盖核心功能和边界情况
- 使用 `testify` 框架进行断言

## 📦 cmd/ 目录详解

### fyneterm/ - 主应用程序

```
cmd/fyneterm/
├── main.go                     # 应用程序入口点
├── theme.go                    # 主题配置
├── FyneApp.toml               # Fyne 应用配置
├── data/                       # 静态数据
│   ├── bundled.go             # 嵌入资源
│   ├── icons.go               # 图标定义
│   ├── fyne_logo.png          # Logo 文件
│   ├── Icon.png               # 应用图标
│   └── Icon.svg               # 矢量图标
├── translation/               # 国际化文件
│   ├── en.json                # 英语
│   ├── fr.json                # 法语
│   ├── pl.json                # 波兰语
│   ├── pt_BR.json             # 巴西葡萄牙语
│   ├── ru.json                # 俄语
│   ├── sk.json                # 斯洛伐克语
│   ├── sv.json                # 瑞典语
│   ├── ta.json                # 泰米尔语
│   └── uk.json                # 乌克兰语
└── Magic Terminal.app/        # macOS 应用包
    └── Contents/
        ├── Info.plist         # macOS 应用信息
        ├── MacOS/
        │   └── magic-terminal # 可执行文件
        └── Resources/
            └── icon.icns      # macOS 图标
```

#### main.go 主要功能
```go
// 应用程序入口
func main() {
    // 解析命令行参数
    // 初始化应用程序
    // 设置国际化
    // 创建主窗口
    // 启动终端
}

// 核心组件
- setupListener()    // 配置监听器
- guessCellSize()   // 计算字符大小
- termTitle()       // 设置窗口标题
```

## 🔒 internal/ 目录

### widget/ - 内部组件

```
internal/widget/
├── termgrid.go                 # 终端网格组件
├── termgridhelper.go          # 网格助手函数
└── termgridhelper_test.go     # 网格组件测试
```

#### TermGrid 组件
```go
type TermGrid struct {
    widget.BaseWidget
    
    // 网格数据
    cells     [][]Cell
    rows      int
    cols      int
    
    // 渲染相关
    cellSize  fyne.Size
    fontFace  font.Face
    
    // 状态管理
    cursor    Position
    selection Selection
}
```

**主要功能:**
- 字符网格的渲染和管理
- 光标位置追踪
- 文本选择处理
- 滚动支持
- 性能优化的重绘逻辑

## 🔧 scripts/ 目录

### 构建和部署脚本

```
scripts/
├── release.sh                  # 发布脚本
├── create-dmg.sh              # macOS DMG 创建
└── create-dmg-background.sh   # DMG 背景创建
```

#### release.sh 脚本功能
```bash
#!/bin/bash
# 主要功能：
# 1. 版本验证和检查
# 2. 构建多平台二进制
# 3. 创建 Git 标签
# 4. 触发 CI/CD 流程
# 5. 生成 CHANGELOG
```

## 📋 .github/ 目录

### GitHub Actions 工作流

```
.github/
├── ISSUE_TEMPLATE/             # Issue 模板
│   ├── bug_report.md          # Bug 报告模板
│   ├── feature_request.md     # 功能请求模板
│   └── question.md            # 问题咨询模板
└── workflows/                  # CI/CD 工作流
    ├── ci.yml                 # 持续集成
    ├── build-and-release.yml  # 构建和发布
    ├── platform-tests.yml     # 平台测试
    ├── platform_tests.yml     # 平台测试（备用）
    ├── security.yml           # 安全扫描
    └── static_analysis.yml    # 静态分析
```

#### 工作流说明

| 工作流 | 触发条件 | 主要功能 |
|--------|----------|----------|
| `ci.yml` | Push/PR to main/develop | 基础 CI 检查 |
| `build-and-release.yml` | 版本标签 | 构建和发布 |
| `platform-tests.yml` | Push/PR to main | 跨平台测试 |
| `security.yml` | 定时/手动 | 安全漏洞扫描 |
| `static_analysis.yml` | Push/PR | 代码质量分析 |

## 📄 配置文件

### 核心配置文件

| 文件 | 用途 | 说明 |
|------|------|------|
| `go.mod` | Go 模块 | 依赖管理、版本控制 |
| `go.sum` | 依赖锁定 | 确保构建可重现性 |
| `Makefile` | 构建脚本 | 统一的构建命令 |
| `.golangci.yml` | 代码检查 | golangci-lint 配置 |
| `.gitignore` | Git 忽略 | 版本控制忽略规则 |

### Makefile 主要目标

```makefile
# 主要构建目标
build:          # 构建应用程序
test:           # 运行测试
lint:           # 代码检查
clean:          # 清理构建文件
install:        # 安装应用程序
dev:            # 开发模式运行

# 发布相关
release:        # 创建发布
tag:            # 创建 Git 标签
push-tag:       # 推送标签

# 跨平台构建
build-linux:    # Linux 构建
build-darwin:   # macOS 构建  
build-windows:  # Windows 构建
build-all:      # 所有平台构建
```

## 🎨 assets/ 和 img/ 目录

### 静态资源

```
assets/
└── dmg-background.png          # macOS DMG 背景图

img/
├── linux.png                  # Linux 截图
├── macos.png                  # macOS 截图
└── windows.png                # Windows 截图
```

## 📊 test_data/ 目录

### 测试数据文件

```
test_data/
└── chn.pdf                    # 中文测试文件
```

**用途:**
- 单元测试数据
- 集成测试样本
- 性能测试基准
- 国际化测试

## 🔍 模块依赖关系

### 核心依赖图

```
main.go (fyneterm)
    ↓
Terminal (term.go)
    ↓
├── Input (input.go)
├── Output (output.go)  
├── Render (render.go)
├── Colors (color.go)
├── Escape (escape.go)
├── Mouse (mouse.go)
└── Platform
    ├── Unix (term_unix.go)
    └── Windows (term_windows.go)
```

### 内部组件依赖

```
Terminal
    ↓
TermGrid (internal/widget)
    ↓
├── Cell Management
├── Cursor Tracking
├── Selection Handling
└── Rendering Logic
```

## 📝 代码组织原则

### 1. 按功能分模块
- 每个文件专注单一功能域
- 清晰的模块边界
- 最小化模块间耦合

### 2. 平台抽象
- 平台特定代码隔离
- 统一的接口设计
- 条件编译支持

### 3. 测试对应
- 每个模块对应测试文件
- 完整的测试覆盖
- 便于维护和验证

### 4. 资源管理
- 静态资源嵌入
- 国际化支持
- 版本化资源管理

---

更多详细信息请参考：
- [架构设计](./architecture.md)
- [模块设计](./module-design.md)
- [开发指南](./development-setup.md)
