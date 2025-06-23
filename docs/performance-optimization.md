# Magic Terminal 性能优化指南

## 🎯 性能目标

Magic Terminal 的性能优化目标：

- **启动时间**: < 500ms (冷启动)
- **内存占用**: < 50MB (空闲状态)
- **CPU 使用**: < 1% (空闲时)
- **渲染帧率**: 60+ FPS
- **输入延迟**: < 10ms
- **大文件处理**: 支持 MB 级别输出

## 📊 性能分析工具

### Go 内置工具

#### pprof 性能分析

```go
// 启用性能分析
import (
    _ "net/http/pprof"
    "net/http"
    "log"
)

func enableProfiling() {
    go func() {
        log.Println("启动性能分析服务: http://localhost:6060/debug/pprof/")
        log.Println(http.ListenAndServe("localhost:6060", nil))
    }()
}

// 在 main 函数中调用
func main() {
    if os.Getenv("ENABLE_PPROF") == "true" {
        enableProfiling()
    }
    // ... 应用程序逻辑
}
```

#### 使用 pprof 分析

```bash
# CPU 分析
go tool pprof http://localhost:6060/debug/pprof/profile?seconds=30

# 内存分析
go tool pprof http://localhost:6060/debug/pprof/heap

# Goroutine 分析
go tool pprof http://localhost:6060/debug/pprof/goroutine

# 在 pprof 交互界面中
(pprof) top10      # 显示占用最高的10个函数
(pprof) list main  # 显示 main 函数的详细信息
(pprof) web        # 生成调用图
```

#### trace 追踪分析

```go
// 生成 trace 文件
import (
    "os"
    "runtime/trace"
)

func enableTracing() {
    f, err := os.Create("trace.out")
    if err != nil {
        panic(err)
    }
    defer f.Close()
    
    if err := trace.Start(f); err != nil {
        panic(err)
    }
    defer trace.Stop()
    
    // 应用程序运行
}
```

```bash
# 分析 trace 文件
go tool trace trace.out
```

### 第三方工具

#### 性能监控脚本

```bash
#!/bin/bash
# scripts/monitor-performance.sh

PID=$(pgrep magic-terminal)
if [[ -z "$PID" ]]; then
    echo "Magic Terminal 未运行"
    exit 1
fi

echo "监控 Magic Terminal 性能 (PID: $PID)"
echo "时间,CPU(%),内存(MB),文件描述符"

while true; do
    # CPU 使用率
    CPU=$(ps -p $PID -o pcpu= | tr -d ' ')
    
    # 内存使用 (MB)
    MEM=$(ps -p $PID -o rss= | awk '{print $1/1024}')
    
    # 文件描述符数量
    FD_COUNT=$(lsof -p $PID 2>/dev/null | wc -l)
    
    # 时间戳
    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo "$TIMESTAMP,$CPU,$MEM,$FD_COUNT"
    
    sleep 5
done
```

## 🚀 启动性能优化

### 延迟初始化

```go
// 使用 sync.Once 进行延迟初始化
type Terminal struct {
    // ... 其他字段
    
    rendererOnce sync.Once
    renderer     *RenderEngine
    
    themeOnce sync.Once
    theme     *ThemeManager
}

func (t *Terminal) getRenderer() *RenderEngine {
    t.rendererOnce.Do(func() {
        t.renderer = NewRenderEngine(t)
    })
    return t.renderer
}

func (t *Terminal) getTheme() *ThemeManager {
    t.themeOnce.Do(func() {
        t.theme = NewThemeManager()
    })
    return t.theme
}
```

### 预编译模板和资源

```go
//go:embed translation/*.json
var translationFS embed.FS

// 预解析翻译文件
var translations map[string]map[string]string

func init() {
    translations = make(map[string]map[string]string)
    
    entries, _ := translationFS.ReadDir("translation")
    for _, entry := range entries {
        if strings.HasSuffix(entry.Name(), ".json") {
            lang := strings.TrimSuffix(entry.Name(), ".json")
            data, _ := translationFS.ReadFile("translation/" + entry.Name())
            
            var langMap map[string]string
            json.Unmarshal(data, &langMap)
            translations[lang] = langMap
        }
    }
}
```

### 配置缓存

