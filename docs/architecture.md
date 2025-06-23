# Magic Terminal 架构设计

## 🏗️ 总体架构

Magic Terminal 采用分层架构设计，将终端模拟器的复杂功能分解为清晰的模块，确保代码的可维护性和可扩展性。

```
┌─────────────────────────────────────────────────────────────┐
│                    用户界面层 (UI Layer)                     │
├─────────────────────────────────────────────────────────────┤
│              终端控制层 (Terminal Control Layer)             │
├─────────────────────────────────────────────────────────────┤
│                输入输出层 (I/O Layer)                        │
├─────────────────────────────────────────────────────────────┤
│              平台抽象层 (Platform Abstraction)               │
└─────────────────────────────────────────────────────────────┘
```

## 📋 核心组件

### 1. 用户界面层 (UI Layer)

#### 主要组件
- **主窗口 (Main Window)**: 应用程序的主要容器
- **终端组件 (Terminal Widget)**: 核心的终端显示组件
- **菜单系统 (Menu System)**: 应用程序菜单和上下文菜单
- **主题管理 (Theme Manager)**: 界面主题和样式管理

#### 技术实现
```go
// 主要基于 Fyne 框架
type TerminalApp struct {
    app      fyne.App
    window   fyne.Window
    terminal *Terminal
    theme    fyne.Theme
}
```

#### 职责
- 处理用户交互事件
- 管理窗口状态和布局
- 提供配置界面
- 实现快捷键绑定

### 2. 终端控制层 (Terminal Control Layer)

#### 核心模块

##### Terminal 核心类
```go
type Terminal struct {
    widget.BaseWidget
    fyne.ShortcutHandler
    
    content      *widget2.TermGrid  // 终端网格显示
    config       Config             // 终端配置
    pty          *os.File          // PTY 文件描述符
    cmd          *exec.Cmd         // 子进程命令
    
    // 状态管理
    cursor       Position          // 光标位置
    cells        [][]Cell         // 字符网格
    colors       ColorScheme      // 颜色方案
    
    // 同步控制
    listenerLock sync.Mutex       // 监听器锁
    writeLock    sync.Mutex       // 写入锁
}
```

##### 配置管理
```go
type Config struct {
    Title         string        // 终端标题
    Rows, Columns uint          // 行列数
    Shell         string        // 默认Shell
    Colors        ColorScheme   // 颜色配置
    Font          FontConfig    // 字体配置
}
```

#### 职责
- 管理终端状态和配置
- 处理终端协议解析
- 协调输入输出流
- 维护光标和显示状态

### 3. 输入输出层 (I/O Layer)

#### 输入处理模块

##### 键盘输入 (input.go)
```go
type InputHandler struct {
    terminal *Terminal
    buffer   []byte
}

// 主要功能
- 键盘事件处理
- 快捷键映射
- 输入缓冲管理
- 特殊键序列转换
```

##### 鼠标输入 (mouse.go)
```go
type MouseHandler struct {
    terminal *Terminal
    mode     MouseMode
}

// 功能特性
- 鼠标点击定位
- 文本选择
- 滚轮支持
- 右键菜单
```

#### 输出处理模块

##### 文本渲染 (render.go)
```go
type Renderer struct {
    terminal *Terminal
    cache    *RenderCache
}

// 渲染功能
- 字符网格渲染
- 颜色处理
- 字体渲染
- 性能优化
```

##### 终端协议 (escape.go, osc.go, apc.go)
```go
// ANSI 转义序列处理
type EscapeHandler struct {
    terminal *Terminal
    parser   *ANSIParser
}

// 支持的协议
- VT100/VT220 转义序列
- ANSI 颜色代码
- OSC (Operating System Command)
- APC (Application Program Command)
```

### 4. 平台抽象层 (Platform Abstraction)

#### 平台特定实现

##### Unix 系统 (term_unix.go)
```go
// Unix 平台实现
func (t *Terminal) startPTY() error {
    // 使用 github.com/creack/pty
    pty, tty, err := pty.Open()
    // PTY 配置和管理
}
```

##### Windows 系统 (term_windows.go)
```go
// Windows 平台实现  
func (t *Terminal) startConPTY() error {
    // 使用 ConPTY API
    // Windows 特定的终端处理
}
```

#### 职责
- 抽象平台差异
- 提供统一的 PTY 接口
- 处理平台特定的终端特性

