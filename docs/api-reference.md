# Magic Terminal API 参考文档

## 📚 API 概览

Magic Terminal 提供了一套完整的 API 来创建、配置和控制终端模拟器。本文档详细描述了所有公共 API 的使用方法。

## 🏗️ 核心类型

### Terminal

`Terminal` 是主要的终端模拟器类型，实现了完整的终端功能。

```go
type Terminal struct {
    widget.BaseWidget
    fyne.ShortcutHandler
    // 私有字段...
}
```

#### 创建 Terminal

```go
// New 创建一个新的终端实例
func New() *Terminal

// NewWithConfig 使用指定配置创建终端
func NewWithConfig(config Config) *Terminal
```

**示例:**
```go
// 创建默认终端
term := terminal.New()

// 创建带配置的终端
config := terminal.Config{
    Rows:    25,
    Columns: 80,
    Title:   "My Terminal",
}
term := terminal.NewWithConfig(config)
```

#### 方法

##### 基本操作

```go
// Start 启动终端并连接到 shell
func (t *Terminal) Start() error

// Stop 停止终端
func (t *Terminal) Stop() error

// Restart 重启终端
func (t *Terminal) Restart() error
```

##### 输入输出

```go
// Write 向终端写入数据
func (t *Terminal) Write(data []byte) (int, error)

// WriteString 写入字符串到终端
func (t *Terminal) WriteString(s string) (int, error)

// Read 从终端读取数据
func (t *Terminal) Read(data []byte) (int, error)
```

**示例:**
```go
// 向终端发送命令
term.WriteString("ls -la\n")

// 写入字节数据
data := []byte("echo hello\n")
n, err := term.Write(data)
if err != nil {
    log.Printf("写入失败: %v", err)
}
```

##### 配置管理

```go
// SetConfig 设置终端配置
func (t *Terminal) SetConfig(config Config) error

// GetConfig 获取当前配置
func (t *Terminal) GetConfig() Config

// UpdateConfig 更新部分配置
func (t *Terminal) UpdateConfig(updates ConfigUpdate) error
```

##### 事件监听

```go
// AddListener 添加配置变更监听器
func (t *Terminal) AddListener(listener chan Config)

// RemoveListener 移除监听器
func (t *Terminal) RemoveListener(listener chan Config)

// OnOutput 设置输出处理回调
func (t *Terminal) OnOutput(handler func([]byte)) 

// OnStateChange 设置状态变更回调
func (t *Terminal) OnStateChange(handler func(State))
```

**示例:**
```go
// 监听配置变更
listener := make(chan terminal.Config, 1)
term.AddListener(listener)

go func() {
    for config := range listener {
        log.Printf("配置已更新: %+v", config)
    }
}()

// 监听输出
term.OnOutput(func(data []byte) {
    fmt.Printf("终端输出: %s", data)
})
```

### Config

`Config` 结构体定义了终端的配置选项。

```go
type Config struct {
    Title         string      // 终端标题
    Rows          uint        // 行数
    Columns       uint        // 列数
    Shell         string      // Shell 程序路径
    WorkingDir    string      // 工作目录
    Environment   []string    // 环境变量
    Colors        ColorScheme // 颜色方案
    Font          FontConfig  // 字体配置
}
```

#### 默认配置

```go
// DefaultConfig 返回默认配置
func DefaultConfig() Config

// ValidateConfig 验证配置有效性
func ValidateConfig(config Config) error
```

**示例:**
```go
// 获取默认配置
config := terminal.DefaultConfig()

// 自定义配置
config.Rows = 30
config.Columns = 100
config.Title = "开发终端"
config.Shell = "/bin/zsh"

// 验证配置
if err := terminal.ValidateConfig(config); err != nil {
    log.Fatalf("配置无效: %v", err)
}
```

### ColorScheme

`ColorScheme` 定义了终端的颜色方案。

```go
type ColorScheme struct {
    Foreground    color.Color    // 前景色
    Background    color.Color    // 背景色
    Black         color.Color    // 黑色
    Red           color.Color    // 红色
    Green         color.Color    // 绿色
    Yellow        color.Color    // 黄色
    Blue          color.Color    // 蓝色
    Magenta       color.Color    // 洋红色
    Cyan          color.Color    // 青色
    White         color.Color    // 白色
    BrightBlack   color.Color    // 亮黑色
    BrightRed     color.Color    // 亮红色
    BrightGreen   color.Color    // 亮绿色
    BrightYellow  color.Color    // 亮黄色
    BrightBlue    color.Color    // 亮蓝色
    BrightMagenta color.Color    // 亮洋红色
    BrightCyan    color.Color    // 亮青色
    BrightWhite   color.Color    // 亮白色
}
```

#### 预定义颜色方案

```go
// DefaultColorScheme 默认颜色方案
func DefaultColorScheme() ColorScheme

// DarkColorScheme 暗色主题
func DarkColorScheme() ColorScheme

// LightColorScheme 亮色主题  
func LightColorScheme() ColorScheme

// SolarizedColorScheme Solarized 主题
func SolarizedColorScheme() ColorScheme
```

