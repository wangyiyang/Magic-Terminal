# Magic Terminal 终端协议支持文档

## 📡 支持的终端协议概览

Magic Terminal 实现了广泛的终端协议和标准，确保与各种应用程序和 shell 的兼容性。

### 核心协议支持
- **VT100/VT220**: 经典终端协议，广泛兼容
- **ANSI X3.64**: 标准 ANSI 转义序列
- **xterm**: 扩展功能和现代特性
- **256色和真彩色**: 完整的颜色支持
- **Unicode**: 完整的 UTF-8 字符支持

## 🎨 ANSI 转义序列支持

### 基本格式
ANSI 转义序列以 ESC 字符（\033 或 \x1B）开始，后跟特定的控制字符和参数。

```
格式: ESC [ <参数> <命令字符>
示例: \033[31m  (设置红色前景)
```

### 光标控制序列

| 序列 | 功能 | 参数说明 |
|------|------|----------|
| `ESC[H` | 光标移到左上角 | 无参数 |
| `ESC[{row};{col}H` | 光标移到指定位置 | row: 行号, col: 列号 |
| `ESC[{n}A` | 光标上移 n 行 | n: 移动行数 |
| `ESC[{n}B` | 光标下移 n 行 | n: 移动行数 |
| `ESC[{n}C` | 光标右移 n 列 | n: 移动列数 |
| `ESC[{n}D` | 光标左移 n 列 | n: 移动列数 |
| `ESC[s` | 保存光标位置 | 无参数 |
| `ESC[u` | 恢复光标位置 | 无参数 |

**实现示例:**
```go
func (t *Terminal) processCursorCommand(command byte, params []int) {
    switch command {
    case 'H', 'f': // 光标定位
        row, col := 1, 1
        if len(params) > 0 {
            row = params[0]
        }
        if len(params) > 1 {
            col = params[1]
        }
        t.setCursorPosition(row-1, col-1)
        
    case 'A': // 光标上移
        n := 1
        if len(params) > 0 {
            n = params[0]
        }
        t.moveCursor(-n, 0)
    }
}
```

### 屏幕清除序列

| 序列 | 功能 | 说明 |
|------|------|------|
| `ESC[2J` | 清除整个屏幕 | 清除所有内容 |
| `ESC[1J` | 清除从光标到屏幕开始 | 部分清除 |
| `ESC[0J` | 清除从光标到屏幕结束 | 部分清除 |
| `ESC[K` | 清除当前行 | 从光标到行尾 |
| `ESC[1K` | 清除从行首到光标 | 部分清除行 |
| `ESC[2K` | 清除整行 | 完整清除 |

**实现示例:**
```go
func (t *Terminal) processEraseCommand(command byte, params []int) {
    switch command {
    case 'J': // 清除屏幕
        mode := 0
        if len(params) > 0 {
            mode = params[0]
        }
        t.eraseDisplay(mode)
        
    case 'K': // 清除行
        mode := 0
        if len(params) > 0 {
            mode = params[0]
        }
        t.eraseLine(mode)
    }
}
```

### 颜色和样式序列

#### 前景色 (30-37, 90-97)

| 序列 | 颜色 | 亮色版本 |
|------|------|----------|
| `ESC[30m` | 黑色 | `ESC[90m` |
| `ESC[31m` | 红色 | `ESC[91m` |
| `ESC[32m` | 绿色 | `ESC[92m` |
| `ESC[33m` | 黄色 | `ESC[93m` |
| `ESC[34m` | 蓝色 | `ESC[94m` |
| `ESC[35m` | 洋红 | `ESC[95m` |
| `ESC[36m` | 青色 | `ESC[96m` |
| `ESC[37m` | 白色 | `ESC[97m` |

#### 背景色 (40-47, 100-107)

| 序列 | 颜色 | 亮色版本 |
|------|------|----------|
| `ESC[40m` | 黑色背景 | `ESC[100m` |
| `ESC[41m` | 红色背景 | `ESC[101m` |
| `ESC[42m` | 绿色背景 | `ESC[102m` |
| `ESC[43m` | 黄色背景 | `ESC[103m` |
| `ESC[44m` | 蓝色背景 | `ESC[104m` |
| `ESC[45m` | 洋红背景 | `ESC[105m` |
| `ESC[46m` | 青色背景 | `ESC[106m` |
| `ESC[47m` | 白色背景 | `ESC[107m` |

