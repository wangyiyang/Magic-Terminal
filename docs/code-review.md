# Magic Terminal 代码审查指南

## 🎯 概述

代码审查是 Magic Terminal 项目质量保证的核心环节。本文档定义了代码审查的标准、流程和最佳实践，确保代码质量、安全性和可维护性。

## 📋 代码审查原则

### 1. 核心原则

- **质量第一**: 代码质量优于开发速度
- **知识共享**: 通过审查传播最佳实践
- **持续改进**: 从审查中学习和改进
- **建设性反馈**: 提供有帮助的、具体的建议
- **团队协作**: 尊重和支持团队成员

### 2. 审查目标

- **功能正确性**: 代码实现符合需求规格
- **代码质量**: 遵循编码标准和最佳实践
- **性能优化**: 识别和解决性能问题
- **安全考虑**: 发现潜在的安全漏洞
- **可维护性**: 确保代码易于理解和维护

## 🔄 审查流程

### 1. 提交前准备

#### 开发者自检清单
```bash
# 代码提交前自检脚本
#!/bin/bash
echo "🔍 Pre-submission checklist..."

# 1. 代码格式化
echo "Formatting code..."
go fmt ./...
goimports -w .

# 2. 静态代码分析
echo "Running linter..."
golangci-lint run

# 3. 运行测试
echo "Running tests..."
go test ./... -race -coverprofile=coverage.out

# 4. 安全扫描
echo "Security scan..."
gosec ./...

# 5. 依赖检查
echo "Checking dependencies..."
go mod tidy
go mod verify

echo "✅ Pre-submission checks completed!"
```

#### Pull Request 创建规范
```markdown
## Pull Request 模板

### 📝 变更描述
<!-- 简要描述此 PR 的目的和变更内容 -->

### 🎯 相关 Issue
<!-- 关联的 Issue 编号，例如: Closes #123 -->

### 🧪 测试覆盖
- [ ] 添加了单元测试
- [ ] 添加了集成测试
- [ ] 手动测试通过
- [ ] 性能测试通过

### 📋 检查清单
- [ ] 代码遵循项目编码规范
- [ ] 添加了必要的文档
- [ ] 没有引入新的安全漏洞
- [ ] 向后兼容性检查通过
- [ ] CI/CD 流水线通过

### 🖼️ 截图/演示
<!-- 如果是 UI 相关变更，请提供截图或录屏 -->

### 💡 补充信息
<!-- 其他需要审查者了解的信息 -->
```

### 2. 审查分配

#### 自动分配规则
```yaml
# .github/CODEOWNERS
# 全局默认审查者
* @project-maintainers

# 核心终端功能
term.go @terminal-experts
input.go @terminal-experts
output.go @terminal-experts

# UI 相关
cmd/fyneterm/ @ui-experts
internal/widget/ @ui-experts

# 平台特定代码
term_unix.go @unix-experts
term_windows.go @windows-experts

# 文档
docs/ @documentation-team
*.md @documentation-team

# CI/CD 和构建
.github/ @devops-team
Makefile @devops-team
scripts/ @devops-team

# 安全相关
auth/ @security-team
crypto/ @security-team
```

#### 审查者选择标准
- **领域专家**: 具有相关模块经验的开发者
- **资深开发者**: 有经验的团队成员
- **代码所有者**: 模块的主要维护者
- **至少两名审查者**: 确保多重验证

### 3. 审查执行

#### 审查检查点

**🔍 代码结构和设计**
```go
// ✅ 好的例子: 清晰的接口设计
type TerminalRenderer interface {
    Render(content [][]Cell) error
    SetSize(rows, cols int) error
    Clear() error
}

// ❌ 不好的例子: 过于复杂的函数
func processTerminalInputWithComplexLogicAndMultipleResponsibilities(
    input []byte, 
    config *Config, 
    state *State, 
    callbacks []Callback,
) (*Result, error) {
    // 函数过长，职责不明确
}
```