**示例:**
```go
// 使用预定义主题
config.Colors = terminal.DarkColorScheme()

// 自定义颜色
config.Colors.Background = color.RGBA{R: 30, G: 30, B: 30, A: 255}
config.Colors.Foreground = color.RGBA{R: 200, G: 200, B: 200, A: 255}
```

### FontConfig

`FontConfig` 定义了字体配置。

```go
type FontConfig struct {
    Family string  // 字体族名
    Size   float32 // 字体大小
    Bold   bool    // 是否粗体
    Italic bool    // 是否斜体
}
```

#### 字体管理

```go
// DefaultFont 返回默认字体配置
func DefaultFont() FontConfig

// ValidateFont 验证字体配置
func ValidateFont(font FontConfig) error

// AvailableFonts 返回可用字体列表
func AvailableFonts() []string
```

**示例:**
```go
// 设置字体
config.Font = terminal.FontConfig{
    Family: "JetBrains Mono",
    Size:   14.0,
    Bold:   false,
    Italic: false,
}

// 获取可用字体
fonts := terminal.AvailableFonts()
for _, font := range fonts {
    fmt.Println("可用字体:", font)
}
```

## 🎯 高级 API

### 位置和选择

#### Position

```go
type Position struct {
    Row int // 行号 (0-based)
    Col int // 列号 (0-based)
}
```

**方法:**
```go
// GetCursorPosition 获取光标位置
func (t *Terminal) GetCursorPosition() Position

// SetCursorPosition 设置光标位置  
func (t *Terminal) SetCursorPosition(pos Position) error

// MoveCursor 移动光标
func (t *Terminal) MoveCursor(deltaRow, deltaCol int) error
```

#### Selection

```go
type Selection struct {
    Start Position // 选择开始位置
    End   Position // 选择结束位置
}
```

**方法:**
```go
// GetSelection 获取当前选择
func (t *Terminal) GetSelection() (Selection, bool)

// SetSelection 设置选择区域
func (t *Terminal) SetSelection(sel Selection) error

// GetSelectedText 获取选中的文本
func (t *Terminal) GetSelectedText() string

// ClearSelection 清除选择
func (t *Terminal) ClearSelection()
```

**示例:**
```go
// 获取选中文本
if selection, hasSelection := term.GetSelection(); hasSelection {
    text := term.GetSelectedText()
    fmt.Printf("选中文本: %s", text)
}

// 程序化选择文本
selection := terminal.Selection{
    Start: terminal.Position{Row: 0, Col: 0},
    End:   terminal.Position{Row: 0, Col: 10},
}
term.SetSelection(selection)
```

### 输入输出处理

#### 输入事件

```go
// KeyEvent 键盘事件
type KeyEvent struct {
    Key       fyne.KeyName // 按键名称
    Text      string       // 输入文本
    Modifiers fyne.KeyModifier // 修饰键
}

// OnKeyDown 设置按键按下回调
func (t *Terminal) OnKeyDown(handler func(KeyEvent) bool)

// OnKeyUp 设置按键抬起回调  
func (t *Terminal) OnKeyUp(handler func(KeyEvent))
```

**示例:**
```go
// 拦截特定按键
term.OnKeyDown(func(event terminal.KeyEvent) bool {
    if event.Key == fyne.KeyEscape {
        fmt.Println("按下了 ESC 键")
        return true // 拦截事件
    }
    return false // 继续处理
})
```

#### 鼠标事件

```go
// MouseEvent 鼠标事件
type MouseEvent struct {
    Position fyne.Position      // 鼠标位置
    Button   desktop.MouseButton // 鼠标按键
}

// OnMouseDown 设置鼠标按下回调
func (t *Terminal) OnMouseDown(handler func(MouseEvent))

// OnMouseUp 设置鼠标抬起回调
func (t *Terminal) OnMouseUp(handler func(MouseEvent))

// OnMouseMove 设置鼠标移动回调
func (t *Terminal) OnMouseMove(handler func(MouseEvent))
```

### 终端协议支持

#### ANSI 转义序列

```go
// SendEscape 发送转义序列
func (t *Terminal) SendEscape(sequence string) error

// ProcessEscape 处理转义序列
func (t *Terminal) ProcessEscape(sequence []byte) error
```

**常用转义序列:**
```go
// 光标控制
term.SendEscape("\033[H")      // 光标移到左上角
term.SendEscape("\033[2J")     // 清屏
term.SendEscape("\033[K")      // 清除行

// 颜色控制
term.SendEscape("\033[31m")    // 设置红色前景
term.SendEscape("\033[42m")    // 设置绿色背景
term.SendEscape("\033[0m")     // 重置颜色
```

#### OSC 命令

```go
// SendOSC 发送 OSC 命令
func (t *Terminal) SendOSC(command string) error

// OnOSC 设置 OSC 命令处理回调
func (t *Terminal) OnOSC(handler func(string))
```

**示例:**
```go
// 设置窗口标题
term.SendOSC("0;新标题\007")

// 监听 OSC 命令
term.OnOSC(func(command string) {
    fmt.Printf("收到 OSC 命令: %s", command)
})
```

## 🔧 工具函数

### 颜色工具

