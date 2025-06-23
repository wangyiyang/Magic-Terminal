# Magic Terminal 监控和日志系统

## 📊 概述

Magic Terminal 项目实现了全面的监控和日志系统，帮助开发者和运维人员了解应用程序的运行状态、性能指标和问题诊断。

## 🔍 监控体系

### 1. 应用程序监控

#### 性能指标监控
```go
// 性能监控示例
type PerformanceMetrics struct {
    RenderTime       time.Duration `json:"render_time"`
    MemoryUsage      int64         `json:"memory_usage"`
    CPUUsage         float64       `json:"cpu_usage"`
    TerminalFPS      int           `json:"terminal_fps"`
    InputLatency     time.Duration `json:"input_latency"`
    OutputThroughput int64         `json:"output_throughput"`
}

// 监控数据收集
func (t *Terminal) CollectMetrics() *PerformanceMetrics {
    return &PerformanceMetrics{
        RenderTime:       t.lastRenderTime,
        MemoryUsage:      t.getMemoryUsage(),
        CPUUsage:         t.getCPUUsage(),
        TerminalFPS:      t.calculateFPS(),
        InputLatency:     t.getInputLatency(),
        OutputThroughput: t.getOutputThroughput(),
    }
}
```

#### 健康检查端点
```go
// 健康检查接口
func (t *Terminal) HealthCheck() map[string]interface{} {
    return map[string]interface{}{
        "status":           "healthy",
        "uptime":          time.Since(t.startTime),
        "active_sessions": t.getActiveSessionCount(),
        "memory_usage":    t.getMemoryUsage(),
        "last_activity":   t.lastActivity,
    }
}
```

### 2. 系统资源监控

#### 内存监控
```go
// 内存使用监控
func (t *Terminal) monitorMemory() {
    ticker := time.NewTicker(30 * time.Second)
    defer ticker.Stop()
    
    for {
        select {
        case <-ticker.C:
            var m runtime.MemStats
            runtime.ReadMemStats(&m)
            
            metrics := MemoryMetrics{
                Alloc:      m.Alloc,
                TotalAlloc: m.TotalAlloc,
                Sys:        m.Sys,
                NumGC:      m.NumGC,
                Timestamp:  time.Now(),
            }
            
            t.logMemoryMetrics(metrics)
            
            // 内存警告阈值
            if m.Alloc > 100*1024*1024 { // 100MB
                t.logger.Warn("High memory usage detected", 
                    "alloc", m.Alloc,
                    "sys", m.Sys)
            }
        case <-t.stopChan:
            return
        }
    }
}
```

#### CPU 监控
```go
// CPU 使用率监控
func (t *Terminal) monitorCPU() {
    ticker := time.NewTicker(1 * time.Minute)
    defer ticker.Stop()
    
    for {
        select {
        case <-ticker.C:
            cpuUsage := t.getCPUUsage()
            
            if cpuUsage > 80.0 {
                t.logger.Warn("High CPU usage detected", 
                    "usage", cpuUsage)
            }
            
            t.metrics.RecordCPUUsage(cpuUsage)
        case <-t.stopChan:
            return
        }
    }
}
```

### 3. 用户行为监控

#### 交互追踪
```go
// 用户交互事件追踪
type UserInteraction struct {
    Type      string    `json:"type"`
    Timestamp time.Time `json:"timestamp"`
    Details   map[string]interface{} `json:"details"`
}

func (t *Terminal) trackUserInteraction(eventType string, details map[string]interface{}) {
    interaction := UserInteraction{
        Type:      eventType,
        Timestamp: time.Now(),
        Details:   details,
    }
    
    t.logger.Info("User interaction", 
        "type", eventType,
        "details", details)
        
    t.analytics.RecordInteraction(interaction)
}
```

## 📝 日志系统

### 1. 日志级别和格式

#### 日志级别定义
```go
const (
    LogLevelDebug = "DEBUG"
    LogLevelInfo  = "INFO"
    LogLevelWarn  = "WARN"
    LogLevelError = "ERROR"
    LogLevelFatal = "FATAL"
)
```

