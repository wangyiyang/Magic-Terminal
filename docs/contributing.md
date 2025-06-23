# Magic Terminal 贡献指南

## 🙏 欢迎贡献

感谢你对 Magic Terminal 项目的关注！我们欢迎各种形式的贡献，包括但不限于：

- 🐛 错误报告和修复
- ✨ 新功能建议和实现
- 📚 文档改进
- 🧪 测试用例添加
- 🌍 国际化翻译
- 💡 性能优化
- 🎨 UI/UX 改进

## 📋 贡献类型

### 1. Bug 报告
- 清晰描述问题现象
- 提供复现步骤
- 包含系统环境信息
- 附上相关日志或截图

### 2. 功能请求
- 详细说明功能需求
- 解释使用场景和价值
- 提供设计建议（可选）
- 考虑向后兼容性

### 3. 代码贡献
- 遵循项目编码规范
- 包含完整的测试用例
- 更新相关文档
- 确保 CI 通过

### 4. 文档贡献
- 修正错误或过时信息
- 增加缺失的文档
- 改进现有文档结构
- 提供使用示例

## 🚀 快速开始

### 1. 环境准备

```bash
# 1. Fork 项目到你的 GitHub 账户

# 2. 克隆你的 fork
git clone https://github.com/YOUR_USERNAME/Magic-Terminal.git
cd Magic-Terminal

# 3. 添加上游仓库
git remote add upstream https://github.com/wangyiyang/Magic-Terminal.git

# 4. 安装开发依赖
make dev-setup

# 5. 验证环境
make test
```

### 2. 分支策略

```bash
# 1. 同步最新代码
git checkout main
git pull upstream main

# 2. 创建功能分支
git checkout -b feature/your-feature-name

# 3. 或创建修复分支
git checkout -b fix/issue-description

# 4. 进行开发...

# 5. 提交更改
git add .
git commit -m "feat: add new feature description"

# 6. 推送到你的 fork
git push origin feature/your-feature-name

# 7. 创建 Pull Request
```

## 📝 提交规范

### Commit 消息格式