#### 文本样式

| 序列 | 功能 | 说明 |
|------|------|------|
| `ESC[0m` | 重置所有样式 | 恢复默认 |
| `ESC[1m` | 粗体 | 加粗文本 |
| `ESC[2m` | 暗淡 | 降低亮度 |
| `ESC[3m` | 斜体 | 倾斜文本 |
| `ESC[4m` | 下划线 | 文本下划线 |
| `ESC[5m` | 闪烁 | 文本闪烁 |
| `ESC[7m` | 反显 | 前景背景互换 |
| `ESC[8m` | 隐藏 | 文本不可见 |
| `ESC[9m` | 删除线 | 文本删除线 |

**颜色处理实现:**
```go
func (t *Terminal) processColorCommand(params []int) {
    for i := 0; i < len(params); i++ {
        param := params[i]
        
        switch {
        case param == 0: // 重置
            t.resetStyle()
            
        case param >= 30 && param <= 37: // 前景色
            t.setForegroundColor(t.getStandardColor(param - 30))
            
        case param >= 40 && param <= 47: // 背景色
            t.setBackgroundColor(t.getStandardColor(param - 40))
            
        case param == 38: // 扩展前景色
            i += t.processExtendedColor(params[i:], true)
            
        case param == 48: // 扩展背景色
            i += t.processExtendedColor(params[i:], false)
        }
    }
}
```

### 256色支持

#### 格式
- 前景色: `ESC[38;5;{n}m`
- 背景色: `ESC[48;5;{n}m`

#### 颜色范围
- **0-15**: 标准 16 色
- **16-231**: 216色立方体 (6×6×6)
- **232-255**: 24级灰度

**实现示例:**
```go
func (t *Terminal) process256Color(colorIndex int) color.Color {
    switch {
    case colorIndex <= 15:
        return t.getStandardColor(colorIndex)
        
    case colorIndex <= 231:
        // 216色立方体计算
        index := colorIndex - 16
        r := index / 36
        g := (index % 36) / 6
        b := index % 6
        return color.RGBA{
            R: uint8(r * 51),
            G: uint8(g * 51), 
            B: uint8(b * 51),
            A: 255,
        }
        
    default:
        // 灰度色彩
        gray := uint8((colorIndex-232)*10 + 8)
        return color.RGBA{R: gray, G: gray, B: gray, A: 255}
    }
}
```

### 真彩色支持 (24位)

#### 格式
- 前景色: `ESC[38;2;{r};{g};{b}m`
- 背景色: `ESC[48;2;{r};{g};{b}m`

**实现示例:**
```go
func (t *Terminal) processTrueColor(r, g, b int) color.Color {
    return color.RGBA{
        R: uint8(clamp(r, 0, 255)),
        G: uint8(clamp(g, 0, 255)),
        B: uint8(clamp(b, 0, 255)),
        A: 255,
    }
}

func clamp(value, min, max int) int {
    if value < min {
        return min
    }
    if value > max {
        return max
    }
    return value
}
```

## 🔧 OSC (Operating System Commands)

OSC 序列格式: `ESC ] {命令} ; {数据} ESC \` 或 `ESC ] {命令} ; {数据} BEL`

### 支持的 OSC 命令

| 命令 | 功能 | 格式 | 示例 |
|------|------|------|------|
| `0` | 设置窗口标题和图标 | `ESC]0;title\007` | `ESC]0;My Terminal\007` |
| `1` | 设置图标标题 | `ESC]1;title\007` | `ESC]1;Terminal\007` |
| `2` | 设置窗口标题 | `ESC]2;title\007` | `ESC]2;Magic Terminal\007` |
| `4` | 设置调色板颜色 | `ESC]4;n;color\007` | `ESC]4;1;#ff0000\007` |
| `10` | 设置前景色 | `ESC]10;color\007` | `ESC]10;#ffffff\007` |
| `11` | 设置背景色 | `ESC]11;color\007` | `ESC]11;#000000\007` |
| `12` | 设置光标色 | `ESC]12;color\007` | `ESC]12;#00ff00\007` |

