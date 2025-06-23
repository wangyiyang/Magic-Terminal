# Magic Terminal 模块设计文档

## 🏗️ 模块架构概览

Magic Terminal 采用模块化设计，将复杂的终端模拟器功能分解为独立、可维护的模块。每个模块都有明确的职责和清晰的接口。

```
┌─────────────────────────────────────────────────────────────┐
│                      应用层 (Application Layer)              │
├─────────────────────────────────────────────────────────────┤
│                      核心层 (Core Layer)                     │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌──────────┐ │
│  │   Terminal  │ │   Config    │ │   State     │ │ Events   │ │
│  │   Manager   │ │   Manager   │ │   Manager   │ │ System   │ │
│  └─────────────┘ └─────────────┘ └─────────────┘ └──────────┘ │
├─────────────────────────────────────────────────────────────┤
│                    协议层 (Protocol Layer)                   │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌──────────┐ │
│  │    ANSI     │ │     OSC     │ │     APC     │ │  Color   │ │
│  │   Handler   │ │   Handler   │ │   Handler   │ │ Handler  │ │
│  └─────────────┘ └─────────────┘ └─────────────┘ └──────────┘ │
├─────────────────────────────────────────────────────────────┤
│                   输入输出层 (I/O Layer)                      │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌──────────┐ │
│  │   Input     │ │   Output    │ │   Mouse     │ │ Selection│ │
│  │  Handler    │ │  Processor  │ │  Handler    │ │ Manager  │ │
│  └─────────────┘ └─────────────┘ └─────────────┘ └──────────┘ │
├─────────────────────────────────────────────────────────────┤
│                    渲染层 (Rendering Layer)                  │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌──────────┐ │
│  │   Render    │ │   TermGrid  │ │    Font     │ │  Theme   │ │
│  │   Engine    │ │   Widget    │ │   Manager   │ │ Manager  │ │
│  └─────────────┘ └─────────────┘ └─────────────┘ └──────────┘ │
├─────────────────────────────────────────────────────────────┤
│                   平台层 (Platform Layer)                    │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐            │
│  │    Unix     │ │   Windows   │ │     BSD     │            │
│  │    PTY      │ │   ConPTY    │ │    PTY      │            │
│  └─────────────┘ └─────────────┘ └─────────────┘            │
└─────────────────────────────────────────────────────────────┘
```

## 📦 核心模块详细设计

### 1. Terminal Core Module (term.go)

#### 职责
- 终端生命周期管理
- 核心状态维护
- 模块协调和通信
- 公共 API 提供

#### 关键组件

```go
// Terminal 核心结构
type Terminal struct {
    widget.BaseWidget
    fyne.ShortcutHandler
    
    // 核心组件
    content      *widget2.TermGrid    // 显示组件
    config       Config               // 配置管理
    state        State                // 状态管理
    
    // I/O 组件
    pty          PTYInterface         // 平台抽象 PTY
    inputHandler *InputHandler        // 输入处理器
    outputProc   *OutputProcessor     // 输出处理器
    
    // 协议处理器
    escapeHandler *EscapeHandler      // ANSI 转义序列
    oscHandler    *OSCHandler         // OSC 命令
    apcHandler    *APCHandler         // APC 命令
    colorHandler  *ColorHandler       // 颜色处理
    
    // 渲染组件
    renderer     *RenderEngine       // 渲染引擎
    fontManager  *FontManager        // 字体管理
    themeManager *ThemeManager       // 主题管理
    
    // 事件系统
    eventBus     *EventBus           // 事件总线
    listeners    []ConfigListener    // 配置监听器
    
    // 同步控制
    mu           sync.RWMutex        // 读写锁
    cancelFunc   context.CancelFunc  // 取消函数
}
```

#### 核心方法

```go
// 生命周期管理
func (t *Terminal) Start() error
func (t *Terminal) Stop() error  
func (t *Terminal) Restart() error

// 配置管理
func (t *Terminal) SetConfig(config Config) error
func (t *Terminal) GetConfig() Config
func (t *Terminal) UpdateConfig(updates ConfigUpdate) error

// 状态管理
func (t *Terminal) GetState() State
func (t *Terminal) SetState(state State)

// I/O 操作
func (t *Terminal) Write(data []byte) (int, error)
func (t *Terminal) Read(data []byte) (int, error)

// 事件管理
func (t *Terminal) AddListener(listener ConfigListener)
func (t *Terminal) EmitEvent(event Event)
```

### 2. Configuration Module (config.go)

#### 职责
- 配置数据结构定义
- 配置验证和默认值
- 配置持久化
- 配置变更通知

#### 配置结构

