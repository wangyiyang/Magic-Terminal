# Magic Terminal 用户手册

## 🎯 欢迎使用 Magic Terminal

Magic Terminal 是一个现代化的跨平台终端模拟器，基于 Fyne 工具包构建，为您提供流畅、美观且功能丰富的终端体验。

## 📥 安装指南

### Windows 安装

#### 方法一：下载安装包
1. 访问 [GitHub Releases](https://github.com/wangyiyang/Magic-Terminal/releases)
2. 下载最新的 `Magic-Terminal-windows.exe`
3. 双击运行安装程序
4. 按照向导完成安装

#### 方法二：使用 Chocolatey
```powershell
# 安装 Chocolatey (如果未安装)
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# 安装 Magic Terminal
choco install magic-terminal
```

#### 方法三：使用 Winget
```powershell
winget install MagicTerminal.MagicTerminal
```

### macOS 安装

#### 方法一：下载 App
1. 下载 `Magic-Terminal-darwin.tar.gz`
2. 解压缩获得 `Magic Terminal.app`
3. 拖拽到 `/Applications` 文件夹
4. 首次运行时可能需要在系统偏好设置中允许运行

#### 方法二：使用 Homebrew
```bash
# 安装 Homebrew (如果未安装)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 安装 Magic Terminal
brew install --cask magic-terminal
```

### Linux 安装

#### 方法一：AppImage (推荐)
```bash
# 下载 AppImage
wget https://github.com/wangyiyang/Magic-Terminal/releases/latest/download/Magic-Terminal-linux.AppImage

# 添加执行权限
chmod +x Magic-Terminal-linux.AppImage

# 运行
./Magic-Terminal-linux.AppImage
```

#### 方法二：使用包管理器

**Ubuntu/Debian:**
```bash
# 添加仓库
curl -fsSL https://apt.magic-terminal.com/gpg | sudo apt-key add -
echo "deb https://apt.magic-terminal.com stable main" | sudo tee /etc/apt/sources.list.d/magic-terminal.list

# 安装
sudo apt update
sudo apt install magic-terminal
```

**Fedora/CentOS:**
```bash
# 添加仓库
sudo dnf config-manager --add-repo https://rpm.magic-terminal.com/magic-terminal.repo

# 安装
sudo dnf install magic-terminal
```

**Arch Linux:**
```bash
# 使用 AUR
yay -S magic-terminal
# 或
paru -S magic-terminal
```

#### 方法三：从源码编译
```bash
# 安装依赖
sudo apt install golang-go libgl1-mesa-dev xorg-dev

# 克隆代码
git clone https://github.com/wangyiyang/Magic-Terminal.git
cd Magic-Terminal

# 编译安装
make build
sudo make install
```

## 🚀 快速开始

### 首次启动

1. **启动应用程序**
   - Windows: 从开始菜单搜索 "Magic Terminal"
   - macOS: 从应用程序文件夹或启动台启动
   - Linux: 从应用菜单或命令行运行 `magic-terminal`

2. **初始设置**
   应用首次启动时会显示欢迎界面，您可以：
   - 选择默认 Shell（bash、zsh、fish 等）
   - 配置外观主题
   - 设置字体和大小
   - 导入现有配置

3. **创建第一个会话**
   启动后会自动创建一个终端会话，您可以立即开始使用。

### 基本操作

#### 文本操作
```bash
# 文本选择
- 鼠标拖拽选择文本
- 双击选择单词
- 三击选择整行
- Ctrl+A 全选

# 复制粘贴
- Ctrl+C 复制选中文本
- Ctrl+V 粘贴
- Ctrl+Shift+C 强制复制
- Ctrl+Shift+V 强制粘贴

# 查找功能
- Ctrl+F 打开查找框
- Enter 查找下一个
- Shift+Enter 查找上一个
- Esc 关闭查找框
```

#### 窗口管理
```bash
# 窗口操作
- Ctrl+N 新建窗口
- Ctrl+W 关闭当前窗口
- Ctrl+Q 退出应用
- F11 全屏模式

# 字体调整
- Ctrl++ 增大字体
- Ctrl+- 减小字体
- Ctrl+0 重置字体大小

# 滚动操作
- 鼠标滚轮 滚动历史
- Shift+PageUp 向上翻页
- Shift+PageDown 向下翻页
- Ctrl+Home 跳到开头
- Ctrl+End 跳到末尾
```

## ⚙️ 配置设置

### 访问设置

#### 图形界面配置
1. 点击菜单栏 **"设置"** → **"偏好设置"**
2. 或使用快捷键 `Ctrl+,`（Windows/Linux）或 `Cmd+,`（macOS）

#### 配置文件位置
```bash
# Windows
%APPDATA%\Magic Terminal\config.yaml

# macOS
~/Library/Application Support/Magic Terminal/config.yaml

# Linux
~/.config/magic-terminal/config.yaml
```

### 基本设置

#### 外观设置
```yaml
# config.yaml - 外观配置
appearance:
  theme: "dark"              # 主题: dark, light, auto
  font_family: "Fira Code"   # 字体族
  font_size: 14              # 字体大小
  line_height: 1.2           # 行高
  cursor_style: "block"      # 光标样式: block, underline, bar
  cursor_blink: true         # 光标闪烁
  
colors:
  foreground: "#ffffff"      # 前景色
  background: "#1e1e1e"      # 背景色
  cursor: "#ffff00"          # 光标颜色
  
  # ANSI 颜色配置
  black: "#000000"
  red: "#ff0000"
  green: "#00ff00"
  yellow: "#ffff00"
  blue: "#0000ff"
  magenta: "#ff00ff"
  cyan: "#00ffff"
  white: "#ffffff"
  
  # 明亮色
  bright_black: "#555555"
  bright_red: "#ff5555"
  bright_green: "#55ff55"
  bright_yellow: "#ffff55"
  bright_blue: "#5555ff"
  bright_magenta: "#ff55ff"
  bright_cyan: "#55ffff"
  bright_white: "#ffffff"
```

#### 行为设置
```yaml
# config.yaml - 行为配置
behavior:
  shell: "/bin/bash"         # 默认 Shell
  working_directory: "~"     # 启动目录
  close_on_exit: true        # 进程结束时关闭
  confirm_quit: true         # 退出时确认
  scroll_back_lines: 10000   # 历史行数
  copy_on_select: false      # 选择时自动复制
  paste_on_right_click: true # 右键粘贴
  
startup:
  restore_sessions: true     # 恢复上次会话
  startup_command: ""        # 启动命令
  window_size: "80x24"      # 窗口大小
  window_position: "center"  # 窗口位置
```

### 高级设置

#### 快捷键自定义
```yaml
# config.yaml - 快捷键配置
keybindings:
  copy: "Ctrl+C"
  paste: "Ctrl+V"
  find: "Ctrl+F"
  new_window: "Ctrl+N"
  close_window: "Ctrl+W"
  quit: "Ctrl+Q"
  fullscreen: "F11"
  zoom_in: "Ctrl+Plus"
  zoom_out: "Ctrl+Minus"
  zoom_reset: "Ctrl+0"
  
  # 自定义快捷键
  custom_commands:
    "Ctrl+Alt+L": "clear"
    "Ctrl+Alt+T": "htop"
    "F12": "neofetch"
```

#### 插件配置
```yaml
# config.yaml - 插件配置
plugins:
  enabled: true
  
  # 语法高亮插件
  syntax_highlighting:
    enabled: true
    theme: "github"
    
  # 自动完成插件
  auto_completion:
    enabled: true
    history_based: true
    
  # 通知插件
  notifications:
    enabled: true
    long_running_command: 30  # 秒
    
  # Git 集成
  git_integration:
    enabled: true
    show_branch: true
    show_status: true
```

## 🎨 主题和自定义

### 内置主题

Magic Terminal 提供多种内置主题：

#### 深色主题
- **One Dark**: 流行的深色主题
- **Dracula**: 优雅的紫色调主题
- **Monokai**: 经典的深色主题
- **Solarized Dark**: 护眼的深色主题

#### 浅色主题
- **One Light**: 简洁的浅色主题
- **GitHub Light**: GitHub 风格浅色主题
- **Solarized Light**: 护眼的浅色主题

#### 切换主题
```bash
# 通过命令行切换主题
magic-terminal --theme="one-dark"

# 或在配置文件中设置
# appearance.theme: "one-dark"
```

### 自定义主题

#### 创建自定义主题
```yaml
# themes/my-theme.yaml
name: "My Custom Theme"
author: "Your Name"
description: "My personalized terminal theme"

colors:
  # 基础颜色
  foreground: "#e6e6e6"
  background: "#1a1a1a"
  cursor: "#ff6b6b"
  
  # 选择高亮
  selection_background: "#404040"
  selection_foreground: "#ffffff"
  
  # ANSI 标准颜色
  ansi:
    black: "#2e3440"
    red: "#bf616a"
    green: "#a3be8c"
    yellow: "#ebcb8b"
    blue: "#81a1c1"
    magenta: "#b48ead"
    cyan: "#88c0d0"
    white: "#e5e9f0"
    
  # 明亮色变体
  bright:
    black: "#4c566a"
    red: "#d06f79"
    green: "#b1c89b"
    yellow: "#f0d399"
    blue: "#8faac7"
    magenta: "#c296b6"
    cyan: "#93c5d1"
    white: "#eceff4"
    
  # 扩展颜色 (256色模式)
  extended:
    color16: "#5e81ac"
    color17: "#88c0d0"
    # ... 更多颜色定义

# UI 元素样式
ui:
  tab_bar:
    background: "#2e3440"
    active_tab: "#5e81ac"
    inactive_tab: "#4c566a"
    
  status_bar:
    background: "#3b4252"
    foreground: "#d8dee9"
    
  scrollbar:
    track: "#3b4252"
    thumb: "#5e81ac"
```

#### 应用自定义主题
```bash
# 将主题文件复制到主题目录
cp my-theme.yaml ~/.config/magic-terminal/themes/

# 在配置中启用
# appearance.theme: "my-theme"
```

### 字体配置

#### 推荐字体
```yaml
# 编程友好的等宽字体推荐
fonts:
  recommended:
    - "Fira Code"          # 支持连字符
    - "JetBrains Mono"     # JetBrains 出品
    - "Source Code Pro"    # Adobe 开源字体
    - "Cascadia Code"      # Microsoft 终端字体
    - "Hack"               # 专为源码设计
    - "Inconsolata"        # 经典编程字体
    - "Ubuntu Mono"        # Ubuntu 系统字体
    - "DejaVu Sans Mono"   # 跨平台兼容
    
  # 字体配置
  configuration:
    family: "Fira Code"
    size: 14
    weight: "normal"       # normal, bold, light
    style: "normal"        # normal, italic
    ligatures: true        # 连字符支持
    anti_aliasing: true    # 抗锯齿
```

#### 字体安装
```bash
# Linux 安装字体
sudo apt install fonts-firacode

# macOS 使用 Homebrew 安装
brew tap homebrew/cask-fonts
brew install --cask font-fira-code

# Windows 从 GitHub 下载安装
# https://github.com/tonsky/FiraCode/releases
```

## 📋 功能特性

### 标签页管理

#### 标签页操作
```bash
# 标签页快捷键
- Ctrl+T 新建标签页
- Ctrl+Shift+T 恢复关闭的标签页
- Ctrl+W 关闭当前标签页
- Ctrl+Tab 切换到下一个标签页
- Ctrl+Shift+Tab 切换到上一个标签页
- Ctrl+PageUp 向左切换标签页
- Ctrl+PageDown 向右切换标签页
- Ctrl+数字键 切换到指定标签页
```

#### 标签页配置
```yaml
# config.yaml - 标签页配置
tabs:
  show_tab_bar: true         # 显示标签栏
  tab_position: "top"        # 标签位置: top, bottom
  close_button: true         # 显示关闭按钮
  new_tab_button: true       # 显示新建按钮
  tab_width: "auto"          # 标签宽度: auto, fixed
  show_tab_numbers: true     # 显示标签编号
  tab_title_template: "{title} - {cwd}"  # 标签标题模板
  
  # 标签行为
  close_last_tab_quits: true   # 关闭最后标签时退出
  new_tab_directory: "current" # 新标签目录: current, home
  restore_tabs: true           # 启动时恢复标签
```

### 分屏功能

#### 分屏操作
```bash
# 分屏快捷键
- Ctrl+Shift+H 水平分屏
- Ctrl+Shift+V 垂直分屏
- Ctrl+Shift+W 关闭当前分屏
- Ctrl+Shift+方向键 切换分屏焦点
- Ctrl+Alt+方向键 调整分屏大小
```

#### 分屏配置
```yaml
# config.yaml - 分屏配置
split_panes:
  enabled: true
  default_orientation: "horizontal"  # horizontal, vertical
  resize_step: 5                     # 调整步长(%)
  min_pane_size: 10                  # 最小面板大小(%)
  show_borders: true                 # 显示边框
  active_border_color: "#5e81ac"     # 活动边框颜色
  inactive_border_color: "#4c566a"   # 非活动边框颜色
```

### 搜索功能

#### 搜索操作
```bash
# 搜索快捷键
- Ctrl+F 打开搜索
- Enter 查找下一个
- Shift+Enter 查找上一个
- Ctrl+G 查找下一个
- Ctrl+Shift+G 查找上一个
- Esc 关闭搜索

# 搜索选项
- 大小写敏感
- 正则表达式
- 全词匹配
- 向上/向下搜索
```

#### 搜索配置
```yaml
# config.yaml - 搜索配置
search:
  highlight_matches: true      # 高亮匹配项
  incremental_search: true     # 增量搜索
  wrap_around: true            # 循环搜索
  case_sensitive: false        # 大小写敏感
  regex_enabled: true          # 正则表达式支持
  max_history: 100             # 搜索历史数量
  
  # 搜索外观
  match_color: "#ffff00"       # 匹配高亮颜色
  current_match_color: "#ff6b6b"  # 当前匹配颜色
```

### 历史记录

#### 历史管理
```bash
# 历史记录快捷键
- 上/下箭头 浏览命令历史
- Ctrl+R 反向搜索历史
- Ctrl+S 正向搜索历史
- Page Up/Down 翻页浏览输出历史

# 历史记录管理
- Ctrl+L 清屏(保留历史)
- Ctrl+Shift+L 清除历史记录
```

#### 历史配置
```yaml
# config.yaml - 历史配置
history:
  save_history: true           # 保存历史
  history_file: "~/.magic_terminal_history"
  max_history_lines: 10000     # 最大历史行数
  max_output_lines: 100000     # 最大输出行数
  duplicate_handling: "ignore" # 重复处理: ignore, append
  
  # 搜索历史
  search_history: true
  search_highlight: true
  search_case_sensitive: false
```

## 🔧 高级功能

### 配置文件管理

#### 配置文件结构
```
~/.config/magic-terminal/
├── config.yaml          # 主配置文件
├── themes/              # 自定义主题
│   ├── my-theme.yaml
│   └── custom.yaml
├── keybindings/         # 自定义快捷键
│   └── custom.yaml
├── plugins/             # 插件配置
│   ├── syntax.yaml
│   └── completion.yaml
├── sessions/            # 会话保存
│   └── default.session
└── logs/               # 日志文件
    └── magic-terminal.log
```

#### 配置备份和恢复
```bash
# 备份配置
magic-terminal --export-config backup.yaml

# 恢复配置
magic-terminal --import-config backup.yaml

# 重置为默认配置
magic-terminal --reset-config
```

### 命令行接口

#### 命令行参数
```bash
# 基本用法
magic-terminal [选项] [命令]

# 选项说明
-c, --command <CMD>        # 执行指定命令
-d, --directory <DIR>      # 设置工作目录
-t, --title <TITLE>        # 设置窗口标题
-e, --execute <CMD>        # 执行命令并保持窗口
-x, --exit                 # 命令执行后退出
--theme <THEME>           # 使用指定主题
--config <FILE>           # 使用指定配置文件
--no-config               # 不加载配置文件
--fullscreen              # 全屏启动
--maximize                # 最大化启动
--geometry <WxH>          # 设置窗口大小
--position <X,Y>          # 设置窗口位置
-v, --version             # 显示版本信息
-h, --help                # 显示帮助信息

# 使用示例
magic-terminal -c "ssh user@server"
magic-terminal -d ~/projects -t "Development"
magic-terminal --theme=solarized-dark --fullscreen
```

#### 配置管理命令
```bash
# 配置相关命令
magic-terminal config list                    # 列出配置项
magic-terminal config get appearance.theme    # 获取配置值
magic-terminal config set appearance.theme dark  # 设置配置值
magic-terminal config reset                   # 重置配置
magic-terminal config validate                # 验证配置

# 主题管理
magic-terminal theme list                     # 列出可用主题
magic-terminal theme install <theme-file>     # 安装主题
magic-terminal theme remove <theme-name>      # 删除主题
magic-terminal theme export <theme-name>      # 导出主题

# 会话管理
magic-terminal session list                   # 列出保存的会话
magic-terminal session save <name>            # 保存当前会话
magic-terminal session load <name>            # 加载会话
magic-terminal session delete <name>          # 删除会话
```

### Shell 集成

#### Bash 集成
```bash
# 添加到 ~/.bashrc
if [[ "$TERM" == "magic-terminal"* ]]; then
    # Magic Terminal 特定配置
    export MAGIC_TERMINAL=1
    
    # 设置提示符
    PS1='\[\e[1;32m\]\u@\h\[\e[0m\]:\[\e[1;34m\]\w\[\e[0m\]\$ '
    
    # 别名
    alias ll='ls -la --color=auto'
    alias grep='grep --color=auto'
    
    # 函数
    magic_title() {
        echo -ne "\033]0;$1\007"
    }
fi
```

#### Zsh 集成
```zsh
# 添加到 ~/.zshrc
if [[ "$TERM" == "magic-terminal"* ]]; then
    # 启用颜色支持
    autoload -U colors && colors
    
    # Oh My Zsh 兼容
    if [[ -n "$ZSH" ]]; then
        # Magic Terminal 主题
        ZSH_THEME="magic-terminal"
    fi
    
    # 自定义提示符
    PROMPT='%{$fg[green]%}%n@%m%{$reset_color%}:%{$fg[blue]%}%~%{$reset_color%}%# '
    
    # 插件兼容性
    plugins=(git magic-terminal-integration)
fi
```

#### Fish 集成
```fish
# 添加到 ~/.config/fish/config.fish
if string match -q "magic-terminal*" $TERM
    # 设置变量
    set -gx MAGIC_TERMINAL 1
    
    # 自定义提示符
    function fish_prompt
        set_color green
        echo -n (whoami)@(hostname)
        set_color normal
        echo -n ':'
        set_color blue
        echo -n (prompt_pwd)
        set_color normal
        echo '$ '
    end
    
    # 标题函数
    function magic_title
        echo -ne "\033]0;$argv[1]\007"
    end
end
```

## 🐛 故障排除

### 常见问题

#### 启动问题

**问题**: 应用程序无法启动
```bash
# 解决方案
1. 检查系统依赖
   - Linux: sudo apt install libgl1-mesa-glx libxi6 libxrender1
   - macOS: 确保系统版本 >= 10.14
   - Windows: 安装 Visual C++ Redistributable

2. 检查权限
   chmod +x /path/to/magic-terminal

3. 重置配置
   magic-terminal --reset-config

4. 查看日志
   magic-terminal --debug --log-level debug
```

**问题**: 字体显示异常
```bash
# 解决方案
1. 安装建议字体
   - sudo apt install fonts-firacode fonts-dejavu

2. 重建字体缓存
   - fc-cache -fv

3. 在配置中指定字体路径
   appearance:
     font_family: "/usr/share/fonts/truetype/firacode/FiraCode-Regular.ttf"
```

#### 性能问题

**问题**: 输出大量文本时卡顿
```yaml
# 优化配置
performance:
  double_buffering: true     # 双缓冲
  hardware_acceleration: true # 硬件加速
  max_fps: 60               # 限制帧率
  lazy_rendering: true      # 延迟渲染
  
history:
  max_output_lines: 50000   # 减少历史行数
  dynamic_scrollback: true  # 动态滚动缓冲
```

**问题**: 内存使用过高
```yaml
# 内存优化
memory:
  gc_interval: 30           # GC 间隔(秒)
  max_memory_mb: 512        # 最大内存限制
  memory_pressure_threshold: 80  # 内存压力阈值(%)
  
history:
  max_output_lines: 10000   # 限制输出历史
  compress_history: true    # 压缩历史数据
```

#### 兼容性问题

**问题**: 某些程序显示异常
```bash
# 解决方案
1. 设置正确的 TERM 变量
   export TERM=xterm-256color

2. 启用兼容模式
   magic-terminal --compatibility-mode

3. 调整终端配置
   terminal:
     term_type: "xterm-256color"
     mouse_reporting: true
     application_cursor_keys: true
```

**问题**: SSH 连接问题
```bash
# 解决方案
1. 配置 SSH 客户端
   # ~/.ssh/config
   Host *
     SendEnv LANG LC_*
     ForwardAgent yes

2. 设置正确的 locale
   export LANG=en_US.UTF-8
   export LC_ALL=en_US.UTF-8

3. 启用 SSH 代理转发
   ssh -A user@server
```

### 诊断工具

#### 内置诊断
```bash
# 系统信息诊断
magic-terminal --system-info

# 配置验证
magic-terminal --config-check

# 性能基准测试
magic-terminal --benchmark

# 连接测试
magic-terminal --connection-test

# 字体检测
magic-terminal --font-test
```

#### 日志调试
```bash
# 启用详细日志
magic-terminal --log-level debug --log-file debug.log

# 实时查看日志
tail -f ~/.config/magic-terminal/logs/magic-terminal.log

# 日志分析
magic-terminal --analyze-logs debug.log
```

#### 环境检查
```bash
#!/bin/bash
# env-check.sh - 环境检查脚本

echo "🔍 Magic Terminal 环境检查"

# 检查系统信息
echo "系统信息:"
uname -a
echo "发行版: $(lsb_release -d 2>/dev/null || echo 'Unknown')"

# 检查依赖
echo -e "\n依赖检查:"
deps=("libgl1-mesa-glx" "libxi6" "libxrender1" "fontconfig")
for dep in "${deps[@]}"; do
    if dpkg -l | grep -q "$dep"; then
        echo "✅ $dep"
    else
        echo "❌ $dep (缺失)"
    fi
done

# 检查字体
echo -e "\n字体检查:"
fonts=("Fira Code" "DejaVu Sans Mono" "Liberation Mono")
for font in "${fonts[@]}"; do
    if fc-list | grep -q "$font"; then
        echo "✅ $font"
    else
        echo "❌ $font (未安装)"
    fi
done

# 检查终端支持
echo -e "\n终端功能:"
echo "颜色支持: $(tput colors)色"
echo "Unicode 支持: $(locale charmap)"
echo "鼠标支持: $(tput kmous 2>/dev/null && echo '是' || echo '否')"

echo -e "\n✅ 环境检查完成"
```

## 📞 获取帮助

### 官方资源

#### 文档和指南
- **项目主页**: https://github.com/wangyiyang/Magic-Terminal
- **用户文档**: https://magic-terminal.readthedocs.io
- **API 文档**: https://pkg.go.dev/github.com/wangyiyang/Magic-Terminal
- **常见问题**: https://github.com/wangyiyang/Magic-Terminal/wiki/FAQ

#### 社区支持
- **GitHub Issues**: https://github.com/wangyiyang/Magic-Terminal/issues
- **讨论区**: https://github.com/wangyiyang/Magic-Terminal/discussions
- **Reddit**: r/MagicTerminal
- **Discord**: https://discord.gg/magic-terminal

### 报告问题

#### Bug 报告模板
```markdown
## Bug 报告

### 环境信息
- 操作系统: [Windows 11 / macOS 13.0 / Ubuntu 22.04]
- Magic Terminal 版本: [v1.3.0]
- 安装方式: [GitHub Release / 包管理器 / 源码编译]

### 问题描述
[清楚描述遇到的问题]

### 重现步骤
1. 启动 Magic Terminal
2. 执行命令 `xxx`
3. 观察到问题

### 期望行为
[描述期望的正确行为]

### 实际行为
[描述实际发生的错误行为]

### 附加信息
- 错误日志: [粘贴相关日志]
- 配置文件: [如果相关，提供配置]
- 截图: [如果有助于说明问题]

### 诊断信息
```bash
magic-terminal --system-info
magic-terminal --config-check
```
```

#### 功能请求模板
```markdown
## 功能请求

### 功能描述
[清楚描述希望添加的功能]

### 使用场景
[描述什么情况下需要这个功能]

### 实现建议
[如果有想法，可以提供实现建议]

### 替代方案
[描述当前的替代解决方案]

### 优先级
[高/中/低]

### 愿意贡献
[是否愿意帮助实现这个功能]
```

### 贡献指南

#### 参与贡献
1. **Fork 项目** - 在 GitHub 上 fork 项目
2. **创建分支** - 为你的功能创建新分支
3. **提交代码** - 遵循代码规范提交代码
4. **创建 PR** - 创建 Pull Request
5. **代码审查** - 参与代码审查过程

#### 贡献类型
- 🐛 **Bug 修复** - 修复已知问题
- ✨ **新功能** - 添加新功能
- 📝 **文档** - 改进文档
- 🎨 **主题** - 贡献新主题
- 🌐 **翻译** - 添加语言支持
- 🧪 **测试** - 添加或改进测试

感谢您选择 Magic Terminal！如果您有任何问题或建议，请不要hesitate联系我们。
