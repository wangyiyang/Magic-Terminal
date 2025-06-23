# Magic Terminal 测试指南

## 🎯 测试策略

Magic Terminal 采用多层次的测试策略，确保代码质量和系统稳定性：

1. **单元测试**: 测试单个函数和方法
2. **集成测试**: 测试模块间的交互
3. **端到端测试**: 测试完整的用户场景
4. **性能测试**: 测试系统性能和资源使用
5. **平台测试**: 测试跨平台兼容性

## 🏗️ 测试框架和工具

### 核心测试工具

```go
// 使用的测试框架和库
import (
    "testing"
    "github.com/stretchr/testify/assert"
    "github.com/stretchr/testify/require"
    "github.com/stretchr/testify/mock"
    "github.com/stretchr/testify/suite"
)
```

### 工具链
- **Go testing**: 标准测试框架
- **testify**: 断言和 Mock 框架
- **golangci-lint**: 静态分析
- **race detector**: 并发检测
- **coverage**: 覆盖率分析

## 🧪 单元测试

### 基本测试结构

```go
// term_test.go
package terminal

import (
    "testing"
    "github.com/stretchr/testify/assert"
    "github.com/stretchr/testify/require"
)

func TestTerminal_New(t *testing.T) {
    // 测试新建终端
    term := New()
    
    assert.NotNil(t, term)
    assert.Equal(t, StateIdle, term.GetState())
    
    // 验证默认配置
    config := term.GetConfig()
    assert.Equal(t, uint(24), config.Rows)
    assert.Equal(t, uint(80), config.Columns)
}
```

### 表驱动测试

```go
func TestValidateConfig(t *testing.T) {
    tests := []struct {
        name      string
        config    Config
        wantError bool
        errorMsg  string
    }{
        {
            name: "valid config",
            config: Config{
                Rows:    24,
                Columns: 80,
                Title:   "Test Terminal",
            },
            wantError: false,
        },
        {
            name: "invalid rows - zero",
            config: Config{
                Rows:    0,
                Columns: 80,
            },
            wantError: true,
            errorMsg:  "rows must be greater than 0",
        },
        {
            name: "invalid columns - too large",
            config: Config{
                Rows:    24,
                Columns: 10000,
            },
            wantError: true,
            errorMsg:  "columns too large",
        },
    }
    
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            err := ValidateConfig(tt.config)
            
            if tt.wantError {
                require.Error(t, err)
                assert.Contains(t, err.Error(), tt.errorMsg)
            } else {
                require.NoError(t, err)
            }
        })
    }
}
```

### Mock 测试

```go
// 创建 Mock 接口
type MockPTY struct {
    mock.Mock
}

func (m *MockPTY) Read(p []byte) (n int, err error) {
    args := m.Called(p)
    return args.Int(0), args.Error(1)
}

func (m *MockPTY) Write(p []byte) (n int, err error) {
    args := m.Called(p)
    return args.Int(0), args.Error(1)
}

func (m *MockPTY) Close() error {
    args := m.Called()
    return args.Error(0)
}

// 使用 Mock 的测试
func TestTerminal_Write_WithMock(t *testing.T) {
    // 创建 Mock PTY
    mockPTY := new(MockPTY)
    
    // 设置期望
    testData := []byte("test command\n")
    mockPTY.On("Write", testData).Return(len(testData), nil)
    
    // 创建终端并注入 Mock
    term := New()
    term.pty = mockPTY  // 假设有这个字段
    
    // 执行测试
    n, err := term.Write(testData)
    
    // 验证结果
    assert.NoError(t, err)
    assert.Equal(t, len(testData), n)
    
    // 验证 Mock 调用
    mockPTY.AssertExpectations(t)
}
```

### 测试辅助函数

```go
// 测试辅助函数
func setupTestTerminal(t *testing.T) *Terminal {
    t.Helper()
    
    term := New()
    
    // 设置测试配置
    config := Config{
        Rows:    10,
        Columns: 40,
        Title:   "Test Terminal",
    }
    
    require.NoError(t, term.SetConfig(config))
    return term
}

func createTestData(size int) []byte {
    data := make([]byte, size)
    for i := range data {
        data[i] = byte('A' + (i % 26))
    }
    return data
}
```