```go
type ConfigCache struct {
    cache    map[string]interface{}
    mu       sync.RWMutex
    lastLoad time.Time
    ttl      time.Duration
}

func (c *ConfigCache) Get(key string) (interface{}, bool) {
    c.mu.RLock()
    defer c.mu.RUnlock()
    
    // 检查缓存是否过期
    if time.Since(c.lastLoad) > c.ttl {
        return nil, false
    }
    
    value, exists := c.cache[key]
    return value, exists
}

func (c *ConfigCache) Set(key string, value interface{}) {
    c.mu.Lock()
    defer c.mu.Unlock()
    
    if c.cache == nil {
        c.cache = make(map[string]interface{})
    }
    
    c.cache[key] = value
    c.lastLoad = time.Now()
}
```

## 🖼️ 渲染性能优化

### 脏区域渲染

```go
type DirtyRegion struct {
    X, Y          int
    Width, Height int
    Priority      int
}

type RenderEngine struct {
    dirtyRegions []DirtyRegion
    fullRedraw   bool
    mu           sync.Mutex
}

func (r *RenderEngine) MarkDirty(x, y, width, height int) {
    r.mu.Lock()
    defer r.mu.Unlock()
    
    region := DirtyRegion{
        X: x, Y: y,
        Width: width, Height: height,
        Priority: calculatePriority(x, y, width, height),
    }
    
    r.dirtyRegions = append(r.dirtyRegions, region)
    
    // 合并重叠区域
    r.mergeOverlappingRegions()
}

func (r *RenderEngine) mergeOverlappingRegions() {
    // 使用区间合并算法减少重绘区域
    merged := make([]DirtyRegion, 0, len(r.dirtyRegions))
    
    for _, region := range r.dirtyRegions {
        wasmerged := false
        
        for i := range merged {
            if r.regionsOverlap(merged[i], region) {
                merged[i] = r.mergeRegions(merged[i], region)
                wasmerged = true
                break
            }
        }
        
        if !wasmerged {
            merged = append(merged, region)
        }
    }
    
    r.dirtyRegions = merged
}
```

### 双缓冲渲染

```go
type DoubleBuffer struct {
    frontBuffer [][]Cell
    backBuffer  [][]Cell
    rows        int
    cols        int
    mu          sync.RWMutex
}

func (db *DoubleBuffer) SwapBuffers() {
    db.mu.Lock()
    defer db.mu.Unlock()
    
    db.frontBuffer, db.backBuffer = db.backBuffer, db.frontBuffer
}

func (db *DoubleBuffer) WriteToBack(row, col int, cell Cell) {
    db.mu.Lock()
    defer db.mu.Unlock()
    
    if row >= 0 && row < db.rows && col >= 0 && col < db.cols {
        db.backBuffer[row][col] = cell
    }
}

func (db *DoubleBuffer) ReadFromFront(row, col int) Cell {
    db.mu.RLock()
    defer db.mu.RUnlock()
    
    if row >= 0 && row < db.rows && col >= 0 && col < db.cols {
        return db.frontBuffer[row][col]
    }
    return Cell{}
}
```

### 字体缓存

```go
type FontCache struct {
    cache       map[FontKey]*font.Face
    metrics     map[FontKey]FontMetrics
    maxSize     int
    accessOrder []FontKey
    mu          sync.RWMutex
}

type FontKey struct {
    Family string
    Size   float32
    Style  FontStyle
}

func (fc *FontCache) GetFont(key FontKey) *font.Face {
    fc.mu.RLock()
    face, exists := fc.cache[key]
    fc.mu.RUnlock()
    
    if exists {
        fc.updateAccessOrder(key)
        return face
    }
    
    return fc.loadFont(key)
}

func (fc *FontCache) loadFont(key FontKey) *font.Face {
    fc.mu.Lock()
    defer fc.mu.Unlock()
    
    // 检查缓存大小
    if len(fc.cache) >= fc.maxSize {
        fc.evictLRU()
    }
    
    // 加载字体
    face := loadFontFace(key)
    fc.cache[key] = face
    fc.accessOrder = append(fc.accessOrder, key)
    
    return face
}
```

## 💾 内存优化

### 对象池