我们使用 [Conventional Commits](https://www.conventionalcommits.org/) 规范：

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

#### 类型 (type)

| 类型 | 说明 | 示例 |
|------|------|------|
| `feat` | 新功能 | `feat: add tab support` |
| `fix` | Bug 修复 | `fix: resolve memory leak in terminal` |
| `docs` | 文档更新 | `docs: update API documentation` |
| `style` | 代码格式 | `style: fix linting errors` |
| `refactor` | 代码重构 | `refactor: simplify color handling` |
| `perf` | 性能优化 | `perf: optimize rendering pipeline` |
| `test` | 测试相关 | `test: add unit tests for input handler` |
| `build` | 构建相关 | `build: update Go version to 1.24` |
| `ci` | CI 配置 | `ci: add security scan workflow` |
| `chore` | 其他杂项 | `chore: update dependencies` |

#### 示例

```bash
# 简单提交
git commit -m "feat: add support for 256 colors"

# 详细提交
git commit -m "fix: resolve cursor positioning issue

The cursor was not correctly positioned when using
certain ANSI escape sequences. This fix ensures proper
handling of cursor positioning commands.

Fixes #123"

# 破坏性变更
git commit -m "feat!: change API for color configuration

BREAKING CHANGE: ColorConfig structure has been modified.
Please update your code to use the new field names."
```

## 🔍 代码审查流程

### Pull Request 要求

#### 1. PR 标题和描述

```markdown
## 变更摘要
简要描述这次 PR 的主要变更内容。

## 变更类型
- [ ] Bug 修复
- [ ] 新功能
- [ ] 破坏性变更
- [ ] 文档更新
- [ ] 性能优化
- [ ] 代码重构

## 测试情况
- [ ] 单元测试已添加/更新
- [ ] 集成测试已验证
- [ ] 手动测试已完成
- [ ] 性能测试已验证（如适用）

## 相关 Issue
关联的 Issue 编号（如果有）：
- Closes #123
- Relates to #456

## 检查清单
- [ ] 代码遵循项目编码规范
- [ ] 所有测试通过
- [ ] 文档已更新
- [ ] CHANGELOG 已更新（如需要）
- [ ] 向后兼容性已考虑
```

#### 2. 代码质量要求

- ✅ 通过所有 CI 检查
- ✅ 代码覆盖率不下降
- ✅ 无新的 linting 错误
- ✅ 遵循项目编码规范
- ✅ 包含适当的测试用例
- ✅ 更新相关文档

#### 3. 审查过程

1. **自动检查**: CI 系统进行自动检查
2. **维护者审查**: 项目维护者进行代码审查
3. **社区反馈**: 其他贡献者可能提供建议
4. **修改完善**: 根据反馈进行修改
5. **合并**: 审查通过后合并到主分支

### 审查指南

#### 作为 PR 作者

```bash
# 提交前自检
make lint        # 代码规范检查
make test        # 运行测试
make build       # 构建验证

# 确保分支最新
git fetch upstream
git rebase upstream/main

# 推送前检查
git log --oneline -5  # 检查提交历史
```

#### 作为审查者

重点关注：

1. **功能正确性**
   - 代码是否实现了预期功能
   - 边界条件是否正确处理
   - 错误处理是否完善

2. **代码质量**
   - 是否遵循编码规范
   - 是否有代码重复
   - 命名是否清晰

3. **测试覆盖**
   - 是否有足够的测试用例
   - 测试是否覆盖边界情况
   - 集成测试是否完整

4. **文档更新**
   - API 变更是否更新文档
   - 新功能是否有使用示例
   - CHANGELOG 是否更新

## 🧪 测试指南

### 测试要求

#### 1. 单元测试

每个新功能和 Bug 修复都应该包含相应的单元测试：

```go
func TestNewFeature(t *testing.T) {
    // 测试设置
    term := setupTestTerminal(t)
    defer term.Stop()
    
    // 测试用例
    tests := []struct {
        name     string
        input    interface{}
        expected interface{}
        wantErr  bool
    }{
        {
            name:     "valid input",
            input:    validInput,
            expected: expectedOutput,
            wantErr:  false,
        },
        // 更多测试用例...
    }
    
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            // 执行测试
            result, err := term.NewFeature(tt.input)
            
            // 验证结果
            if tt.wantErr {
                assert.Error(t, err)
            } else {
                assert.NoError(t, err)
                assert.Equal(t, tt.expected, result)
            }
        })
    }
}
```

#### 2. 集成测试

对于涉及多个模块的功能，需要添加集成测试：

```go
// +build integration

func TestTerminalIntegration(t *testing.T) {
    if testing.Short() {
        t.Skip("跳过集成测试")
    }
    
    // 完整的终端操作测试
    term := setupRealTerminal(t)
    defer term.Stop()
    
    // 测试实际的 shell 交互
    require.NoError(t, term.Start())
    
    // 发送命令并验证输出
    output, err := term.ExecuteCommand("echo hello")
    require.NoError(t, err)
    assert.Contains(t, output, "hello")
}
```

#### 3. 性能测试

对于性能相关的改动，需要添加基准测试：

```go
func BenchmarkRenderPerformance(b *testing.B) {
    term := setupBenchmarkTerminal(b)
    defer term.Stop()
    
    // 准备测试数据
    prepareRenderData(term)
    
    b.ResetTimer()
    b.ReportAllocs()
    
    for i := 0; i < b.N; i++ {
        term.Render()
    }
}
```

### 运行测试

```bash
# 运行所有测试
make test

# 运行特定测试
go test -run TestSpecificFunction ./...

# 运行基准测试
make test-bench

# 运行集成测试
make test-integration

# 生成覆盖率报告
make test-coverage
```

## 📚 文档贡献

### 文档类型

1. **API 文档**: 代码注释和 API 参考
2. **用户指南**: 面向最终用户的使用说明
3. **开发文档**: 面向开发者的技术文档
4. **贡献指南**: 如何参与项目贡献

### 文档规范

#### Markdown 格式

```markdown
# 主标题

## 二级标题

### 三级标题

**加粗文本**

*斜体文本*

`行内代码`

```语言
代码块
```

| 表格 | 列 |
|------|-----|
| 数据 | 值 |

- 列表项 1
- 列表项 2

1. 有序列表 1
2. 有序列表 2

> 引用文本

[链接文本](URL)

![图片说明](图片URL)
```

#### 代码示例

```go
// 好的代码示例
func ExampleFunction() {
    // 简要注释说明
    term := terminal.New()
    
    // 配置终端
    config := terminal.Config{
        Rows:    25,
        Columns: 80,
    }
    term.SetConfig(config)
    
    // 启动终端
    if err := term.Start(); err != nil {
        log.Fatal(err)
    }
    
    // 清理资源
    defer term.Stop()
}
```

### 文档更新流程

1. **识别需求**: 确定需要更新的文档
2. **创建分支**: `git checkout -b docs/update-description`
3. **编写内容**: 遵循文档规范
4. **本地验证**: 检查格式和链接
5. **提交 PR**: 包含清晰的变更说明

## 🌍 国际化贡献

### 支持的语言

当前支持的语言：
- 英语 (en)
- 中文 (zh)
- 法语 (fr)
- 德语 (de)
- 日语 (ja)
- 西班牙语 (es)

### 翻译流程

1. **检查现有翻译**: `cmd/fyneterm/translation/`
2. **添加新语言**:
   ```bash
   # 复制英语模板
   cp cmd/fyneterm/translation/en.json cmd/fyneterm/translation/xx.json
   
   # 翻译内容
   # 编辑 xx.json 文件
   ```
3. **更新代码**: 在需要的地方添加语言支持
4. **测试翻译**: 验证翻译在界面中的显示效果

### 翻译规范

```json
{
    "Title": "Magic Terminal",
    "File": "文件",
    "Edit": "编辑",
    "View": "查看",
    "Help": "帮助",
    "Copy": "复制",
    "Paste": "粘贴",
    "Clear": "清除",
    "Settings": "设置"
}
```

## 🎯 特殊贡献类型

### 1. 性能优化

性能优化贡献需要：

- **基准测试**: 提供优化前后的性能对比
- **测量数据**: 包含具体的性能指标
- **兼容性**: 确保优化不影响功能
- **文档**: 说明优化原理和效果

```go
// 优化示例
func BenchmarkBefore(b *testing.B) {
    // 优化前的实现
}

func BenchmarkAfter(b *testing.B) {
    // 优化后的实现
}
```

### 2. 安全改进

安全相关的贡献需要：

- **漏洞分析**: 详细说明安全问题
- **修复方案**: 提供安全的解决方案
- **测试验证**: 验证修复效果
- **影响评估**: 评估对现有功能的影响

### 3. 平台支持

新平台支持需要：

- **平台调研**: 了解平台特性和限制
- **接口实现**: 实现平台特定的接口
- **测试验证**: 在目标平台上测试
- **文档更新**: 更新平台兼容性文档

## 📞 获取帮助

### 交流渠道

- **GitHub Issues**: 报告问题和功能请求
- **GitHub Discussions**: 技术讨论和问答
- **Code Review**: PR 中的代码审查讨论

### 联系维护者

如果你有任何问题或建议，可以通过以下方式联系：

- 在相关 Issue 中 @维护者
- 在 PR 中请求审查
- 发起 GitHub Discussion

### 响应时间

我们努力在以下时间内响应：

- **Bug 报告**: 48 小时内首次响应
- **功能请求**: 1 周内评估和回复
- **PR 审查**: 3-5 个工作日内审查
- **安全问题**: 24 小时内响应

## 🏆 贡献者认可

### 贡献记录

所有贡献者都会在以下地方得到认可：

- **AUTHORS 文件**: 列出所有贡献者
- **CHANGELOG**: 记录重要贡献
- **Release Notes**: 感谢重要贡献者
- **README**: 展示主要贡献者

### 贡献统计

我们使用 GitHub 的内置功能跟踪贡献：

- **Commits**: 代码提交贡献
- **Issues**: 问题报告和讨论
- **Pull Requests**: 代码和文档贡献
- **Reviews**: 代码审查贡献

感谢你考虑为 Magic Terminal 做出贡献！每一个贡献都让这个项目变得更好。🚀

---

更多信息请参考：
- [开发环境配置](./development-setup.md)
- [编码规范](./coding-standards.md)
- [测试指南](./testing-guide.md)