## 🔗 集成测试

### 模块间交互测试

```go
// term_integration_test.go
// +build integration

package terminal

import (
    "context"
    "testing"
    "time"
    
    "github.com/stretchr/testify/assert"
    "github.com/stretchr/testify/require"
)

func TestTerminal_StartAndCommunication(t *testing.T) {
    if testing.Short() {
        t.Skip("跳过集成测试")
    }
    
    term := setupTestTerminal(t)
    defer term.Stop()
    
    // 启动终端
    require.NoError(t, term.Start())
    
    // 等待连接建立
    ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
    defer cancel()
    
    require.NoError(t, term.WaitForState(StateConnected, 5*time.Second))
    
    // 测试基本命令
    testBasicCommand(t, term)
    
    // 测试输入输出
    testInputOutput(t, term)
}

func testBasicCommand(t *testing.T, term *Terminal) {
    // 发送简单命令
    command := "echo 'Hello, World!'\n"
    n, err := term.WriteString(command)
    
    require.NoError(t, err)
    assert.Equal(t, len(command), n)
    
    // 等待输出
    time.Sleep(100 * time.Millisecond)
    
    // 这里可以添加输出验证逻辑
}
```

### 平台特定测试

```go
// +build !windows

func TestTerminal_UnixPTY(t *testing.T) {
    term := New()
    
    // 测试 Unix PTY 特定功能
    err := term.Start()
    require.NoError(t, err)
    defer term.Stop()
    
    // 验证 PTY 属性
    assert.True(t, term.IsConnected())
}

// +build windows

func TestTerminal_WindowsConPTY(t *testing.T) {
    term := New()
    
    // 测试 Windows ConPTY 特定功能
    err := term.Start()
    require.NoError(t, err)
    defer term.Stop()
    
    // 验证 ConPTY 属性
    assert.True(t, term.IsConnected())
}
```

## 🎭 端到端测试

### GUI 测试

```go
// e2e_test.go
// +build e2e

package main

import (
    "testing"
    "time"
    
    "fyne.io/fyne/v2/test"
    "github.com/stretchr/testify/assert"
)

func TestApplication_E2E(t *testing.T) {
    if testing.Short() {
        t.Skip("跳过端到端测试")
    }
    
    // 创建测试应用
    app := test.NewApp()
    defer app.Quit()
    
    // 启动主窗口
    window := createMainWindow(app)
    
    // 等待界面渲染
    time.Sleep(100 * time.Millisecond)
    
    // 测试界面交互
    testUserInteraction(t, window)
}

func testUserInteraction(t *testing.T, window fyne.Window) {
    // 模拟键盘输入
    test.Type(window.Canvas(), "echo hello")
    test.TypeKey(window.Canvas(), fyne.KeyReturn)
    
    // 等待执行
    time.Sleep(200 * time.Millisecond)
    
    // 验证结果
    // 这里需要根据实际实现添加验证逻辑
}
```

### 用户场景测试

```go
func TestUserScenario_BasicUsage(t *testing.T) {
    scenario := []struct {
        name   string
        action func(*Terminal) error
        verify func(*Terminal) bool
    }{
        {
            name: "启动终端",
            action: func(term *Terminal) error {
                return term.Start()
            },
            verify: func(term *Terminal) bool {
                return term.IsConnected()
            },
        },
        {
            name: "执行命令",
            action: func(term *Terminal) error {
                _, err := term.WriteString("pwd\n")
                return err
            },
            verify: func(term *Terminal) bool {
                // 验证命令执行
                return true
            },
        },
        {
            name: "修改配置",
            action: func(term *Terminal) error {
                config := term.GetConfig()
                config.Title = "Updated Title"
                return term.SetConfig(config)
            },
            verify: func(term *Terminal) bool {
                return term.GetConfig().Title == "Updated Title"
            },
        },
    }
    
    term := setupTestTerminal(t)
    defer term.Stop()
    
    for _, step := range scenario {
        t.Run(step.name, func(t *testing.T) {
            require.NoError(t, step.action(term))
            assert.True(t, step.verify(term), "验证失败: %s", step.name)
        })
    }
}
```

