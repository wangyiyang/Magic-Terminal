# Magic Terminal 编码规范

## 📝 总体原则

### 1. 代码哲学
- **简洁明了**: 代码应该易于理解和维护
- **一致性**: 遵循统一的编码风格
- **性能意识**: 注重性能但不过度优化
- **安全第一**: 优先考虑代码安全性

### 2. Go 语言惯例
- 严格遵循 Go 官方编码规范
- 使用 `gofmt` 和 `goimports` 格式化代码
- 遵循 Go 语言的命名约定
- 有效使用 Go 语言特性

## 🏗️ 代码结构规范

### 1. 包组织

#### 包命名
```go
// ✅ 好的包名 - 简短、描述性
package terminal
package widget
package color

// ❌ 避免的包名 - 通用、冗长
package utils
package terminalemulator
package helper
```

#### 包导入顺序
```go
import (
    // 1. 标准库
    "context"
    "fmt"
    "os"
    
    // 2. 第三方库  
    "fyne.io/fyne/v2"
    "github.com/creack/pty"
    
    // 3. 项目内部包
    "github.com/wangyiyang/Magic-Terminal/internal/widget"
)
```

### 2. 文件组织

#### 文件命名约定
```go
// 主要功能文件
term.go              // 终端核心功能
input.go             // 输入处理
output.go            // 输出处理

// 平台特定文件
term_unix.go         // Unix 特定实现
term_windows.go      // Windows 特定实现

// 测试文件
term_test.go         // 单元测试
term_integration_test.go  // 集成测试
```

#### 文件结构模板
```go
// Package 文档注释
// Package terminal 提供终端模拟器的核心功能
package terminal

import (
    // 导入声明
)

const (
    // 包级常量
)

var (
    // 包级变量
)

type (
    // 类型定义
)

// 公共函数

// 私有函数

// 方法定义
```

## 🏷️ 命名规范

### 1. 变量命名

#### 基本规则
```go
// ✅ 推荐的命名
var terminalConfig Config
var userInput string
var isConnected bool
var maxRetries int

// ❌ 避免的命名
var tc Config        // 过于简短
var userData string  // 含糊不清
var flag bool        // 通用词汇
var num int          // 无意义
```

#### 作用域相关
```go
// 短作用域 - 简短名称可接受
for i, v := range items {
    // i, v 在短循环中可接受
}

// 长作用域 - 使用描述性名称
func ProcessTerminalOutput(terminalOutput []byte) error {
    // 使用完整的描述性名称
}
```

### 2. 函数命名

#### 公共函数
```go
// ✅ 好的函数命名
func NewTerminal() *Terminal
func (t *Terminal) Write(data []byte) (int, error)
func (t *Terminal) SetConfig(config Config) error

// 布尔返回函数使用 Is/Has 前缀
func (t *Terminal) IsConnected() bool
func (t *Terminal) HasSelection() bool
```

#### 私有函数
```go
// ✅ 私有函数命名
func (t *Terminal) processEscapeSequence(seq []byte) error
func (t *Terminal) updateCursor(pos Position) error
func validateConfig(config Config) error
```

### 3. 类型命名

#### 结构体
```go
// ✅ 好的结构体命名
type Terminal struct {
    config Config
    cursor Position
}

type ColorScheme struct {
    Foreground color.Color
    Background color.Color
}

// 接口使用 -er 后缀
type Writer interface {
    Write([]byte) (int, error)
}

type Renderer interface {
    Render() error
}
```

#### 常量
```go
// ✅ 常量命名
const (
    DefaultRows    = 24
    DefaultColumns = 80
    MaxBufferSize  = 32768
)

// 枚举类型常量
type State int

const (
    StateIdle State = iota
    StateConnecting
    StateConnected
    StateDisconnected
)
```

## 📚 文档注释规范

### 1. 包文档
```go
// Package terminal 提供了一个基于 Fyne 的终端模拟器实现。
//
// 该包包含了终端模拟器的核心功能，包括：
//   - 终端协议处理 (VT100, ANSI)
//   - 输入输出管理
//   - 跨平台 PTY 支持
//   - 颜色和渲染管理
//
// 基本使用示例：
//   terminal := terminal.New()
//   terminal.SetConfig(terminal.Config{
//       Rows: 24,
//       Columns: 80,
//   })
//   terminal.Start()
package terminal
```

### 2. 类型文档
```go
// Terminal 表示一个终端模拟器实例。
//
// Terminal 管理与底层 shell 进程的通信，处理输入输出，
// 并提供一个基于 Fyne 的图形界面。
//
// 例子：
//   term := terminal.New()
//   term.SetConfig(terminal.Config{Rows: 25, Columns: 80})
//   term.Start()
type Terminal struct {
    // ...
}
```

### 3. 函数文档
```go
// Write 将数据写入终端。
//
// 数据将被发送到底层的 shell 进程。如果终端未连接，
// 将返回错误。
//
// 参数：
//   data: 要写入的字节数据
//
// 返回：
//   写入的字节数和可能的错误
func (t *Terminal) Write(data []byte) (int, error) {
    // ...
}
```

## 🚀 性能编码规范

### 1. 内存管理

#### 避免不必要的内存分配
```go
// ✅ 重用 slice
var buffer []byte
func processData(data []byte) {
    buffer = buffer[:0]  // 重置但保留容量
    buffer = append(buffer, data...)
}

// ✅ 预分配已知大小的 slice
cells := make([]Cell, rows*columns)

// ❌ 避免在循环中分配
for i := 0; i < n; i++ {
    data := make([]byte, size)  // 每次都分配
}
```