```go
// Cell 对象池
var cellPool = sync.Pool{
    New: func() interface{} {
        return &Cell{}
    },
}

func GetCell() *Cell {
    return cellPool.Get().(*Cell)
}

func PutCell(cell *Cell) {
    cell.Reset() // 重置状态
    cellPool.Put(cell)
}

// 缓冲区对象池
type BufferPool struct {
    pools map[int]*sync.Pool
    mu    sync.RWMutex
}

func NewBufferPool() *BufferPool {
    return &BufferPool{
        pools: make(map[int]*sync.Pool),
    }
}

func (bp *BufferPool) Get(size int) []byte {
    bp.mu.RLock()
    pool, exists := bp.pools[size]
    bp.mu.RUnlock()
    
    if !exists {
        bp.mu.Lock()
        pool = &sync.Pool{
            New: func() interface{} {
                return make([]byte, size)
            },
        }
        bp.pools[size] = pool
        bp.mu.Unlock()
    }
    
    return pool.Get().([]byte)
}

func (bp *BufferPool) Put(buf []byte) {
    size := cap(buf)
    
    bp.mu.RLock()
    pool, exists := bp.pools[size]
    bp.mu.RUnlock()
    
    if exists {
        pool.Put(buf[:0]) // 重置长度但保留容量
    }
}
```

### 内存使用监控

```go
func (t *Terminal) monitorMemoryUsage() {
    ticker := time.NewTicker(30 * time.Second)
    defer ticker.Stop()
    
    for {
        select {
        case <-ticker.C:
            var m runtime.MemStats
            runtime.ReadMemStats(&m)
            
            log.Printf("内存统计:")
            log.Printf("  分配内存: %d KB", m.Alloc/1024)
            log.Printf("  总分配: %d KB", m.TotalAlloc/1024)
            log.Printf("  系统内存: %d KB", m.Sys/1024)
            log.Printf("  GC 次数: %d", m.NumGC)
            
            // 检查内存泄漏
            if m.Alloc > 100*1024*1024 { // 100MB
                log.Printf("警告: 内存使用过高")
                runtime.GC() // 强制垃圾回收
            }
            
        case <-t.ctx.Done():
            return
        }
    }
}
```

### 垃圾回收优化

```go
func optimizeGC() {
    // 设置 GC 目标百分比
    debug.SetGCPercent(50) // 默认是 100
    
    // 设置最大内存限制
    debug.SetMemoryLimit(200 * 1024 * 1024) // 200MB
    
    // 定期手动触发 GC
    go func() {
        ticker := time.NewTicker(5 * time.Minute)
        defer ticker.Stop()
        
        for range ticker.C {
            runtime.GC()
        }
    }()
}
```

## ⚡ I/O 性能优化

### 缓冲 I/O

```go
type BufferedPTY struct {
    pty        PTYInterface
    readBuf    *bufio.Reader
    writeBuf   *bufio.Writer
    bufSize    int
    flushTimer *time.Timer
    mu         sync.Mutex
}

func NewBufferedPTY(pty PTYInterface, bufSize int) *BufferedPTY {
    return &BufferedPTY{
        pty:     pty,
        readBuf: bufio.NewReaderSize(pty, bufSize),
        writeBuf: bufio.NewWriterSize(pty, bufSize),
        bufSize: bufSize,
    }
}

func (bp *BufferedPTY) Write(data []byte) (int, error) {
    bp.mu.Lock()
    defer bp.mu.Unlock()
    
    n, err := bp.writeBuf.Write(data)
    
    // 设置延迟刷新
    if bp.flushTimer != nil {
        bp.flushTimer.Reset(10 * time.Millisecond)
    } else {
        bp.flushTimer = time.AfterFunc(10*time.Millisecond, func() {
            bp.mu.Lock()
            bp.writeBuf.Flush()
            bp.mu.Unlock()
        })
    }
    
    return n, err
}

func (bp *BufferedPTY) Read(data []byte) (int, error) {
    return bp.readBuf.Read(data)
}
```

### 异步 I/O 处理

```go
type AsyncIOProcessor struct {
    inputChan  chan []byte
    outputChan chan []byte
    errorChan  chan error
    workers    int
    wg         sync.WaitGroup
}

func NewAsyncIOProcessor(workers int) *AsyncIOProcessor {
    return &AsyncIOProcessor{
        inputChan:  make(chan []byte, 100),
        outputChan: make(chan []byte, 100),
        errorChan:  make(chan error, 10),
        workers:    workers,
    }
}

func (aio *AsyncIOProcessor) Start() {
    for i := 0; i < aio.workers; i++ {
        aio.wg.Add(1)
        go aio.worker()
    }
}

func (aio *AsyncIOProcessor) worker() {
    defer aio.wg.Done()
    
    for data := range aio.inputChan {
        // 处理输入数据
        processed := aio.processData(data)
        
        select {
        case aio.outputChan <- processed:
        case <-time.After(100 * time.Millisecond):
            // 输出通道阻塞，记录错误
            aio.errorChan <- fmt.Errorf("output channel blocked")
        }
    }
}
```