## ⚡ 性能测试

### Benchmark 测试

```go
func BenchmarkTerminal_Write(b *testing.B) {
    term := setupBenchmarkTerminal(b)
    defer term.Stop()
    
    data := createTestData(1024) // 1KB 数据
    
    b.ResetTimer()
    b.ReportAllocs()
    
    for i := 0; i < b.N; i++ {
        _, err := term.Write(data)
        if err != nil {
            b.Fatal(err)
        }
    }
}

func BenchmarkTerminal_Render(b *testing.B) {
    term := setupBenchmarkTerminal(b)
    defer term.Stop()
    
    // 填充终端内容
    fillTerminalWithData(term)
    
    b.ResetTimer()
    
    for i := 0; i < b.N; i++ {
        term.Refresh() // 假设有这个方法
    }
}

func BenchmarkColorParsing(b *testing.B) {
    testColors := []string{
        "\033[31m",     // 红色
        "\033[42m",     // 绿色背景
        "\033[1;33m",   // 粗体黄色
        "\033[38;5;196m", // 256色
    }
    
    b.ResetTimer()
    
    for i := 0; i < b.N; i++ {
        for _, color := range testColors {
            parseANSIColor(color) // 假设有这个函数
        }
    }
}
```

### 内存使用测试

```go
func TestTerminal_MemoryUsage(t *testing.T) {
    if testing.Short() {
        t.Skip("跳过内存测试")
    }
    
    // 记录初始内存
    var initialMem runtime.MemStats
    runtime.GC()
    runtime.ReadMemStats(&initialMem)
    
    // 创建多个终端实例
    terminals := make([]*Terminal, 10)
    for i := range terminals {
        terminals[i] = New()
        require.NoError(t, terminals[i].Start())
    }
    
    // 运行一些操作
    for _, term := range terminals {
        for j := 0; j < 100; j++ {
            term.WriteString("echo test\n")
            time.Sleep(1 * time.Millisecond)
        }
    }
    
    // 清理
    for _, term := range terminals {
        term.Stop()
    }
    
    // 强制 GC 并检查内存
    runtime.GC()
    runtime.GC() // 两次 GC 确保清理完成
    
    var finalMem runtime.MemStats
    runtime.ReadMemStats(&finalMem)
    
    // 检查内存泄漏
    memDiff := finalMem.Alloc - initialMem.Alloc
    t.Logf("内存差异: %d bytes", memDiff)
    
    // 允许一定的内存增长，但不应该过大
    maxAllowedDiff := uint64(10 * 1024 * 1024) // 10MB
    assert.Less(t, memDiff, maxAllowedDiff, "可能存在内存泄漏")
}
```

### 并发测试

```go
func TestTerminal_Concurrent(t *testing.T) {
    term := setupTestTerminal(t)
    require.NoError(t, term.Start())
    defer term.Stop()
    
    const numGoroutines = 10
    const numWrites = 100
    
    var wg sync.WaitGroup
    errors := make(chan error, numGoroutines)
    
    // 启动多个 goroutine 并发写入
    for i := 0; i < numGoroutines; i++ {
        wg.Add(1)
        go func(id int) {
            defer wg.Done()
            
            for j := 0; j < numWrites; j++ {
                data := fmt.Sprintf("goroutine %d message %d\n", id, j)
                if _, err := term.WriteString(data); err != nil {
                    errors <- err
                    return
                }
            }
        }(i)
    }
    
    // 等待所有 goroutine 完成
    wg.Wait()
    close(errors)
    
    // 检查错误
    for err := range errors {
        t.Errorf("并发写入错误: %v", err)
    }
}
```

## 🔧 测试工具和脚本

### Makefile 测试目标

```makefile
# 测试相关命令
.PHONY: test test-unit test-integration test-e2e test-bench test-coverage

# 运行所有测试
test:
	go test ./...

# 单元测试
test-unit:
	go test -short ./...

# 集成测试
test-integration:
	go test -tags=integration ./...

# 端到端测试
test-e2e:
	go test -tags=e2e ./...

# 性能测试
test-bench:
	go test -bench=. -benchmem ./...

# 覆盖率测试
test-coverage:
	go test -coverprofile=coverage.out ./...
	go tool cover -html=coverage.out -o coverage.html

# 竞态检测
test-race:
	go test -race ./...

# 详细测试
test-verbose:
	go test -v ./...

# 测试特定包
test-pkg:
	go test -v ./pkg/$(PKG)
```

