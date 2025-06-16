<p align="center">
  <a href="https://goreportcard.com/report/github.com/wangyiyang/Magic-Terminal"><img src="https://goreportcard.com/badge/github.com/wangyiyang/Magic-Terminal" alt="Go 报告卡" /></a>
  <a href="https://github.com/wangyiyang/Magic-Terminal/actions"><img src="https://github.com/wangyiyang/Magic-Terminal/actions/workflows/platform_tests.yml/badge.svg" alt="平台测试" /></a>
  <a href="https://github.com/wangyiyang/Magic-Terminal/releases"><img src="https://img.shields.io/github/v/release/wangyiyang/Magic-Terminal?style=flat-square" alt="最新版本" /></a>
  <a href="https://github.com/wangyiyang/Magic-Terminal/blob/main/LICENSE"><img src="https://img.shields.io/github/license/wangyiyang/Magic-Terminal?style=flat-square" alt="许可证" /></a>
  <a href="https://github.com/wangyiyang/Magic-Terminal"><img src="https://img.shields.io/github/stars/wangyiyang/Magic-Terminal?style=flat-square" alt="GitHub Stars" /></a>
</p>

# Magic Terminal

一个使用 Fyne 工具包构建的终端模拟器，支持 Linux、macOS、Windows 和 BSD 系统。
基于 [fyne-io/terminal](https://github.com/fyne-io/terminal) 开发，增加了额外的功能和增强特性。

**中文文档 | [English](README.md)**

在 Linux 上运行，使用自定义 zsh 主题。
<img alt="截图" src="img/linux.png" width="929" />

在 macOS 上运行，使用 powerlevel10k zsh 主题和经典样式。
<img alt="截图" src="img/macos.png" width="912" />

在 Windows 上运行，内置 PowerShell。
<img alt="截图" src="img/windows.png" width="900" />

# 命令行安装

只需使用 go get 命令（您需要先安装 Go 和 C 编译器）：

```bash
go install github.com/wangyiyang/Magic-Terminal/cmd/fyneterm@latest
```

# 作为应用程序安装

要将应用程序与其他应用程序一起安装（包含元数据、图标等），
请使用 `fyne` 工具，如下所示：

```bash
go get fyne.io/fyne/v2/cmd/fyne
fyne get github.com/wangyiyang/Magic-Terminal/cmd/fyneterm
```

# 待办事项

这个应用程序还有很多很棒的功能可以添加。
已计划的功能包括：

* 标签页
* 滚动回溯
* 背景和字体/大小自定义
* 分割面板

# 库使用

您也可以将此项目用作库来创建自己的基于终端的应用程序，
使用导入路径 "github.com/wangyiyang/Magic-Terminal"。

有两种模式：使用默认 shell 或连接到远程 shell。

## 本地 Shell

要加载终端小部件并启动当前 shell（适用于 macOS 和 Linux；
在 Windows 上，它始终使用 PowerShell），请在创建 `Terminal` 后使用 `RunLocalShell` 方法，
如下所示：

```go
 // 运行新终端并在终端退出时关闭应用程序
 t := terminal.New()
 go func() {
  _ = t.RunLocalShell()
  log.Printf("终端 shell 退出，退出代码：%d", t.ExitCode())
  a.Quit()
 }()

 // w 是创建用于保存内容的 fyne.Window
 w.SetContent(t)
 w.ShowAndRun()
```

## 远程连接

例如，打开一个到您已创建的 SSH 连接的终端：

```go
 // session 是来自 golang.org/x/crypto/ssh 的 *ssh.Session
 in, _ := session.StdinPipe()
 out, _ := session.StdoutPipe()
 go session.Run("$SHELL || bash")

 // 运行新终端并在终端退出时关闭应用程序
 t := terminal.New()
 go func() {
  _ = t.RunWithConnection(in, out)
  a.Quit()
 }()

 // 可选：动态调整终端会话大小
 ch := make(chan terminal.Config)
 go func() {
  rows, cols := uint(0), uint(0)
  for {
   config := <-ch
   if rows == config.Rows && cols == config.Columns {
    continue
   }
   rows, cols = config.Rows, config.Columns
   session.WindowChange(int(rows), int(cols))
  }
 }()
 t.AddListener(ch)

 // w 是创建用于保存内容的 fyne.Window
 w.SetContent(t)
 w.ShowAndRun()
```

## 特性

* 🚀 **跨平台支持**：支持 Linux、macOS、Windows 和 BSD
* 🎨 **现代 UI**：基于 Fyne 工具包的美观界面
* ⚡ **高性能**：优化的终端渲染和响应
* 🔧 **可自定义**：支持主题和配置自定义
* 📚 **库模式**：可作为库集成到其他项目中
* 🌐 **远程连接**：支持 SSH 等远程连接

## 构建要求

* Go 1.19 或更高版本
* C 编译器（gcc 或 clang）
* 平台特定的依赖项：
  * Linux：X11 开发库
  * macOS：Xcode 命令行工具
  * Windows：MinGW-w64 或 Visual Studio

## 开发

要从源代码构建：

```bash
git clone https://github.com/wangyiyang/Magic-Terminal.git
cd Magic-Terminal
go build ./cmd/fyneterm
```

运行测试：

```bash
go test ./...
```

## 许可证

Magic Terminal 基于 BSD 3-Clause 许可证发布。详细信息请查看 [LICENSE](LICENSE) 文件。

## 致谢

Magic Terminal 基于 [fyne-io/terminal](https://github.com/fyne-io/terminal) 项目开发。
我们诚挚感谢原始作者和 Fyne.io 开发团队，感谢他们为创建这个增强版终端模拟器
奠定了坚实的基础。

## 贡献

欢迎贡献！请随时提交 Pull Request。对于重大更改，请先开启 issue 讨论您想要更改的内容。

1. Fork 该仓库
2. 创建您的功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交您的更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启一个 Pull Request

## 支持

* 📚 [文档](docs/CI-CD.md)
* 🐛 [问题跟踪](https://github.com/wangyiyang/Magic-Terminal/issues)
* 💬 [讨论区](https://github.com/wangyiyang/Magic-Terminal/discussions)

---

© 2025 Wang Yiyang (Magic Terminal)。基于 fyne-io/terminal © 2021 Fyne.io developers。
