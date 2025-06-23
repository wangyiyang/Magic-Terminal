# Magic Terminal 故障排除指南

## 🔍 问题诊断流程

当遇到问题时，请按以下步骤进行诊断：

1. **确认问题现象** - 记录具体的错误信息或异常行为
2. **检查系统环境** - 验证系统要求和依赖
3. **收集日志信息** - 获取详细的错误日志
4. **隔离问题原因** - 确定是配置、环境还是代码问题
5. **尝试解决方案** - 按照相应的解决步骤操作
6. **验证修复效果** - 确认问题已解决

## 🚨 常见问题及解决方案

### 1. 启动问题

#### 问题：应用程序无法启动

**症状：**
- 双击应用程序无响应
- 命令行运行显示权限错误
- 显示依赖库缺失错误

**诊断步骤：**

```bash
# 检查文件权限
ls -la magic-terminal

# 检查依赖库
ldd magic-terminal  # Linux
otool -L magic-terminal  # macOS

# 查看详细错误信息
./magic-terminal -v
```

**解决方案：**

##### Linux 系统
```bash
# 1. 添加执行权限
chmod +x magic-terminal

# 2. 安装缺失的依赖
sudo apt install libgl1-mesa-glx libxi6 libxrandr2 libxcursor1  # Ubuntu/Debian
sudo yum install mesa-libGL libXi libXrandr libXcursor  # CentOS/RHEL

# 3. 检查显示环境
echo $DISPLAY  # 应该显示 :0 或类似值
xhost +local:  # 如果通过 SSH 连接
```

##### macOS 系统
```bash
# 1. 处理 Gatekeeper 警告
sudo xattr -rd com.apple.quarantine Magic\ Terminal.app

# 2. 检查系统版本
sw_vers  # 确保 macOS 10.14+

# 3. 重新安装 Xcode Command Line Tools
xcode-select --install
```

##### Windows 系统
```powershell
# 1. 以管理员身份运行
# 右键 → "以管理员身份运行"

# 2. 检查 Windows 版本
winver  # 确保 Windows 10 Build 1903+

# 3. 安装 Visual C++ Redistributable
# 下载并安装最新版本
```

#### 问题：启动时崩溃

**错误信息示例：**
```
panic: runtime error: invalid memory address or nil pointer dereference
```

**解决方案：**

```bash
# 1. 启用调试模式
export DEBUG=true
./magic-terminal

# 2. 生成崩溃报告
export GOTRACEBACK=all
./magic-terminal

# 3. 检查配置文件
rm ~/.config/magic-terminal/config.json  # 删除可能损坏的配置

# 4. 重新初始化
./magic-terminal --reset-config
```

### 2. 显示问题

#### 问题：界面显示异常

**症状：**
- 窗口空白或黑屏
- 字符显示错乱
- 颜色不正确
- 字体模糊

**诊断步骤：**

```bash
# 检查显示配置
xrandr  # Linux
system_profiler SPDisplaysDataType  # macOS

# 检查 GPU 驱动
nvidia-smi  # NVIDIA GPU
glxinfo | grep "OpenGL"  # Linux OpenGL 信息
```

**解决方案：**

##### 显示驱动问题
```bash
# Linux - 更新显示驱动
sudo apt update && sudo apt upgrade  # Ubuntu/Debian
sudo yum update  # CentOS/RHEL

# 安装 NVIDIA 驱动（如果使用 NVIDIA GPU）
sudo apt install nvidia-driver-470  # Ubuntu
```

##### 高DPI显示问题
```bash
# Linux - 设置环境变量
export QT_SCALE_FACTOR=1.0
export GDK_SCALE=1.0
export GDK_DPI_SCALE=1.0

# macOS - 重置显示设置
sudo defaults delete /Library/Preferences/com.apple.windowserver DisplayResolutionEnabled
```

##### 字体渲染问题
```go
// 在配置文件中调整字体设置
{
    "font": {
        "family": "JetBrains Mono",
        "size": 14,
        "dpi": 96
    },
    "rendering": {
        "antialiasing": true,
        "hinting": "slight"
    }
}
```

### 3. 终端功能问题

#### 问题：无法连接到 shell

**症状：**
- 终端窗口显示但无法输入
- 显示 "Connection failed" 错误
- 进程创建失败

**诊断步骤：**

```bash
# 检查默认 shell
echo $SHELL

# 检查 shell 是否存在
which bash
which zsh
which fish

# 检查进程创建权限
ps aux | grep magic-terminal
```

**解决方案：**