```go
type Config struct {
    // 基本设置
    Title         string        `json:"title"`
    Rows          uint          `json:"rows"`
    Columns       uint          `json:"columns"`
    
    // Shell 设置
    Shell         string        `json:"shell"`
    ShellArgs     []string      `json:"shell_args"`
    WorkingDir    string        `json:"working_dir"`
    Environment   []string      `json:"environment"`
    
    // 显示设置
    Colors        ColorScheme   `json:"colors"`
    Font          FontConfig    `json:"font"`
    Theme         string        `json:"theme"`
    
    // 行为设置
    ScrollBack    uint          `json:"scroll_back"`
    CursorBlink   bool          `json:"cursor_blink"`
    MouseSupport  bool          `json:"mouse_support"`
    
    // 高级设置
    BufferSize    uint          `json:"buffer_size"`
    FlowControl   bool          `json:"flow_control"`
    LocalEcho     bool          `json:"local_echo"`
}

// 配置管理器
type ConfigManager struct {
    config       Config
    defaults     Config
    validators   []ConfigValidator
    listeners    []ConfigChangeListener
    mu           sync.RWMutex
}
```

#### 配置验证

```go
type ConfigValidator func(Config) error

// 内置验证器
func ValidateBasicConfig(config Config) error {
    if config.Rows == 0 || config.Rows > MaxRows {
        return fmt.Errorf("invalid rows: %d", config.Rows)
    }
    if config.Columns == 0 || config.Columns > MaxColumns {
        return fmt.Errorf("invalid columns: %d", config.Columns)
    }
    return nil
}

func ValidateShellConfig(config Config) error {
    if config.Shell == "" {
        return fmt.Errorf("shell cannot be empty")
    }
    if _, err := os.Stat(config.Shell); os.IsNotExist(err) {
        return fmt.Errorf("shell not found: %s", config.Shell)
    }
    return nil
}
```

### 3. Input Processing Module (input.go)

#### 职责
- 键盘输入处理
- 输入事件转换
- 快捷键管理
- 输入缓冲管理

#### 输入处理器

```go
type InputHandler struct {
    terminal     *Terminal
    buffer       *InputBuffer
    keyMap       *KeyMap
    shortcuts    map[fyne.KeyName]ShortcutHandler
    inputMode    InputMode
    mu           sync.Mutex
}

type InputBuffer struct {
    data         []byte
    position     int
    capacity     int
    mu           sync.Mutex
}

type KeyMap struct {
    mappings     map[fyne.KeyName][]byte
    modifiers    map[fyne.KeyModifier]string
}
```

#### 输入处理流程

```go
// 键盘事件处理
func (h *InputHandler) HandleKeyEvent(event *fyne.KeyEvent) bool {
    // 1. 检查快捷键
    if h.handleShortcut(event) {
        return true
    }
    
    // 2. 模式特定处理
    switch h.inputMode {
    case ModeNormal:
        return h.handleNormalMode(event)
    case ModeApplication:
        return h.handleApplicationMode(event)
    case ModeInsert:
        return h.handleInsertMode(event)
    }
    
    return false
}

// 输入转换
func (h *InputHandler) ConvertToBytes(event *fyne.KeyEvent) []byte {
    // 特殊键处理
    if sequence, exists := h.keyMap.mappings[event.Name]; exists {
        return h.applyModifiers(sequence, event.Modifier)
    }
    
    // 普通字符
    if event.Text != "" {
        return []byte(event.Text)
    }
    
    return nil
}
```

### 4. Output Processing Module (output.go)

#### 职责
- 输出数据处理
- 转义序列解析
- 显示状态更新
- 输出缓冲管理

#### 输出处理器

```go
type OutputProcessor struct {
    terminal     *Terminal
    parser       *ANSIParser
    buffer       *OutputBuffer
    charset      CharSet
    state        ProcessorState
    mu           sync.Mutex
}

type OutputBuffer struct {
    data         []byte
    readPos      int
    writePos     int
    size         int
    overflow     bool
    mu           sync.RWMutex
}

type ANSIParser struct {
    state        ParserState
    sequence     []byte
    parameters   []int
    intermediate []byte
}
```

#### 输出处理流程

```go
func (p *OutputProcessor) ProcessOutput(data []byte) error {
    p.mu.Lock()
    defer p.mu.Unlock()
    
    for _, b := range data {
        switch p.parser.state {
        case StateNormal:
            p.processNormalChar(b)
        case StateEscape:
            p.processEscapeChar(b)
        case StateCSI:
            p.processCSIChar(b)
        case StateOSC:
            p.processOSCChar(b)
        }
    }
    
    return p.flushUpdates()
}

func (p *OutputProcessor) processNormalChar(b byte) {
    // 处理普通字符
    if unicode.IsPrint(rune(b)) {
        p.addCharacter(b)
    } else {
        p.processControlChar(b)
    }
}
```