#### 字符串处理优化
```go
// ✅ 使用 strings.Builder 构建字符串
var builder strings.Builder
builder.Grow(estimatedSize)  // 预分配
builder.WriteString("hello")
builder.WriteString(" world")
result := builder.String()

// ❌ 避免字符串连接
var result string
result += "hello"
result += " world"
```

### 2. 并发编程

#### Goroutine 使用
```go
// ✅ 合理使用 goroutine
func (t *Terminal) startReader() {
    go func() {
        defer t.cleanup()  // 确保清理
        
        buffer := make([]byte, bufferSize)
        for {
            n, err := t.pty.Read(buffer)
            if err != nil {
                return
            }
            t.processOutput(buffer[:n])
        }
    }()
}
```

#### 通道使用
```go
// ✅ 适当的通道缓冲
inputChan := make(chan []byte, 10)  // 缓冲通道
configChan := make(chan Config)     // 同步通道

// 确保通道关闭
defer close(inputChan)
```

### 3. 错误处理

#### 错误包装
```go
// ✅ 使用 fmt.Errorf 包装错误
if err := t.pty.Write(data); err != nil {
    return fmt.Errorf("failed to write to pty: %w", err)
}

// ✅ 自定义错误类型
type TerminalError struct {
    Op  string
    Err error
}

func (e *TerminalError) Error() string {
    return fmt.Sprintf("terminal %s: %v", e.Op, e.Err)
}
```

#### 错误检查
```go
// ✅ 明确的错误检查
data, err := ioutil.ReadFile(filename)
if err != nil {
    return fmt.Errorf("reading config file: %w", err)
}

// ✅ 使用 errors.Is 和 errors.As
if errors.Is(err, os.ErrNotExist) {
    // 文件不存在的特殊处理
}
```

## 🧪 测试编码规范

### 1. 测试文件组织

#### 测试命名
```go
// 文件名：term_test.go
func TestTerminal_Write(t *testing.T) {
    // 测试 Terminal.Write 方法
}

func TestTerminal_Write_InvalidInput(t *testing.T) {
    // 测试无效输入情况
}

func BenchmarkTerminal_Write(b *testing.B) {
    // 性能测试
}
```

### 2. 测试结构

#### 表驱动测试
```go
func TestValidateConfig(t *testing.T) {
    tests := []struct {
        name    string
        config  Config
        wantErr bool
    }{
        {
            name: "valid config",
            config: Config{
                Rows:    24,
                Columns: 80,
            },
            wantErr: false,
        },
        {
            name: "invalid rows",
            config: Config{
                Rows:    0,
                Columns: 80,
            },
            wantErr: true,
        },
    }
    
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            err := ValidateConfig(tt.config)
            if (err != nil) != tt.wantErr {
                t.Errorf("ValidateConfig() error = %v, wantErr %v", err, tt.wantErr)
            }
        })
    }
}
```

#### 测试辅助函数
```go
// 测试辅助函数应以 help 或 setup 开头
func setupTestTerminal(t *testing.T) *Terminal {
    t.Helper()
    
    term := New()
    // 设置测试配置
    return term
}

func helpAssertEqual(t *testing.T, got, want interface{}) {
    t.Helper()
    
    if got != want {
        t.Errorf("got %v, want %v", got, want)
    }
}
```

## 🔧 代码质量工具

### 1. 静态分析工具配置

#### golangci-lint 配置示例
```yaml
# .golangci.yml
run:
  timeout: 5m
  
linters-settings:
  goimports:
    local-prefixes: github.com/wangyiyang/Magic-Terminal
  
  gocyclo:
    min-complexity: 15
  
  govet:
    check-shadowing: true

linters:
  enable:
    - goimports
    - golint
    - govet
    - gocyclo
    - misspell
    - ineffassign
```

### 2. 预提交钩子

#### Git pre-commit hook
```bash
#!/bin/sh
# .git/hooks/pre-commit

# 格式化代码
go fmt ./...

# 运行 linter
golangci-lint run

# 运行测试
go test ./...

# 检查 go mod
go mod tidy
git diff --exit-code go.mod go.sum
```

## 📊 代码审查规范

### 1. 审查检查清单

#### 功能性
- [ ] 代码实现是否符合需求
- [ ] 边界条件是否正确处理
- [ ] 错误处理是否完整
- [ ] 并发安全性是否保证

#### 代码质量
- [ ] 命名是否清晰明确
- [ ] 函数是否过于复杂
- [ ] 是否有重复代码
- [ ] 注释是否充分且准确

#### 性能
- [ ] 是否存在性能瓶颈
- [ ] 内存使用是否合理
- [ ] 是否有不必要的分配

### 2. 代码审查模板

```markdown
## 审查总结
简要描述这次变更的目的和主要内容。

## 主要变更
- 添加/修改/删除了什么功能
- 对现有代码的影响

## 测试情况
- [ ] 单元测试已添加/更新
- [ ] 集成测试已验证
- [ ] 手动测试已完成

## 注意事项
列出需要特别关注的地方。
```

---

更多信息请参考：
- [开发环境配置](./development-setup.md)
- [测试指南](./testing-guide.md)
- [API 文档](./api-reference.md)