#### 日志格式
```json
{
    "timestamp": "2025-06-23T10:30:00Z",
    "level": "INFO",
    "component": "terminal",
    "message": "Terminal session started",
    "session_id": "sess_123456",
    "user_id": "user_001",
    "metadata": {
        "terminal_size": "80x24",
        "shell": "/bin/bash",
        "platform": "linux"
    }
}
```

### 2. 日志组件

#### 结构化日志记录器
```go
// 日志记录器接口
type Logger interface {
    Debug(msg string, fields ...interface{})
    Info(msg string, fields ...interface{})
    Warn(msg string, fields ...interface{})
    Error(msg string, fields ...interface{})
    Fatal(msg string, fields ...interface{})
}

// 结构化日志实现
type StructuredLogger struct {
    component string
    level     string
    output    io.Writer
}

func (l *StructuredLogger) Info(msg string, fields ...interface{}) {
    entry := LogEntry{
        Timestamp: time.Now().UTC(),
        Level:     "INFO",
        Component: l.component,
        Message:   msg,
        Fields:    fieldsToMap(fields...),
    }
    
    l.writeLog(entry)
}
```

#### 日志分类

**应用程序日志**
```go
// 应用启动/关闭
logger.Info("Application starting", 
    "version", version,
    "build", buildDate,
    "platform", runtime.GOOS)

// 配置变更
logger.Info("Configuration updated",
    "config_key", key,
    "old_value", oldValue,
    "new_value", newValue)

// 错误处理
logger.Error("Failed to render frame",
    "error", err.Error(),
    "frame_id", frameID,
    "retry_count", retryCount)
```

**终端操作日志**
```go
// 终端会话管理
logger.Info("Terminal session created",
    "session_id", sessionID,
    "shell", shell,
    "working_dir", workingDir)

// 命令执行
logger.Debug("Command execution",
    "command", command,
    "exit_code", exitCode,
    "duration", duration)

// 输入输出事件
logger.Debug("Terminal output",
    "session_id", sessionID,
    "bytes_written", bytesWritten,
    "content_type", contentType)
```

**性能日志**
```go
// 渲染性能
logger.Debug("Frame rendered",
    "frame_id", frameID,
    "render_time", renderTime,
    "cell_count", cellCount)

// 内存使用
logger.Info("Memory usage report",
    "allocated", allocated,
    "heap_size", heapSize,
    "gc_count", gcCount)
```

### 3. 日志输出配置

#### 文件输出
```go
// 日志文件配置
type FileLogConfig struct {
    Path       string `yaml:"path"`
    MaxSize    int    `yaml:"max_size"`    // MB
    MaxBackups int    `yaml:"max_backups"`
    MaxAge     int    `yaml:"max_age"`     // days
    Compress   bool   `yaml:"compress"`
}

// 日志轮转
func setupFileLogging(config FileLogConfig) *lumberjack.Logger {
    return &lumberjack.Logger{
        Filename:   config.Path,
        MaxSize:    config.MaxSize,
        MaxBackups: config.MaxBackups,
        MaxAge:     config.MaxAge,
        Compress:   config.Compress,
    }
}
```

#### 控制台输出
```go
// 开发模式：彩色控制台输出
func setupConsoleLogging(isDev bool) io.Writer {
    if isDev {
        return &coloredConsoleWriter{
            colors: map[string]string{
                "DEBUG": "\033[36m", // Cyan
                "INFO":  "\033[32m", // Green
                "WARN":  "\033[33m", // Yellow
                "ERROR": "\033[31m", // Red
                "FATAL": "\033[35m", // Magenta
            },
        }
    }
    return os.Stdout
}
```

## 📈 监控指标

### 1. 核心性能指标

#### 渲染性能
- **帧率 (FPS)**: 终端渲染的每秒帧数
- **渲染延迟**: 从数据到显示的时间
- **重绘次数**: 每秒的重绘操作数量