```bash
# 1. 设置正确的 shell 路径
export SHELL=/bin/bash  # 或其他有效的 shell

# 2. 检查权限
chmod +x /bin/bash  # 确保 shell 可执行

# 3. 在配置中指定 shell
{
    "shell": "/bin/bash",
    "shell_args": ["--login"]
}

# 4. 对于 Windows，确保 ConPTY 可用
# 需要 Windows 10 Build 1903 或更高版本
```

#### 问题：输入输出延迟

**症状：**
- 键入字符显示延迟
- 命令执行响应慢
- 滚动性能差

**解决方案：**

```json
// 优化配置
{
    "performance": {
        "buffer_size": 65536,
        "flush_interval": "5ms",
        "render_fps": 60
    },
    "terminal": {
        "scroll_back": 1000,
        "fast_scroll": true
    }
}
```

```bash
# 系统优化
# 增加进程优先级
nice -n -10 ./magic-terminal

# Linux - 调整调度器
echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
```

### 4. 内存和性能问题

#### 问题：内存使用过高

**症状：**
- 应用程序占用大量内存
- 系统变慢
- 内存泄漏警告

**诊断步骤：**

```bash
# 监控内存使用
top -p $(pgrep magic-terminal)
htop
ps aux | grep magic-terminal

# Go 内存分析
go tool pprof http://localhost:6060/debug/pprof/heap  # 如果启用了 pprof
```

**解决方案：**

```bash
# 1. 调整垃圾回收
export GOGC=50  # 降低 GC 阈值

# 2. 限制缓冲区大小
{
    "buffer_size": 16384,
    "max_cache_size": 1000,
    "scroll_back": 500
}

# 3. 定期重启（临时解决方案）
# 设置自动重启脚本
```

#### 问题：CPU 使用率高

**解决方案：**

```json
// 降低渲染频率
{
    "rendering": {
        "target_fps": 30,
        "enable_vsync": true,
        "dirty_region_only": true
    }
}
```

### 5. 字符编码问题

#### 问题：中文或特殊字符显示异常

**症状：**
- 中文字符显示为方块
- 特殊符号无法显示
- 字符宽度计算错误

**解决方案：**

```bash
# 1. 设置正确的编码环境
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US:en

# 2. 检查字体支持
fc-list | grep "CJK"  # Linux 检查中文字体

# 3. 安装完整的字体包
sudo apt install fonts-noto-cjk  # Ubuntu/Debian
```

```json
// 配置文件设置
{
    "encoding": "UTF-8",
    "font": {
        "family": "Noto Sans Mono CJK SC",
        "fallback_fonts": [
            "Consolas",
            "DejaVu Sans Mono"
        ]
    }
}
```

## 🛠️ 调试工具和技巧

### 1. 日志分析

#### 启用详细日志

```bash
# 环境变量方式
export MAGIC_TERMINAL_LOG_LEVEL=debug
export MAGIC_TERMINAL_LOG_FILE=/tmp/terminal.log
./magic-terminal

# 命令行参数方式
./magic-terminal --log-level=debug --log-file=/tmp/terminal.log
```

#### 日志配置

```json
{
    "logging": {
        "level": "debug",
        "file": "/tmp/magic-terminal.log",
        "max_size": "10MB",
        "max_backups": 5,
        "compress": true
    }
}
```

#### 分析日志

```bash
# 查看错误日志
grep "ERROR\|FATAL\|panic" /tmp/magic-terminal.log

# 查看性能相关日志
grep "performance\|slow\|timeout" /tmp/magic-terminal.log

# 实时监控日志
tail -f /tmp/magic-terminal.log
```

### 2. 性能分析

#### 启用性能分析

```bash
# 启用 pprof
export ENABLE_PPROF=true
./magic-terminal

# 访问性能分析页面
go tool pprof http://localhost:6060/debug/pprof/profile?seconds=30
```

#### CPU 使用分析

```bash
# 生成 CPU profile
curl http://localhost:6060/debug/pprof/profile?seconds=30 > cpu.prof

# 分析 profile
go tool pprof cpu.prof
(pprof) top10
(pprof) list main
(pprof) web  # 生成可视化图表
```

#### 内存分析

```bash
# 生成内存 profile
curl http://localhost:6060/debug/pprof/heap > heap.prof

# 分析内存使用
go tool pprof heap.prof
(pprof) top10
(pprof) list allocateMemory
```

### 3. 网络诊断

#### 检查网络连接

```bash
# 检查端口占用
netstat -tlnp | grep :6060
lsof -i :6060

# 检查防火墙设置
sudo ufw status  # Ubuntu
sudo firewall-cmd --list-all  # CentOS/RHEL
```

### 4. 系统资源监控

#### 监控脚本