### 5. Color Management Module (color.go)

#### 职责
- 颜色解析和转换
- 颜色方案管理
- ANSI 颜色支持
- 真彩色支持

#### 颜色管理器

```go
type ColorHandler struct {
    scheme       ColorScheme
    palette      [256]color.Color  // 256色调色板
    trueColor    bool              // 真彩色支持
    cache        map[string]color.Color
    mu           sync.RWMutex
}

type ColorScheme struct {
    // 基本颜色
    Foreground    color.Color
    Background    color.Color
    
    // 标准 16 色
    Black         color.Color
    Red           color.Color
    Green         color.Color
    Yellow        color.Color
    Blue          color.Color
    Magenta       color.Color
    Cyan          color.Color
    White         color.Color
    
    // 亮色版本
    BrightBlack   color.Color
    BrightRed     color.Color
    BrightGreen   color.Color
    BrightYellow  color.Color
    BrightBlue    color.Color
    BrightMagenta color.Color
    BrightCyan    color.Color
    BrightWhite   color.Color
}
```

#### 颜色处理方法

```go
// ANSI 颜色解析
func (c *ColorHandler) ParseANSIColor(code int) color.Color {
    switch {
    case code >= 0 && code <= 7:
        return c.scheme.getStandardColor(code)
    case code >= 8 && code <= 15:
        return c.scheme.getBrightColor(code - 8)
    case code >= 16 && code <= 231:
        return c.palette[code]
    case code >= 232 && code <= 255:
        return c.getGrayscaleColor(code - 232)
    default:
        return c.scheme.Foreground
    }
}

// RGB 颜色解析
func (c *ColorHandler) ParseRGBColor(r, g, b uint8) color.Color {
    if !c.trueColor {
        return c.findNearestPaletteColor(r, g, b)
    }
    return color.RGBA{R: r, G: g, B: b, A: 255}
}
```

### 6. Rendering Module (render.go)

#### 职责
- 字符网格渲染
- 性能优化
- 脏区域管理
- 双缓冲实现

#### 渲染引擎

```go
type RenderEngine struct {
    terminal     *Terminal
    canvas       fyne.Canvas
    grid         *TermGrid
    fontManager  *FontManager
    
    // 缓冲区
    frontBuffer  [][]Cell
    backBuffer   [][]Cell
    dirtyRegions []Region
    
    // 渲染状态
    lastRender   time.Time
    frameCount   int64
    renderStats  RenderStats
    
    mu           sync.Mutex
}

type Cell struct {
    Char         rune
    Foreground   color.Color
    Background   color.Color
    Attributes   CellAttributes
    Width        int  // 字符宽度（Unicode 宽字符支持）
}

type CellAttributes struct {
    Bold         bool
    Italic       bool
    Underline    bool
    Strikethrough bool
    Blink        bool
    Reverse      bool
    Dim          bool
}
```

#### 渲染优化

```go
// 脏区域渲染
func (r *RenderEngine) Render() error {
    r.mu.Lock()
    defer r.mu.Unlock()
    
    if len(r.dirtyRegions) == 0 {
        return nil // 无需渲染
    }
    
    // 合并重叠区域
    regions := r.mergeDirtyRegions()
    
    // 渲染每个区域
    for _, region := range regions {
        r.renderRegion(region)
    }
    
    // 交换缓冲区
    r.swapBuffers()
    
    // 清理脏区域
    r.dirtyRegions = r.dirtyRegions[:0]
    
    return nil
}

// 增量渲染
func (r *RenderEngine) markDirty(row, col, width, height int) {
    region := Region{
        X: col, Y: row,
        Width: width, Height: height,
    }
    r.dirtyRegions = append(r.dirtyRegions, region)
}
```

### 7. Platform Abstraction Module

#### 职责
- 平台差异抽象
- PTY 接口统一
- 平台特定优化

#### PTY 接口

```go
type PTYInterface interface {
    Start(shell string, args []string) error
    Stop() error
    Read([]byte) (int, error)
    Write([]byte) (int, error)
    Resize(rows, cols int) error
    GetSize() (rows, cols int, err error)
    SetRaw() error
    Restore() error
}

// Unix 实现
type UnixPTY struct {
    pty    *os.File
    tty    *os.File
    cmd    *exec.Cmd
    size   Size
    mu     sync.Mutex
}

// Windows 实现  
type WindowsPTY struct {
    conpty HPCON
    input  *os.File
    output *os.File
    cmd    *exec.Cmd
    size   Size
    mu     sync.Mutex
}
```

## 🔄 模块间通信

### 1. 事件总线系统