### 测试数据生成

```go
// testdata/generator.go
package testdata

import (
    "math/rand"
    "time"
)

// GenerateANSISequence 生成随机 ANSI 序列
func GenerateANSISequence() string {
    sequences := []string{
        "\033[31m",      // 红色
        "\033[32m",      // 绿色
        "\033[33m",      // 黄色
        "\033[34m",      // 蓝色
        "\033[35m",      // 洋红
        "\033[36m",      // 青色
        "\033[37m",      // 白色
        "\033[0m",       // 重置
        "\033[1m",       // 粗体
        "\033[2m",       // 暗淡
        "\033[4m",       // 下划线
    }
    
    rand.Seed(time.Now().UnixNano())
    return sequences[rand.Intn(len(sequences))]
}

// GenerateRandomText 生成随机文本
func GenerateRandomText(length int) string {
    const charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 "
    
    result := make([]byte, length)
    for i := range result {
        result[i] = charset[rand.Intn(len(charset))]
    }
    
    return string(result)
}
```

## 📊 测试覆盖率和报告

### 覆盖率配置

```bash
#!/bin/bash
# scripts/test-coverage.sh

echo "运行测试覆盖率分析..."

# 运行测试并生成覆盖率文件
go test -coverprofile=coverage.out ./...

# 生成 HTML 报告
go tool cover -html=coverage.out -o coverage.html

# 显示覆盖率统计
go tool cover -func=coverage.out

# 检查覆盖率阈值
COVERAGE=$(go tool cover -func=coverage.out | grep total | awk '{print $3}' | sed 's/%//')
THRESHOLD=80

if (( $(echo "$COVERAGE < $THRESHOLD" | bc -l) )); then
    echo "警告: 测试覆盖率 $COVERAGE% 低于阈值 $THRESHOLD%"
    exit 1
else
    echo "测试覆盖率 $COVERAGE% 满足要求"
fi
```

### CI 集成

```yaml
# .github/workflows/test.yml
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        go-version: [1.23, 1.24]
    
    steps:
    - uses: actions/checkout@v3
    - uses: actions/setup-go@v3
      with:
        go-version: ${{ matrix.go-version }}
    
    - name: 安装依赖
      run: |
        sudo apt-get update
        sudo apt-get install -y libgl1-mesa-dev xorg-dev
    
    - name: 运行测试
      run: |
        make test-coverage
        make test-race
    
    - name: 上传覆盖率
      uses: codecov/codecov-action@v3
      with:
        file: ./coverage.out
```

## 🐛 测试调试

### 调试失败的测试

```go
func TestDebugExample(t *testing.T) {
    // 启用详细日志
    if testing.Verbose() {
        log.SetLevel(log.DebugLevel)
    }
    
    term := setupTestTerminal(t)
    
    // 添加测试状态检查
    t.Logf("终端状态: %v", term.GetState())
    t.Logf("配置: %+v", term.GetConfig())
    
    // 使用 require 进行关键检查
    require.True(t, term.IsConnected(), "终端应该已连接")
    
    // 添加清理回调
    t.Cleanup(func() {
        if term.IsConnected() {
            term.Stop()
        }
    })
}
```

### 测试环境变量

```bash
# 测试环境变量
export TERMINAL_TEST_TIMEOUT=30s
export TERMINAL_TEST_DEBUG=true
export TERMINAL_TEST_PTY_TYPE=native

# 运行特定测试
go test -run TestTerminal_Write -v

# 运行失败测试重试
go test -count=5 -run TestFlaky

# 运行测试直到失败
go test -count=1000 -failfast -run TestRace
```

---

更多信息请参考：
- [编码规范](./coding-standards.md)
- [开发环境配置](./development-setup.md)
- [性能优化](./performance-optimization.md)