```bash
#!/bin/bash
# scripts/monitor.sh

PID=$(pgrep magic-terminal)
if [[ -z "$PID" ]]; then
    echo "Magic Terminal 未运行"
    exit 1
fi

echo "监控 Magic Terminal (PID: $PID)"
echo "时间,CPU(%),内存(MB),文件描述符,线程数"

while kill -0 $PID 2>/dev/null; do
    CPU=$(ps -p $PID -o pcpu= | tr -d ' ')
    MEM=$(ps -p $PID -o rss= | awk '{print $1/1024}')
    FD=$(lsof -p $PID 2>/dev/null | wc -l)
    THREADS=$(ps -p $PID -o nlwp= | tr -d ' ')
    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
    
    printf "%s,%.1f,%.1f,%d,%d\n" "$TIMESTAMP" "$CPU" "$MEM" "$FD" "$THREADS"
    
    sleep 5
done
```

## 🔧 配置文件问题

### 1. 配置文件位置

| 平台 | 配置文件路径 |
|------|--------------|
| Linux | `~/.config/magic-terminal/config.json` |
| macOS | `~/Library/Application Support/magic-terminal/config.json` |
| Windows | `%APPDATA%\magic-terminal\config.json` |

### 2. 配置文件验证

```bash
# 验证 JSON 格式
python -m json.tool ~/.config/magic-terminal/config.json

# 或使用 jq
jq . ~/.config/magic-terminal/config.json
```

### 3. 重置配置

```bash
# 备份当前配置
cp ~/.config/magic-terminal/config.json ~/.config/magic-terminal/config.json.bak

# 删除配置文件（使用默认配置）
rm ~/.config/magic-terminal/config.json

# 或重置为默认配置
./magic-terminal --reset-config
```

### 4. 配置文件示例

```json
{
    "version": "1.0",
    "terminal": {
        "rows": 24,
        "columns": 80,
        "shell": "/bin/bash",
        "working_dir": "$HOME"
    },
    "appearance": {
        "theme": "dark",
        "font": {
            "family": "JetBrains Mono",
            "size": 14
        },
        "colors": {
            "foreground": "#ffffff",
            "background": "#000000"
        }
    },
    "behavior": {
        "scroll_back": 1000,
        "mouse_support": true,
        "cursor_blink": true
    },
    "performance": {
        "buffer_size": 32768,
        "render_fps": 60,
        "enable_gpu": true
    }
}
```

## 📞 获取帮助

### 1. 自助资源

- **文档**: 查看完整的项目文档
- **FAQ**: 查看常见问题解答
- **日志**: 分析应用程序日志
- **社区**: 搜索已知问题和解决方案

### 2. 报告问题

#### 问题报告模板

```markdown
## 问题描述
简要描述遇到的问题

## 复现步骤
1. 启动应用程序
2. 执行特定操作
3. 观察到的异常行为

## 期望行为
描述期望的正常行为

## 环境信息
- 操作系统: [e.g., Ubuntu 20.04]
- Magic Terminal 版本: [e.g., v1.0.0]
- Go 版本: [e.g., 1.24.0]
- 硬件信息: [e.g., Intel i7, 16GB RAM]

## 日志信息
```
粘贴相关的错误日志
```

## 配置文件
```json
粘贴相关的配置文件内容
```

## 附加信息
其他可能有用的信息
```

#### 收集诊断信息脚本

```bash
#!/bin/bash
# scripts/collect-diagnostics.sh

echo "Magic Terminal 诊断信息收集"
echo "================================"
echo

echo "系统信息:"
uname -a
echo

echo "Magic Terminal 版本:"
./magic-terminal --version
echo

echo "Go 环境:"
go version
go env
echo

echo "依赖库:"
ldd magic-terminal 2>/dev/null || otool -L magic-terminal 2>/dev/null
echo

echo "进程信息:"
ps aux | grep magic-terminal
echo

echo "配置文件:"
if [[ -f ~/.config/magic-terminal/config.json ]]; then
    cat ~/.config/magic-terminal/config.json
else
    echo "配置文件不存在"
fi
echo

echo "最近的日志:"
if [[ -f /tmp/magic-terminal.log ]]; then
    tail -50 /tmp/magic-terminal.log
else
    echo "日志文件不存在"
fi
```

### 3. 联系支持

- **GitHub Issues**: [提交新问题](https://github.com/wangyiyang/Magic-Terminal/issues/new)
- **GitHub Discussions**: [参与讨论](https://github.com/wangyiyang/Magic-Terminal/discussions)
- **Email**: 发送邮件给维护者（仅限严重问题）

### 4. 社区资源

- **Wiki**: 项目 Wiki 页面
- **论坛**: 技术论坛讨论
- **聊天群**: 实时技术交流

---

更多信息请参考：
- [开发环境配置](./development-setup.md)
- [API 文档](./api-reference.md)
- [性能优化](./performance-optimization.md)