## 🔄 数据流架构

### 输入数据流
```
用户输入 → 输入处理器 → 协议转换 → PTY → Shell进程
    ↓
键盘/鼠标事件 → 事件分发 → 命令解析 → 进程通信
```

### 输出数据流
```
Shell进程 → PTY → 数据缓冲 → 协议解析 → 渲染引擎 → 屏幕显示
    ↓
文本输出 → 转义序列 → 字符网格 → 视觉渲染 → 用户界面
```

### 配置数据流
```
配置文件 → 配置解析 → 状态管理 → 组件更新 → 界面刷新
    ↓
用户设置 → 验证检查 → 持久化存储 → 实时应用
```

## 🧩 模块间交互

### 核心交互模式

#### 1. 观察者模式 (Observer Pattern)
```go
// 配置变化监听
type ConfigListener chan Config

func (t *Terminal) AddListener(listener ConfigListener) {
    t.listenerLock.Lock()
    defer t.listenerLock.Unlock()
    t.listeners = append(t.listeners, listener)
}
```

#### 2. 命令模式 (Command Pattern)
```go
// 终端命令处理
type TerminalCommand interface {
    Execute(terminal *Terminal) error
}

type EscapeCommand struct {
    sequence string
    handler  EscapeHandler
}
```

#### 3. 策略模式 (Strategy Pattern)
```go
// 平台特定策略
type PlatformStrategy interface {
    CreatePTY() (PTY, error)
    ConfigureTerminal(config Config) error
}
```

## 🏆 设计原则

### 1. 单一职责原则 (SRP)
- 每个模块专注于单一功能
- 清晰的模块边界
- 降低耦合度

### 2. 开闭原则 (OCP)
- 对扩展开放，对修改封闭
- 通过接口和抽象支持新功能
- 插件化架构准备

### 3. 依赖倒置原则 (DIP)
- 依赖抽象而非具体实现
- 平台抽象层设计
- 接口优先的设计方法

### 4. 接口隔离原则 (ISP)
- 细粒度的接口设计
- 避免臃肿的接口
- 客户端只依赖需要的接口

## 🔧 关键设计决策

### 1. 选择 Fyne 框架
**原因:**
- 跨平台支持优秀
- Go 语言原生支持
- 现代化的 UI 设计
- 活跃的社区支持

**权衡:**
- 相对较新的框架
- 生态系统仍在发展
- 某些高级功能需要自实现

### 2. 分层架构设计
**优势:**
- 清晰的职责分离
- 易于测试和维护
- 支持独立演进
- 便于新功能添加

**考虑:**
- 增加了一定的复杂性
- 需要良好的接口设计
- 层间通信需要优化

### 3. 异步 I/O 处理
**实现:**
```go
// 异步读取 PTY 输出
go func() {
    buffer := make([]byte, bufLen)
    for {
        n, err := t.pty.Read(buffer)
        if err != nil {
            return
        }
        t.processOutput(buffer[:n])
    }
}()
```

**优势:**
- 响应式用户体验
- 避免界面阻塞
- 更好的性能表现

## 📊 性能架构

### 1. 渲染优化
- **双缓冲渲染**: 避免闪烁
- **增量更新**: 只渲染变化部分
- **缓存机制**: 字符和颜色缓存

### 2. 内存管理
- **对象池**: 复用频繁创建的对象
- **垃圾回收优化**: 减少 GC 压力
- **缓冲区管理**: 智能的缓冲区大小调整

### 3. 并发控制
- **读写锁**: 保护共享数据结构
- **通道通信**: 协程间安全通信
- **原子操作**: 高性能的状态更新

## 🔮 扩展性设计

### 1. 插件系统准备
```go
// 预留的插件接口
type Plugin interface {
    Name() string
    Initialize(terminal *Terminal) error
    HandleCommand(cmd string) (bool, error)
}
```

### 2. 主题系统
```go
// 可扩展的主题系统
type Theme interface {
    Colors() ColorScheme
    Fonts() FontConfig
    Layout() LayoutConfig
}
```

### 3. 协议扩展
```go
// 支持新协议的扩展点
type ProtocolHandler interface {
    CanHandle(data []byte) bool
    Process(data []byte) error
}
```

---

更多详细信息请参考：
- [模块设计](./module-design.md)
- [API 文档](./api-reference.md)
- [性能优化](./performance-optimization.md)