#### 内存指标
- **堆内存使用**: 当前堆内存占用量
- **内存分配速率**: 每秒内存分配量
- **垃圾回收频率**: GC 触发频率和耗时

#### 网络和 I/O
- **输入处理延迟**: 键盘输入到处理的延迟
- **输出吞吐量**: 每秒输出的字符数
- **缓冲区使用率**: 输入输出缓冲区的使用情况

### 2. 业务指标

#### 用户体验
- **启动时间**: 应用程序启动到可用的时间
- **响应时间**: 用户操作到反馈的时间
- **错误率**: 操作失败的比例

#### 会话管理
- **活跃会话数**: 当前活跃的终端会话数量
- **会话持续时间**: 平均会话持续时间
- **会话创建/销毁速率**: 会话的创建和销毁频率

## 🔧 监控工具集成

### 1. Prometheus 集成

#### 指标暴露
```go
// Prometheus 指标定义
var (
    renderDuration = prometheus.NewHistogramVec(
        prometheus.HistogramOpts{
            Name: "terminal_render_duration_seconds",
            Help: "Duration of terminal rendering operations",
        },
        []string{"operation"},
    )
    
    memoryUsage = prometheus.NewGaugeVec(
        prometheus.GaugeOpts{
            Name: "terminal_memory_usage_bytes",
            Help: "Current memory usage of the terminal",
        },
        []string{"type"},
    )
    
    activeSessions = prometheus.NewGauge(
        prometheus.GaugeOpts{
            Name: "terminal_active_sessions",
            Help: "Number of active terminal sessions",
        },
    )
)

// 指标收集
func (t *Terminal) recordMetrics() {
    renderDuration.WithLabelValues("frame").Observe(t.lastRenderTime.Seconds())
    memoryUsage.WithLabelValues("heap").Set(float64(t.getHeapUsage()))
    activeSessions.Set(float64(t.getActiveSessionCount()))
}
```

### 2. 日志聚合

#### ELK Stack 集成
```yaml
# Filebeat 配置
filebeat.inputs:
- type: log
  enabled: true
  paths:
    - /var/log/magic-terminal/*.log
  fields:
    application: magic-terminal
    environment: production
  json.keys_under_root: true
  json.add_error_key: true

output.elasticsearch:
  hosts: ["elasticsearch:9200"]
  index: "magic-terminal-%{+yyyy.MM.dd}"
```

#### Grafana 仪表板
```json
{
  "dashboard": {
    "title": "Magic Terminal Monitoring",
    "panels": [
      {
        "title": "Render Performance",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(terminal_render_duration_seconds_sum[5m])",
            "legendFormat": "Render Time"
          }
        ]
      },
      {
        "title": "Memory Usage",
        "type": "singlestat",
        "targets": [
          {
            "expr": "terminal_memory_usage_bytes",
            "legendFormat": "Memory"
          }
        ]
      }
    ]
  }
}
```

## 🚨 告警和通知

### 1. 告警规则

#### 性能告警
```yaml
# Prometheus 告警规则
groups:
- name: magic-terminal
  rules:
  - alert: HighMemoryUsage
    expr: terminal_memory_usage_bytes > 100000000
    for: 5m
    labels:
      severity: warning
    annotations:
      summary: "Magic Terminal high memory usage"
      description: "Memory usage is above 100MB for 5 minutes"
  
  - alert: LowFrameRate
    expr: rate(terminal_render_duration_seconds_count[1m]) < 30
    for: 2m
    labels:
      severity: critical
    annotations:
      summary: "Magic Terminal low frame rate"
      description: "Frame rate is below 30 FPS"
```

### 2. 通知渠道