**OSC 处理实现:**
```go
func (t *Terminal) processOSC(command string) error {
    parts := strings.SplitN(command, ";", 2)
    if len(parts) < 2 {
        return fmt.Errorf("invalid OSC command: %s", command)
    }
    
    cmd := parts[0]
    data := parts[1]
    
    switch cmd {
    case "0", "2": // 设置窗口标题
        t.setWindowTitle(data)
        
    case "1": // 设置图标标题
        t.setIconTitle(data)
        
    case "4": // 设置调色板
        return t.setPaletteColor(data)
        
    case "10": // 前景色
        return t.setDefaultForeground(data)
        
    case "11": // 背景色
        return t.setDefaultBackground(data)
        
    default:
        // 未知命令，忽略
        return nil
    }
    
    return nil
}
```

## 🎯 APC (Application Program Commands)

APC 序列格式: `ESC _ {数据} ESC \`

Magic Terminal 支持一些自定义的 APC 命令：

### 自定义 APC 命令

| 命令 | 功能 | 格式 |
|------|------|------|
| `config` | 运行时配置更新 | `ESC_config;key=value\ESC\` |
| `theme` | 主题切换 | `ESC_theme;theme_name\ESC\` |
| `notification` | 显示通知 | `ESC_notification;message\ESC\` |

**APC 处理实现:**
```go
func (t *Terminal) processAPC(data string) error {
    parts := strings.SplitN(data, ";", 2)
    if len(parts) == 0 {
        return nil
    }
    
    command := parts[0]
    args := ""
    if len(parts) > 1 {
        args = parts[1]
    }
    
    switch command {
    case "config":
        return t.processConfigCommand(args)
        
    case "theme":
        return t.processThemeCommand(args)
        
    case "notification":
        return t.processNotificationCommand(args)
        
    default:
        return fmt.Errorf("unknown APC command: %s", command)
    }
}
```

## 🖱️ 鼠标协议支持

### 鼠标模式

| 模式 | 序列 | 功能 |
|------|------|------|
| X10 | `ESC[?9h` | 基本鼠标支持 |
| Normal | `ESC[?1000h` | 鼠标点击和释放 |
| Highlight | `ESC[?1001h` | 鼠标高亮跟踪 |
| Button Event | `ESC[?1002h` | 鼠标按钮事件 |
| Any Event | `ESC[?1003h` | 所有鼠标事件 |
| UTF-8 | `ESC[?1005h` | UTF-8 编码鼠标 |
| SGR | `ESC[?1006h` | SGR 编码鼠标 |
| URXVT | `ESC[?1015h` | URXVT 编码鼠标 |

### 鼠标事件编码

#### 标准编码格式
`ESC[M{button}{x}{y}`

#### SGR 编码格式  
`ESC[<{button};{x};{y}M` (按下)
`ESC[<{button};{x};{y}m` (释放)

**鼠标处理实现:**
```go
func (t *Terminal) handleMouseEvent(event *desktop.MouseEvent) {
    if !t.mouseMode.enabled {
        return
    }
    
    x, y := t.screenToCell(event.Position.X, event.Position.Y)
    
    switch t.mouseMode.encoding {
    case MouseEncodingSGR:
        t.sendSGRMouseEvent(event.Button, x, y, event.Type)
        
    case MouseEncodingUTF8:
        t.sendUTF8MouseEvent(event.Button, x, y, event.Type)
        
    default:
        t.sendStandardMouseEvent(event.Button, x, y, event.Type)
    }
}

func (t *Terminal) sendSGRMouseEvent(button desktop.MouseButton, x, y int, eventType EventType) {
    buttonCode := t.getMouseButtonCode(button)
    mode := "M"
    if eventType == EventMouseRelease {
        mode = "m"
    }
    
    sequence := fmt.Sprintf("\033[<%d;%d;%d%s", buttonCode, x+1, y+1, mode)
    t.sendToShell([]byte(sequence))
}
```

## 📱 移动和触摸支持

### 触摸事件转换
Magic Terminal 将触摸事件转换为相应的鼠标事件：

```go
func (t *Terminal) handleTouchEvent(event *mobile.TouchEvent) {
    mouseEvent := &desktop.MouseEvent{
        Position: fyne.Position{X: event.Position.X, Y: event.Position.Y},
        Button:   desktop.MouseButtonPrimary,
    }
    
    switch event.Type {
    case mobile.TouchStart:
        mouseEvent.Type = EventMousePress
        
    case mobile.TouchEnd:
        mouseEvent.Type = EventMouseRelease
        
    case mobile.TouchMove:
        mouseEvent.Type = EventMouseMove
    }
    
    t.handleMouseEvent(mouseEvent)
}
```

## 🔍 协议检测和兼容性

### 终端能力查询

应用程序可以查询终端支持的功能：

```go
// 发送设备属性查询
func (t *Terminal) handleDeviceAttributesQuery() {
    // 响应支持的功能
    response := "\033[?1;2;6;7;8;9;15;18;21;22c"
    t.sendToShell([]byte(response))
}

// 功能位含义:
// 1: 132 列模式
// 2: 打印机端口
// 6: 选择性擦除
// 7: 软字符
// 8: 用户定义键
// 9: 国家替换字符集
// 15: 技术字符集
// 18: 用户窗口
// 21: 水平滚动
// 22: 颜色
```

### 协议版本协商

```go
func (t *Terminal) negotiateProtocol() {
    // 查询终端类型
    t.sendToShell([]byte("\033[>q"))
    
    // 设置兼容模式
    t.protocolLevel = ProtocolVT220
    t.mouseSupport = true
    t.colorSupport = ColorSupport256
    t.unicodeSupport = true
}
```

## 🧪 协议测试和验证

### 测试用例

```go
func TestANSIColorParsing(t *testing.T) {
    tests := []struct {
        input    string
        expected color.Color
    }{
        {"\033[31m", color.RGBA{R: 255, G: 0, B: 0, A: 255}},
        {"\033[38;5;196m", color.RGBA{R: 255, G: 0, B: 0, A: 255}},
        {"\033[38;2;255;128;0m", color.RGBA{R: 255, G: 128, B: 0, A: 255}},
    }
    
    terminal := setupTestTerminal(t)
    
    for _, test := range tests {
        terminal.processOutput([]byte(test.input))
        assert.Equal(t, test.expected, terminal.getCurrentForeground())
    }
}

func TestOSCCommands(t *testing.T) {
    terminal := setupTestTerminal(t)
    
    // 测试标题设置
    terminal.processOutput([]byte("\033]2;Test Title\007"))
    assert.Equal(t, "Test Title", terminal.getWindowTitle())
    
    // 测试颜色设置
    terminal.processOutput([]byte("\033]11;#ff0000\007"))
    expected := color.RGBA{R: 255, G: 0, B: 0, A: 255}
    assert.Equal(t, expected, terminal.getDefaultBackground())
}
```

### 兼容性测试

```bash
#!/bin/bash
# scripts/test-protocols.sh

echo "测试 ANSI 颜色支持..."
echo -e "\033[31m红色\033[0m \033[32m绿色\033[0m \033[34m蓝色\033[0m"

echo "测试 256 色支持..."
for i in {0..255}; do
    echo -en "\033[38;5;${i}m█\033[0m"
    if (( i % 16 == 15 )); then
        echo
    fi
done

echo "测试真彩色支持..."
for ((r=0; r<=255; r+=32)); do
    for ((g=0; g<=255; g+=32)); do
        for ((b=0; b<=255; b+=32)); do
            echo -en "\033[38;2;${r};${g};${b}m█\033[0m"
        done
    done
    echo
done

echo "测试光标控制..."
echo -e "\033[2J\033[H光标在左上角"
echo -e "\033[10;10H光标在 (10,10)"
echo -e "\033[s保存光标位置"
echo -e "\033[20;20H移到 (20,20)"
echo -e "\033[u恢复光标位置"
```

---

更多信息请参考：
- [API 文档](./api-reference.md)
- [模块设计](./module-design.md)
- [测试指南](./testing-guide.md)