## 🔄 并发优化

### Goroutine 池

```go
type GoroutinePool struct {
    taskChan chan func()
    wg       sync.WaitGroup
    size     int
    stop     chan struct{}
}

func NewGoroutinePool(size int) *GoroutinePool {
    pool := &GoroutinePool{
        taskChan: make(chan func(), size*2),
        size:     size,
        stop:     make(chan struct{}),
    }
    
    for i := 0; i < size; i++ {
        pool.wg.Add(1)
        go pool.worker()
    }
    
    return pool
}

func (p *GoroutinePool) worker() {
    defer p.wg.Done()
    
    for {
        select {
        case task := <-p.taskChan:
            task()
        case <-p.stop:
            return
        }
    }
}

func (p *GoroutinePool) Submit(task func()) error {
    select {
    case p.taskChan <- task:
        return nil
    case <-time.After(100 * time.Millisecond):
        return fmt.Errorf("goroutine pool is full")
    }
}
```

### 无锁数据结构

```go
// 无锁环形缓冲区
type LockFreeRingBuffer struct {
    buffer []interface{}
    mask   uint64
    _      [8]uint64 // 缓存行填充
    head   uint64
    _      [8]uint64 // 缓存行填充
    tail   uint64
    _      [8]uint64 // 缓存行填充
}

func NewLockFreeRingBuffer(size int) *LockFreeRingBuffer {
    // 确保大小是 2 的幂
    if size&(size-1) != 0 {
        panic("size must be power of 2")
    }
    
    return &LockFreeRingBuffer{
        buffer: make([]interface{}, size),
        mask:   uint64(size - 1),
    }
}

func (rb *LockFreeRingBuffer) Push(item interface{}) bool {
    head := atomic.LoadUint64(&rb.head)
    tail := atomic.LoadUint64(&rb.tail)
    
    // 检查缓冲区是否已满
    if head-tail >= uint64(len(rb.buffer)) {
        return false
    }
    
    rb.buffer[head&rb.mask] = item
    atomic.StoreUint64(&rb.head, head+1)
    return true
}

func (rb *LockFreeRingBuffer) Pop() (interface{}, bool) {
    head := atomic.LoadUint64(&rb.head)
    tail := atomic.LoadUint64(&rb.tail)
    
    // 检查缓冲区是否为空
    if head == tail {
        return nil, false
    }
    
    item := rb.buffer[tail&rb.mask]
    atomic.StoreUint64(&rb.tail, tail+1)
    return item, true
}
```

## 📈 性能监控和指标

### 性能指标收集

```go
type PerformanceMetrics struct {
    StartTime     time.Time
    FrameCount    int64
    RenderTime    time.Duration
    InputLatency  time.Duration
    MemoryUsage   int64
    CPUUsage      float64
    mu            sync.RWMutex
}

func (pm *PerformanceMetrics) RecordFrame(renderTime time.Duration) {
    pm.mu.Lock()
    defer pm.mu.Unlock()
    
    pm.FrameCount++
    pm.RenderTime += renderTime
}

func (pm *PerformanceMetrics) GetFPS() float64 {
    pm.mu.RLock()
    defer pm.mu.RUnlock()
    
    elapsed := time.Since(pm.StartTime).Seconds()
    if elapsed == 0 {
        return 0
    }
    
    return float64(pm.FrameCount) / elapsed
}

func (pm *PerformanceMetrics) GetAverageRenderTime() time.Duration {
    pm.mu.RLock()
    defer pm.mu.RUnlock()
    
    if pm.FrameCount == 0 {
        return 0
    }
    
    return pm.RenderTime / time.Duration(pm.FrameCount)
}
```

### 性能报告

```go
func (t *Terminal) generatePerformanceReport() {
    metrics := t.performanceMetrics
    
    report := fmt.Sprintf(`