```go
type EventBus struct {
    subscribers map[EventType][]EventHandler
    mu          sync.RWMutex
}

type Event struct {
    Type      EventType
    Source    string
    Data      interface{}
    Timestamp time.Time
}

type EventHandler func(Event) error

// 事件类型
const (
    EventConfigChanged EventType = iota
    EventStateChanged
    EventOutputReceived
    EventInputReceived
    EventSizeChanged
    EventColorSchemeChanged
)
```

### 2. 模块初始化和依赖注入

```go
type ModuleManager struct {
    modules     map[string]Module
    dependencies map[string][]string
    initialized  map[string]bool
    mu          sync.Mutex
}

type Module interface {
    Name() string
    Dependencies() []string
    Initialize(deps ModuleDependencies) error
    Start() error
    Stop() error
}

// 模块注册和启动
func (m *ModuleManager) RegisterModule(module Module) {
    m.modules[module.Name()] = module
    m.dependencies[module.Name()] = module.Dependencies()
}

func (m *ModuleManager) StartAll() error {
    // 拓扑排序依赖
    order, err := m.resolveDependencies()
    if err != nil {
        return err
    }
    
    // 按顺序初始化模块
    for _, name := range order {
        if err := m.startModule(name); err != nil {
            return fmt.Errorf("failed to start module %s: %w", name, err)
        }
    }
    
    return nil
}
```

### 3. 配置同步机制

```go
// 配置变更广播
func (t *Terminal) broadcastConfigChange(config Config) {
    event := Event{
        Type:   EventConfigChanged,
        Source: "terminal",
        Data:   config,
    }
    
    t.eventBus.Emit(event)
    
    // 通知所有监听器
    for _, listener := range t.listeners {
        select {
        case listener <- config:
        default:
            // 非阻塞发送
        }
    }
}
```

## 📊 性能考虑

### 1. 内存管理

```go
// 对象池模式
type CellPool struct {
    pool sync.Pool
}

func (p *CellPool) Get() *Cell {
    cell := p.pool.Get().(*Cell)
    // 重置 cell 状态
    cell.Reset()
    return cell
}

func (p *CellPool) Put(cell *Cell) {
    p.pool.Put(cell)
}

// 缓冲区复用
type BufferPool struct {
    pools map[int]*sync.Pool  // 按大小分组的缓冲池
    mu    sync.RWMutex
}
```

### 2. 并发控制

```go
// 读写分离
type ConcurrentGrid struct {
    cells    [][]Cell
    readers  int32
    writing  int32
    rwMutex  sync.RWMutex
}

func (g *ConcurrentGrid) Read(row, col int) Cell {
    atomic.AddInt32(&g.readers, 1)
    defer atomic.AddInt32(&g.readers, -1)
    
    g.rwMutex.RLock()
    defer g.rwMutex.RUnlock()
    
    return g.cells[row][col]
}

func (g *ConcurrentGrid) Write(row, col int, cell Cell) {
    atomic.StoreInt32(&g.writing, 1)
    defer atomic.StoreInt32(&g.writing, 0)
    
    g.rwMutex.Lock()
    defer g.rwMutex.Unlock()
    
    g.cells[row][col] = cell
}
```

### 3. 渲染优化

```go
// 帧率限制
type FrameRateLimiter struct {
    targetFPS    int
    lastFrame    time.Time
    frameTime    time.Duration
    dropFrame    bool
}

func (f *FrameRateLimiter) ShouldRender() bool {
    now := time.Now()
    elapsed := now.Sub(f.lastFrame)
    
    if elapsed < f.frameTime {
        f.dropFrame = true
        return false
    }
    
    f.lastFrame = now
    f.dropFrame = false
    return true
}
```

## 🔧 扩展点和插件接口

### 1. 协议扩展

```go
type ProtocolExtension interface {
    Name() string
    CanHandle(data []byte) bool
    Process(data []byte, terminal *Terminal) error
    Priority() int
}

// 协议注册器
type ProtocolRegistry struct {
    extensions []ProtocolExtension
    mu         sync.RWMutex
}

func (r *ProtocolRegistry) Register(ext ProtocolExtension) {
    r.mu.Lock()
    defer r.mu.Unlock()
    
    r.extensions = append(r.extensions, ext)
    
    // 按优先级排序
    sort.Slice(r.extensions, func(i, j int) bool {
        return r.extensions[i].Priority() > r.extensions[j].Priority()
    })
}
```

### 2. 主题扩展

```go
type ThemeExtension interface {
    Name() string
    ColorScheme() ColorScheme
    FontConfig() FontConfig
    CustomProperties() map[string]interface{}
}

// 主题管理器
type ThemeManager struct {
    themes      map[string]ThemeExtension
    current     string
    customizer  ThemeCustomizer
    mu          sync.RWMutex
}
```

---

更多信息请参考：
- [架构设计](./architecture.md)
- [API 文档](./api-reference.md)
- [性能优化](./performance-optimization.md)
