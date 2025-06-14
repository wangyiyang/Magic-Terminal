# Magic Terminal Makefile
# 项目名称和版本
APP_NAME := magic-terminal
BINARY_NAME := magic-terminal
MAIN_PACKAGE := ./cmd/fyneterm
VERSION := $(shell git describe --tags --always --dirty 2>/dev/null || echo "dev")
BUILD_TIME := $(shell date -u '+%Y-%m-%d_%H:%M:%S')
COMMIT_HASH := $(shell git rev-parse --short HEAD 2>/dev/null || echo "unknown")

# Go 相关变量
GO := go
GOCMD := $(GO)
GOBUILD := $(GOCMD) build
GOCLEAN := $(GOCMD) clean
GOTEST := $(GOCMD) test
GOGET := $(GOCMD) get
GOMOD := $(GOCMD) mod
GOFMT := $(GOCMD) fmt

# 构建标志
LDFLAGS := -ldflags "-X main.version=$(VERSION) -X main.buildTime=$(BUILD_TIME) -X main.commitHash=$(COMMIT_HASH)"
BUILD_FLAGS := $(LDFLAGS) -trimpath

# 输出目录
DIST_DIR := dist
BIN_DIR := bin

# 平台和架构
PLATFORMS := linux darwin windows
ARCHITECTURES := amd64 arm64