性能报告
========
运行时间: %v
总帧数: %d
平均FPS: %.2f
平均渲染时间: %v
输入延迟: %v
内存使用: %d KB
CPU使用: %.2f%%
`,
        time.Since(metrics.StartTime),
        metrics.FrameCount,
        metrics.GetFPS(),
        metrics.GetAverageRenderTime(),
        metrics.InputLatency,
        metrics.MemoryUsage/1024,
        metrics.CPUUsage,
    )
    
    log.Println(report)
}
```

## 🧪 性能测试

### 基准测试

```go
func BenchmarkTerminalRender(b *testing.B) {
    term := setupBenchmarkTerminal(b)
    defer term.Stop()
    
    // 填充终端内容
    fillTerminalWithTestData(term, 1000)
    
    b.ResetTimer()
    b.ReportAllocs()
    
    for i := 0; i < b.N; i++ {
        term.Render()
    }
}

func BenchmarkInputProcessing(b *testing.B) {
    term := setupBenchmarkTerminal(b)
    defer term.Stop()
    
    testInput := []byte("echo hello world\n")
    
    b.ResetTimer()
    b.ReportAllocs()
    
    for i := 0; i < b.N; i++ {
        term.ProcessInput(testInput)
    }
}

func BenchmarkColorParsing(b *testing.B) {
    colorCodes := []string{
        "\033[31m",
        "\033[42m", 
        "\033[1;33m",
        "\033[38;5;196m",
        "\033[38;2;255;128;0m",
    }
    
    b.ResetTimer()
    b.ReportAllocs()
    
    for i := 0; i < b.N; i++ {
        for _, code := range colorCodes {
            parseColorCode(code)
        }
    }
}
```

### 压力测试

```go
func TestTerminalStressTest(t *testing.T) {
    if testing.Short() {
        t.Skip("跳过压力测试")
    }
    
    term := setupTestTerminal(t)
    defer term.Stop()
    
    // 并发写入测试
    const numWorkers = 10
    const messagesPerWorker = 1000
    
    var wg sync.WaitGroup
    errors := make(chan error, numWorkers)
    
    for i := 0; i < numWorkers; i++ {
        wg.Add(1)
        go func(workerID int) {
            defer wg.Done()
            
            for j := 0; j < messagesPerWorker; j++ {
                message := fmt.Sprintf("Worker %d Message %d\n", workerID, j)
                if _, err := term.Write([]byte(message)); err != nil {
                    errors <- err
                    return
                }
            }
        }(i)
    }
    
    wg.Wait()
    close(errors)
    
    // 检查错误
    for err := range errors {
        t.Errorf("压力测试失败: %v", err)
    }
    
    // 验证性能指标
    metrics := term.GetPerformanceMetrics()
    assert.Less(t, metrics.GetAverageRenderTime(), 16*time.Millisecond) // < 16ms (60 FPS)
    assert.Greater(t, metrics.GetFPS(), 30.0) // > 30 FPS
}
```

## 🔧 配置优化

### 性能配置选项

```go
type PerformanceConfig struct {
    // 渲染优化
    EnableVSync        bool          `json:"enable_vsync"`
    TargetFPS          int           `json:"target_fps"`
    EnableDirtyRender  bool          `json:"enable_dirty_render"`
    
    // 内存优化
    BufferSize         int           `json:"buffer_size"`
    MaxCacheSize       int           `json:"max_cache_size"`
    GCPercent          int           `json:"gc_percent"`
    
    // 并发优化
    WorkerCount        int           `json:"worker_count"`
    EnableGoroutinePool bool         `json:"enable_goroutine_pool"`
    
    // I/O 优化
    ReadBufferSize     int           `json:"read_buffer_size"`
    WriteBufferSize    int           `json:"write_buffer_size"`
    FlushInterval      time.Duration `json:"flush_interval"`
}

func DefaultPerformanceConfig() PerformanceConfig {
    return PerformanceConfig{
        EnableVSync:         true,
        TargetFPS:          60,
        EnableDirtyRender:  true,
        BufferSize:         32768,
        MaxCacheSize:       1000,
        GCPercent:          50,
        WorkerCount:        runtime.NumCPU(),
        EnableGoroutinePool: true,
        ReadBufferSize:     8192,
        WriteBufferSize:    8192,
        FlushInterval:      10 * time.Millisecond,
    }
}
```

---

更多信息请参考：
- [架构设计](./architecture.md)
- [测试指南](./testing-guide.md)
- [故障排除](./troubleshooting.md)