#### Slack 集成
```go
// Slack 通知
func (a *AlertManager) sendSlackNotification(alert Alert) {
    webhook := &slack.WebhookMessage{
        Text: fmt.Sprintf("🚨 Alert: %s", alert.Summary),
        Attachments: []slack.Attachment{
            {
                Color: alert.Severity.Color(),
                Fields: []slack.AttachmentField{
                    {
                        Title: "Description",
                        Value: alert.Description,
                        Short: false,
                    },
                    {
                        Title: "Severity",
                        Value: string(alert.Severity),
                        Short: true,
                    },
                },
            },
        },
    }
    
    slack.PostWebhook(a.slackWebhookURL, webhook)
}
```

## 📊 数据分析

### 1. 使用统计

#### 功能使用分析
```sql
-- 功能使用频率分析
SELECT 
    event_type,
    COUNT(*) as usage_count,
    AVG(session_duration) as avg_duration
FROM user_interactions 
WHERE timestamp >= NOW() - INTERVAL 30 DAY
GROUP BY event_type
ORDER BY usage_count DESC;
```

#### 性能趋势分析
```sql
-- 性能趋势分析
SELECT 
    DATE(timestamp) as date,
    AVG(render_time) as avg_render_time,
    AVG(memory_usage) as avg_memory_usage,
    AVG(cpu_usage) as avg_cpu_usage
FROM performance_metrics
WHERE timestamp >= NOW() - INTERVAL 7 DAY
GROUP BY DATE(timestamp)
ORDER BY date;
```

### 2. 错误分析

#### 错误分类统计
```go
// 错误统计
type ErrorStats struct {
    ErrorType    string    `json:"error_type"`
    Count        int       `json:"count"`
    LastOccurred time.Time `json:"last_occurred"`
    Samples      []string  `json:"samples"`
}

func (a *Analytics) getErrorStats(timeRange time.Duration) []ErrorStats {
    // 从日志中分析错误模式
    return a.analyzeErrors(timeRange)
}
```

## 🛠️ 故障排除

### 1. 日志分析工具

#### 日志查询脚本
```bash
#!/bin/bash
# logs-query.sh - 日志查询工具

function query_errors() {
    local timeframe=${1:-"1h"}
    echo "Querying errors in the last $timeframe..."
    
    journalctl -u magic-terminal \
        --since "$timeframe ago" \
        --grep "ERROR\|FATAL" \
        --output json | \
    jq -r '.MESSAGE' | \
    sort | uniq -c | sort -nr
}

function performance_summary() {
    local logfile=${1:-"/var/log/magic-terminal/app.log"}
    echo "Performance summary from $logfile..."
    
    grep "render_time\|memory_usage" "$logfile" | \
    tail -100 | \
    jq -r '[.render_time, .memory_usage] | @csv'
}
```

### 2. 性能分析

#### CPU 性能分析
```bash
# pprof 性能分析
go tool pprof http://localhost:6060/debug/pprof/profile?seconds=30

# 内存分析
go tool pprof http://localhost:6060/debug/pprof/heap

# Goroutine 分析
go tool pprof http://localhost:6060/debug/pprof/goroutine
```

## 📚 最佳实践

### 1. 日志记录最佳实践

- **结构化日志**: 使用 JSON 格式便于解析
- **上下文信息**: 包含足够的上下文信息便于故障排除
- **敏感信息**: 避免记录密码、令牌等敏感信息
- **适当级别**: 根据重要性选择合适的日志级别
- **性能考虑**: 避免过度日志记录影响性能

### 2. 监控最佳实践

- **关键指标**: 专注于最重要的业务和技术指标
- **基线建立**: 建立性能基线便于异常检测
- **渐进式监控**: 从基础监控开始逐步完善
- **自动化响应**: 实现自动告警和故障恢复
- **定期审查**: 定期审查和优化监控策略

### 3. 数据保留策略

- **日志轮转**: 实现自动日志轮转避免磁盘空间耗尽
- **数据归档**: 长期数据归档到低成本存储
- **隐私合规**: 遵守数据保护法规的数据保留要求
- **访问控制**: 实现适当的日志和监控数据访问控制

通过实施全面的监控和日志系统，Magic Terminal 能够提供高质量的用户体验，同时为开发和运维团队提供必要的可观测性工具。