```go
// ParseColor 解析颜色字符串
func ParseColor(colorStr string) (color.Color, error)

// ColorToANSI 转换颜色为 ANSI 代码
func ColorToANSI(c color.Color, foreground bool) string

// ANSIToColor 转换 ANSI 代码为颜色
func ANSIToColor(ansiCode int) color.Color
```

**示例:**
```go
// 解析十六进制颜色
c, err := terminal.ParseColor("#FF0000")
if err != nil {
    log.Printf("颜色解析失败: %v", err)
}

// 转换为 ANSI 代码
ansiCode := terminal.ColorToANSI(c, true)
fmt.Printf("ANSI 代码: %s", ansiCode)
```

### 文本工具

```go
// StripANSI 移除 ANSI 转义序列
func StripANSI(text string) string

// MeasureText 测量文本显示宽度
func MeasureText(text string) int

// WrapText 文本换行
func WrapText(text string, width int) []string
```

**示例:**
```go
// 清理 ANSI 序列
cleanText := terminal.StripANSI("\033[31mHello\033[0m World")
fmt.Println(cleanText) // 输出: "Hello World"

// 文本换行
lines := terminal.WrapText("这是一段很长的文本需要换行", 20)
for _, line := range lines {
    fmt.Println(line)
}
```

## 🔄 状态管理

### 状态类型

```go
type State int

const (
    StateIdle        State = iota // 空闲状态
    StateConnecting              // 连接中
    StateConnected               // 已连接
    StateDisconnected            // 已断开连接
    StateError                   // 错误状态
)
```

### 状态管理方法

```go
// GetState 获取当前状态
func (t *Terminal) GetState() State

// IsConnected 检查是否已连接
func (t *Terminal) IsConnected() bool

// WaitForState 等待特定状态
func (t *Terminal) WaitForState(state State, timeout time.Duration) error
```

**示例:**
```go
// 检查连接状态
if term.IsConnected() {
    fmt.Println("终端已连接")
} else {
    fmt.Println("终端未连接")
}

// 等待连接建立
ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
defer cancel()

if err := term.WaitForState(terminal.StateConnected, 5*time.Second); err != nil {
    log.Printf("等待连接超时: %v", err)
}
```

## 🎛️ 完整示例

### 基本使用示例

```go
package main

import (
    "log"
    
    "fyne.io/fyne/v2/app"
    "fyne.io/fyne/v2/container"
    "github.com/wangyiyang/Magic-Terminal"
)

func main() {
    // 创建应用
    myApp := app.New()
    myWindow := myApp.NewWindow("Terminal Example")
    myWindow.Resize(fyne.NewSize(800, 600))
    
    // 创建终端
    term := terminal.New()
    
    // 配置终端
    config := terminal.DefaultConfig()
    config.Rows = 25
    config.Columns = 80
    config.Title = "My Terminal"
    term.SetConfig(config)
    
    // 设置监听器
    term.OnOutput(func(data []byte) {
        log.Printf("终端输出: %s", data)
    })
    
    // 启动终端
    if err := term.Start(); err != nil {
        log.Fatalf("启动终端失败: %v", err)
    }
    
    // 创建界面
    content := container.NewBorder(nil, nil, nil, nil, term)
    myWindow.SetContent(content)
    
    // 显示窗口
    myWindow.ShowAndRun()
}
```

### 高级配置示例

```go
func createAdvancedTerminal() *terminal.Terminal {
    // 创建终端
    term := terminal.New()
    
    // 高级配置
    config := terminal.Config{
        Title:      "Advanced Terminal",
        Rows:       30,
        Columns:    120,
        Shell:      "/bin/zsh",
        WorkingDir: "/home/user",
        Environment: []string{
            "TERM=xterm-256color",
            "COLORTERM=truecolor",
        },
        Colors: terminal.SolarizedColorScheme(),
        Font: terminal.FontConfig{
            Family: "JetBrains Mono",
            Size:   14.0,
            Bold:   false,
            Italic: false,
        },
    }
    
    // 应用配置
    if err := term.SetConfig(config); err != nil {
        log.Printf("配置失败: %v", err)
    }
    
    // 设置事件处理
    setupEventHandlers(term)
    
    return term
}

func setupEventHandlers(term *terminal.Terminal) {
    // 输出监听
    term.OnOutput(func(data []byte) {
        // 处理终端输出
        processOutput(data)
    })
    
    // 状态变更监听
    term.OnStateChange(func(state terminal.State) {
        switch state {
        case terminal.StateConnected:
            log.Println("终端已连接")
        case terminal.StateDisconnected:
            log.Println("终端已断开")
        case terminal.StateError:
            log.Println("终端出现错误")
        }
    })
    
    // 按键拦截
    term.OnKeyDown(func(event terminal.KeyEvent) bool {
        // Ctrl+C 处理
        if event.Key == fyne.KeyC && 
           event.Modifiers&fyne.KeyModifierControl != 0 {
            handleCtrlC()
            return true
        }
        return false
    })
}
```

---

更多信息请参考：
- [架构设计](./architecture.md)
- [模块设计](./module-design.md)
- [编码规范](./coding-standards.md)