**📏 代码质量标准**
```go
// ✅ 好的例子: 清晰的错误处理
func (t *Terminal) processInput(data []byte) error {
    if len(data) == 0 {
        return fmt.Errorf("input data cannot be empty")
    }
    
    if err := t.validateInput(data); err != nil {
        return fmt.Errorf("input validation failed: %w", err)
    }
    
    return t.handleInput(data)
}

// ❌ 不好的例子: 忽略错误
func (t *Terminal) processInput(data []byte) {
    t.validateInput(data) // 忽略错误
    t.handleInput(data)   // 可能因为上面的错误而失败
}
```

**🧪 测试覆盖检查**
```go
// ✅ 好的例子: 完整的测试覆盖
func TestTerminal_ProcessInput(t *testing.T) {
    tests := []struct {
        name     string
        input    []byte
        expected string
        wantErr  bool
    }{
        {
            name:     "valid input",
            input:    []byte("hello"),
            expected: "hello",
            wantErr:  false,
        },
        {
            name:     "empty input",
            input:    []byte{},
            expected: "",
            wantErr:  true,
        },
        {
            name:     "invalid characters",
            input:    []byte{0xFF, 0xFE},
            expected: "",
            wantErr:  true,
        },
    }
    
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            term := NewTerminal()
            err := term.ProcessInput(tt.input)
            
            if tt.wantErr {
                assert.Error(t, err)
            } else {
                assert.NoError(t, err)
                assert.Equal(t, tt.expected, term.GetOutput())
            }
        })
    }
}
```

**🔒 安全性检查**
```go
// ✅ 好的例子: 输入验证和边界检查
func (t *Terminal) setCursorPosition(row, col int) error {
    if row < 0 || row >= t.rows {
        return fmt.Errorf("row %d out of bounds [0, %d)", row, t.rows)
    }
    if col < 0 || col >= t.cols {
        return fmt.Errorf("col %d out of bounds [0, %d)", col, t.cols)
    }
    
    t.cursorRow = row
    t.cursorCol = col
    return nil
}

// ❌ 不好的例子: 没有边界检查
func (t *Terminal) setCursorPosition(row, col int) {
    t.grid[row][col] = cursor // 可能导致数组越界
}
```

**⚡ 性能考虑**
```go
// ✅ 好的例子: 高效的字符串操作
func (t *Terminal) buildOutput() string {
    var builder strings.Builder
    builder.Grow(t.rows * t.cols) // 预分配容量
    
    for _, row := range t.grid {
        for _, cell := range row {
            builder.WriteRune(cell.Char)
        }
        builder.WriteByte('\n')
    }
    
    return builder.String()
}

// ❌ 不好的例子: 频繁的字符串拼接
func (t *Terminal) buildOutput() string {
    output := ""
    for _, row := range t.grid {
        for _, cell := range row {
            output += string(cell.Char) // 每次都重新分配内存
        }
        output += "\n"
    }
    return output
}
```

### 4. 审查反馈

#### 反馈分类
```markdown
## 反馈类型标识

### 🚨 Critical (必须修复)
- 安全漏洞
- 功能缺陷
- 数据丢失风险
- 性能严重问题

### ⚠️ Major (强烈建议修复)
- 代码质量问题
- 设计模式违反
- 测试覆盖不足
- 文档缺失

### 💡 Minor (建议优化)
- 代码风格问题
- 变量命名优化
- 注释改进
- 小的重构建议

### 🤔 Question (讨论)
- 设计决策疑问
- 实现方案讨论
- 需求理解确认
```