# 颜色定义（用于输出）
GREEN := \033[32m
YELLOW := \033[33m
RED := \033[31m
RESET := \033[0m

.PHONY: help build clean test coverage lint fmt vet tidy run install dev release deps check all

# 默认目标
all: clean fmt vet test build

# 帮助信息
help: ## 显示帮助信息
	@echo "Magic Terminal Makefile"
	@echo ""
	@echo "可用的命令："
	@awk 'BEGIN {FS = ":.*##"} /^[a-zA-Z_-]+:.*?##/ { printf "  $(GREEN)%-15s$(RESET) %s\n", $$1, $$2 }' $(MAKEFILE_LIST)

# 构建
build: ## 构建应用程序
	@echo "$(GREEN)构建 $(BINARY_NAME)...$(RESET)"
	@mkdir -p $(BIN_DIR)
	$(GOBUILD) $(BUILD_FLAGS) -o $(BIN_DIR)/$(BINARY_NAME) $(MAIN_PACKAGE)
	@echo "$(GREEN)构建完成: $(BIN_DIR)/$(BINARY_NAME)$(RESET)"

# 开发模式构建（快速构建，不包含版本信息）
build-dev: ## 开发模式快速构建
	@echo "$(GREEN)开发模式构建...$(RESET)"
	@mkdir -p $(BIN_DIR)
	$(GOBUILD) -o $(BIN_DIR)/$(BINARY_NAME) $(MAIN_PACKAGE)

# 运行应用程序
run: ## 运行应用程序
	@echo "$(GREEN)运行 $(BINARY_NAME)...$(RESET)"
	$(GOCMD) run $(MAIN_PACKAGE)

# 开发模式（构建并运行）
dev: build-dev ## 开发模式：快速构建并运行
	@echo "$(GREEN)启动开发模式...$(RESET)"
	./$(BIN_DIR)/$(BINARY_NAME)

# 测试
test: ## 运行所有测试
	@echo "$(GREEN)运行测试...$(RESET)"
	$(GOTEST) -v ./...

# 测试（短模式）
test-short: ## 运行短测试
	@echo "$(GREEN)运行短测试...$(RESET)"
	$(GOTEST) -short ./...

# 测试覆盖率
coverage: ## 生成测试覆盖率报告
	@echo "$(GREEN)生成覆盖率报告...$(RESET)"
	@mkdir -p $(DIST_DIR)
	$(GOTEST) -coverprofile=$(DIST_DIR)/coverage.out ./...
	$(GOCMD) tool cover -html=$(DIST_DIR)/coverage.out -o $(DIST_DIR)/coverage.html
	@echo "$(GREEN)覆盖率报告生成: $(DIST_DIR)/coverage.html$(RESET)"

# 基准测试
bench: ## 运行基准测试
	@echo "$(GREEN)运行基准测试...$(RESET)"
	$(GOTEST) -bench=. -benchmem ./...

# 代码格式化
fmt: ## 格式化代码
	@echo "$(GREEN)格式化代码...$(RESET)"
	$(GOFMT) ./...

# 代码检查
vet: ## 运行 go vet
	@echo "$(GREEN)运行 go vet...$(RESET)"
	$(GOCMD) vet ./...

# 依赖整理
tidy: ## 整理 go modules
	@echo "$(GREEN)整理依赖...$(RESET)"
	$(GOMOD) tidy

# 下载依赖
deps: ## 下载依赖
	@echo "$(GREEN)下载依赖...$(RESET)"
	$(GOMOD) download

# 更新依赖
update-deps: ## 更新所有依赖到最新版本
	@echo "$(GREEN)更新依赖...$(RESET)"
	$(GOGET) -u ./...
	$(GOMOD) tidy

# 安装到系统
install: build ## 安装到 GOPATH/bin
	@echo "$(GREEN)安装 $(BINARY_NAME) 到系统...$(RESET)"
	$(GOCMD) install $(BUILD_FLAGS) $(MAIN_PACKAGE)

# 清理
clean: ## 清理构建文件
	@echo "$(GREEN)清理构建文件...$(RESET)"
	$(GOCLEAN)
	rm -rf $(BIN_DIR)
	rm -rf $(DIST_DIR)

# 代码质量检查
check: fmt vet test ## 运行所有代码质量检查

# Lint（需要安装 golangci-lint）
lint: ## 运行 golangci-lint
	@if command -v golangci-lint >/dev/null 2>&1; then \
		echo "$(GREEN)运行 golangci-lint...$(RESET)"; \
		golangci-lint run; \
	else \
		echo "$(YELLOW)golangci-lint 未安装，跳过 lint 检查$(RESET)"; \
		echo "$(YELLOW)安装命令: go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest$(RESET)"; \
	fi

# 跨平台构建
build-all: ## 构建所有平台的二进制文件
	@echo "$(GREEN)构建所有平台版本...$(RESET)"
	@mkdir -p $(DIST_DIR)
	@for platform in $(PLATFORMS); do \
		for arch in $(ARCHITECTURES); do \
			if [ "$$platform" = "windows" ]; then \
				ext=".exe"; \
			else \
				ext=""; \
			fi; \
			output_name=$(DIST_DIR)/$(BINARY_NAME)-$$platform-$$arch$$ext; \
			echo "$(GREEN)构建 $$platform/$$arch...$(RESET)"; \
			GOOS=$$platform GOARCH=$$arch $(GOBUILD) $(BUILD_FLAGS) -o $$output_name $(MAIN_PACKAGE); \
			if [ $$? -eq 0 ]; then \
				echo "$(GREEN)✓ $$output_name$(RESET)"; \
			else \
				echo "$(RED)✗ 构建失败: $$platform/$$arch$(RESET)"; \
			fi; \
		done; \
	done

# 创建发布包
release: clean build-all ## 创建发布包
	@echo "$(GREEN)创建发布包...$(RESET)"
	@cd $(DIST_DIR) && \
	for platform in $(PLATFORMS); do \
		for arch in $(ARCHITECTURES); do \
			if [ "$$platform" = "windows" ]; then \
				ext=".exe"; \
				archive_ext=".zip"; \
			else \
				ext=""; \
				archive_ext=".tar.gz"; \
			fi; \
			binary_name=$(BINARY_NAME)-$$platform-$$arch$$ext; \
			if [ -f $$binary_name ]; then \
				archive_name=$(APP_NAME)-$(VERSION)-$$platform-$$arch$$archive_ext; \
				if [ "$$platform" = "windows" ]; then \
					zip $$archive_name $$binary_name; \
				else \
					tar -czf $$archive_name $$binary_name; \
				fi; \
				echo "$(GREEN)✓ $$archive_name$(RESET)"; \
			fi; \
		done; \
	done

# 显示版本信息
version: ## 显示版本信息
	@echo "$(GREEN)版本信息:$(RESET)"
	@echo "  版本: $(VERSION)"
	@echo "  构建时间: $(BUILD_TIME)"
	@echo "  提交哈希: $(COMMIT_HASH)"

# Fyne 相关命令
fyne-package: build ## 使用 fyne package 打包应用
	@echo "$(GREEN)使用 fyne package 打包...$(RESET)"
	@mkdir -p $(DIST_DIR)
	@GOPATH_BIN=$$($(GOCMD) env GOPATH)/bin; \
	if [ -f "$$GOPATH_BIN/fyne" ]; then \
		cd cmd/fyneterm && $$GOPATH_BIN/fyne package -exe ../../bin/$(BINARY_NAME); \
		if ls *.app >/dev/null 2>&1; then mv *.app ../../$(DIST_DIR)/; fi; \
		if ls *.exe >/dev/null 2>&1; then mv *.exe ../../$(DIST_DIR)/; fi; \
		if ls *.tar.gz >/dev/null 2>&1; then mv *.tar.gz ../../$(DIST_DIR)/; fi; \
		echo "$(GREEN)打包完成，文件已移动到 $(DIST_DIR)/ 目录$(RESET)"; \
	elif command -v fyne >/dev/null 2>&1; then \
		cd cmd/fyneterm && fyne package -exe ../../bin/$(BINARY_NAME); \
		if ls *.app >/dev/null 2>&1; then mv *.app ../../$(DIST_DIR)/; fi; \
		if ls *.exe >/dev/null 2>&1; then mv *.exe ../../$(DIST_DIR)/; fi; \
		if ls *.tar.gz >/dev/null 2>&1; then mv *.tar.gz ../../$(DIST_DIR)/; fi; \
		echo "$(GREEN)打包完成，文件已移动到 $(DIST_DIR)/ 目录$(RESET)"; \
	else \
		echo "$(RED)fyne 工具未安装$(RESET)"; \
		echo "$(YELLOW)安装命令: go install fyne.io/tools/cmd/fyne@latest$(RESET)"; \
	fi

# 安装开发工具
install-tools: ## 安装开发工具
	@echo "$(GREEN)安装开发工具...$(RESET)"
	@echo "$(GREEN)安装 golangci-lint...$(RESET)"
	$(GOGET) github.com/golangci/golangci-lint/cmd/golangci-lint@latest
	@echo "$(GREEN)安装新版本的 fyne 工具...$(RESET)"
	$(GOGET) fyne.io/tools/cmd/fyne@latest
	@echo "$(GREEN)开发工具安装完成$(RESET)"
	@echo "$(YELLOW)已安装工具:$(RESET)"
	@echo "  - golangci-lint: 代码静态分析"
	@echo "  - fyne: Fyne 应用打包工具（新版本）"

# 检查 Git 状态
git-status: ## 检查 Git 状态
	@echo "$(GREEN)Git 状态:$(RESET)"
	@git status --porcelain || echo "$(RED)不是 Git 仓库$(RESET)"

# 快速开始命令
quick-start: deps build run ## 快速开始：下载依赖、构建并运行

# Docker 相关（如果需要）
docker-build: ## 构建 Docker 镜像
	@echo "$(GREEN)构建 Docker 镜像...$(RESET)"
	docker build -t $(APP_NAME):$(VERSION) .

# 显示项目信息
info: ## 显示项目信息
	@echo "$(GREEN)Magic Terminal 项目信息:$(RESET)"
	@echo "  项目名称: $(APP_NAME)"
	@echo "  二进制名称: $(BINARY_NAME)"
	@echo "  主包路径: $(MAIN_PACKAGE)"
	@echo "  Go 版本: $(shell $(GOCMD) version)"
	@echo "  操作系统: $(shell $(GOCMD) env GOOS)"
	@echo "  架构: $(shell $(GOCMD) env GOARCH)"