#### 反馈示例
```markdown
## 📝 审查反馈示例

### 🚨 Critical: 潜在的内存泄漏
**位置**: `term.go:145`
```go
// 问题代码
func (t *Terminal) addSession() {
    session := &Session{}
    t.sessions = append(t.sessions, session)
    // 缺少清理机制
}
```
**建议**: 需要在会话结束时从切片中移除，否则会导致内存泄漏。

### ⚠️ Major: 错误处理不当
**位置**: `input.go:67`
```go
// 问题代码
result, _ := processInput(data) // 忽略错误
```
**建议**: 应该检查和处理错误，避免静默失败。

### 💡 Minor: 变量命名可以更清晰
**位置**: `render.go:23`
```go
// 当前代码
var n int
// 建议改为
var cellCount int
```
**建议**: 使用更具描述性的变量名提高代码可读性。
```

## 🤝 审查礼仪

### 1. 给出反馈时

#### 积极的表达方式
```markdown
✅ 好的反馈表达:
- "考虑使用 strings.Builder 来提高性能"
- "这里可能需要添加边界检查"
- "建议添加单元测试覆盖这个分支"
- "这个实现很巧妙！不过如果添加注释会更好"

❌ 避免的表达方式:
- "这代码写得不行"
- "你为什么这样写？"
- "这完全是错的"
- "明显有问题"
```

#### 建设性建议
```markdown
## 如何给出建设性建议

### 1. 具体明确
❌ "这里有性能问题"
✅ "这个循环的时间复杂度是 O(n²)，建议使用 map 来优化到 O(n)"

### 2. 提供解决方案
❌ "这个设计不好"
✅ "当前的紧耦合设计可能影响测试，建议使用依赖注入"

### 3. 解释原因
❌ "不要这样写"
✅ "建议避免在循环中分配内存，因为这可能导致频繁的 GC"
```

### 2. 接收反馈时

#### 正确的态度
- **开放心态**: 将反馈视为学习机会
- **专业回应**: 基于技术讨论，避免情绪化
- **积极改进**: 快速响应和修复问题
- **感谢审查者**: 认可审查者的时间和努力

#### 回应示例
```markdown
✅ 好的回应:
- "感谢指出这个问题，我会添加边界检查"
- "你说得对，我重构一下这个函数"
- "好建议！我没考虑到这种情况"
- "我更新了测试覆盖，请再看看"

❌ 避免的回应:
- "这样写没问题"
- "我觉得不需要改"
- "这是故意这样设计的"（没有说明原因）
```

## 🛠️ 工具和自动化

### 1. 自动化检查工具

#### GitHub Actions 自动审查
```yaml
name: Automated Code Review
on:
  pull_request:
    types: [opened, synchronize]

jobs:
  automated-review:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    
    - name: Set up Go
      uses: actions/setup-go@v4
      with:
        go-version: '1.23'
    
    - name: Run linters
      uses: golangci/golangci-lint-action@v3
      with:
        version: latest
        args: --timeout=5m
    
    - name: Security scan
      uses: securecodewarrior/github-action-add-sarif@v1
      with:
        sarif-file: gosec-report.sarif
    
    - name: Test coverage
      run: |
        go test ./... -race -coverprofile=coverage.out
        go tool cover -html=coverage.out -o coverage.html
    
    - name: Comment PR
      uses: actions/github-script@v6
      with:
        script: |
          const fs = require('fs');
          const coverage = fs.readFileSync('coverage.out', 'utf8');
          // 解析覆盖率并评论到 PR
```

#### 预提交钩子
```bash
#!/bin/bash
# .git/hooks/pre-commit

echo "Running pre-commit checks..."

# 格式化代码
gofmt -l -s -w .
goimports -w .

# 运行 linter
golangci-lint run

# 运行快速测试
go test ./... -short

# 检查 go.mod
go mod tidy

echo "Pre-commit checks passed!"
```

### 2. 代码质量度量

#### 质量指标收集
```go
// 代码质量指标收集
type CodeQualityMetrics struct {
    TestCoverage    float64 `json:"test_coverage"`
    CyclomaticComplexity int `json:"cyclomatic_complexity"`
    LinesOfCode     int     `json:"lines_of_code"`
    DuplicationRate float64 `json:"duplication_rate"`
    TechnicalDebt   int     `json:"technical_debt_minutes"`
}

func collectQualityMetrics() CodeQualityMetrics {
    // 使用工具收集质量指标
    return CodeQualityMetrics{
        TestCoverage:         getCoveragePercentage(),
        CyclomaticComplexity: getCyclomaticComplexity(),
        LinesOfCode:          countLinesOfCode(),
        DuplicationRate:      calculateDuplication(),
        TechnicalDebt:        estimateTechnicalDebt(),
    }
}
```

## 📊 审查度量和改进

### 1. 审查效果度量

#### 关键指标
- **审查覆盖率**: 每个 PR 的审查者数量
- **审查时间**: 从提交到审查完成的时间
- **缺陷发现率**: 审查中发现的问题数量
- **修复时间**: 从发现问题到修复的时间
- **重复审查率**: 需要多轮审查的 PR 比例

#### 度量脚本
```bash
#!/bin/bash
# review-metrics.sh

# 计算平均审查时间
function avg_review_time() {
    gh pr list --state merged --limit 100 --json createdAt,mergedAt | \
    jq -r '.[] | (.mergedAt | fromdateiso8601) - (.createdAt | fromdateiso8601)' | \
    awk '{sum+=$1; count++} END {print "Average review time:", sum/count/3600, "hours"}'
}

# 计算审查覆盖率
function review_coverage() {
    gh pr list --state merged --limit 50 --json number | \
    jq -r '.[] | .number' | \
    while read pr; do
        reviews=$(gh pr view $pr --json reviews --jq '.reviews | length')
        echo "PR #$pr: $reviews reviews"
    done
}
```

### 2. 持续改进

#### 定期审查回顾
```markdown
## 月度审查回顾会议议程

### 📈 数据回顾 (15分钟)
- 审查指标趋势分析
- 质量指标变化
- 常见问题统计

### 🔍 流程改进 (20分钟)
- 审查流程痛点讨论
- 工具效果评估
- 自动化机会识别

### 📚 知识分享 (20分钟)
- 最佳实践分享
- 新技术和工具介绍
- 团队经验交流

### 🎯 行动计划 (5分钟)
- 下月改进目标
- 责任人分配
- 时间节点确定
```

#### 培训计划
```markdown
## 代码审查能力提升计划

### 新成员培训
- [ ] 代码审查指南学习
- [ ] 工具使用培训
- [ ] 导师配对计划
- [ ] 实践审查练习

### 进阶培训
- [ ] 安全审查专项培训
- [ ] 性能优化最佳实践
- [ ] 架构设计原则
- [ ] 跨团队协作技巧

### 专家认证
- [ ] 审查技能评估
- [ ] 领域专家认证
- [ ] 培训师资格
- [ ] 持续教育计划
```

## 📚 参考资源

### 1. 工具清单
- **golangci-lint**: Go 代码静态分析工具
- **gosec**: Go 安全扫描工具
- **gocyclo**: 圈复杂度分析工具
- **ineffassign**: 无效赋值检测工具
- **misspell**: 拼写检查工具

### 2. 参考文献
- [Google 代码审查指南](https://google.github.io/eng-practices/review/)
- [Effective Go](https://golang.org/doc/effective_go.html)
- [Go Code Review Comments](https://github.com/golang/go/wiki/CodeReviewComments)
- [Clean Code](https://www.amazon.com/Clean-Code-Handbook-Software-Craftsmanship/dp/0132350884)

### 3. 社区资源
- [Go 社区代码审查实践](https://github.com/golang/go/wiki/CodeReview)
- [开源项目审查案例](https://github.com/kubernetes/community/blob/master/contributors/guide/reviewing.md)

通过建立系统化的代码审查体系，Magic Terminal 项目能够维持高质量的代码标准，促进知识共享，并确保项目的长期健康发展。
