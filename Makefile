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

# 快速开始
quick-start: deps build ## 快速开始：下载依赖、构建并运行
	@echo "$(GREEN)快速开始完成！运行 ./bin/$(BINARY_NAME) 启动应用$(RESET)"

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

# Git 和发布相关命令
git-clean-check: ## 检查 Git 工作目录是否干净
	@if [ -n "$$(git status --porcelain)" ]; then \
		echo "$(RED)错误: Git 工作目录不干净$(RESET)"; \
		git status --short; \
		exit 1; \
	else \
		echo "$(GREEN)Git 工作目录干净$(RESET)"; \
	fi

pre-release: git-clean-check test lint ## 发布前检查
	@echo "$(GREEN)发布前检查通过$(RESET)"

tag: ## 创建 Git 标签 (用法: make tag VERSION=v1.0.0)
	@if [ -z "$(VERSION)" ]; then \
		echo "$(RED)错误: 请指定版本号，例如: make tag VERSION=v1.0.0$(RESET)"; \
		exit 1; \
	fi
	@echo "$(GREEN)创建标签 $(VERSION)...$(RESET)"
	@if git tag -l | grep -q "^$(VERSION)$$"; then \
		echo "$(RED)错误: 标签 $(VERSION) 已存在$(RESET)"; \
		exit 1; \
	fi
	git tag -a $(VERSION) -m "Release $(VERSION)"
	@echo "$(GREEN)标签 $(VERSION) 已创建$(RESET)"
	@echo "$(YELLOW)推送标签: git push origin $(VERSION)$(RESET)"

push-tag: ## 推送标签到远程仓库
	@if [ -z "$(VERSION)" ]; then \
		echo "$(RED)错误: 请指定版本号，例如: make push-tag VERSION=v1.0.0$(RESET)"; \
		exit 1; \
	fi
	@echo "$(GREEN)推送标签 $(VERSION) 到远程仓库...$(RESET)"
	git push origin $(VERSION)
	@echo "$(GREEN)标签已推送，GitHub Actions 将自动构建发布$(RESET)"

# 快速发布（使用脚本）
quick-release: ## 快速发布 (用法: make quick-release VERSION=v1.0.0)
	@if [ -z "$(VERSION)" ]; then \
		echo "$(RED)错误: 请指定版本号，例如: make quick-release VERSION=v1.0.0$(RESET)"; \
		exit 1; \
	fi
	@./scripts/release.sh $(VERSION)

# 查看发布历史
releases: ## 查看 Git 标签/发布历史
	@echo "$(GREEN)发布历史:$(RESET)"
	@git tag -l | sort -V | tail -10

# 查看当前分支信息
branch-info: ## 显示当前分支信息
	@echo "$(GREEN)分支信息:$(RESET)"
	@echo "  当前分支: $$(git branch --show-current)"
	@echo "  最新提交: $$(git log -1 --format='%h - %s (%an, %ar)')"
	@echo "  远程状态: $$(git status -uno --porcelain=v1 2>/dev/null | wc -l | tr -d ' ') 个未推送的更改"

# CI 相关命令
ci-test: ## 模拟 CI 环境测试
	@echo "$(GREEN)模拟 CI 环境测试...$(RESET)"
	@GOOS=linux GOARCH=amd64 go build -o /dev/null ./cmd/fyneterm
	@GOOS=darwin GOARCH=amd64 go build -o /dev/null ./cmd/fyneterm || echo "$(YELLOW)macOS 交叉编译可能失败（在 CI 中正常）$(RESET)"
	@go test ./...
	@echo "$(GREEN)CI 模拟测试完成$(RESET)"

# Docker 相关（如果需要）
docker-build: ## 构建 Docker 镜像
	@echo "$(GREEN)构建 Docker 镜像...$(RESET)"
	@if [ -f "Dockerfile" ]; then \
		docker build -t $(APP_NAME):$(VERSION) .; \
		docker build -t $(APP_NAME):latest .; \
		echo "$(GREEN)Docker 镜像构建完成$(RESET)"; \
	else \
		echo "$(YELLOW)Dockerfile 不存在，跳过 Docker 构建$(RESET)"; \
	fi

# 开发环境设置
dev-setup: install-tools ## 设置开发环境
	@echo "$(GREEN)设置开发环境...$(RESET)"
	@go mod download
	@echo "$(GREEN)开发环境设置完成$(RESET)"
	@echo "$(YELLOW)可用命令:$(RESET)"
	@echo "  make dev      - 开发模式运行"
	@echo "  make test     - 运行测试"
	@echo "  make lint     - 代码检查"
	@echo "  make build    - 构建应用"

# 显示所有目标的帮助信息
help: ## 显示帮助信息
	@echo "$(GREEN)Magic Terminal 构建系统$(RESET)"
	@echo ""
	@echo "$(YELLOW)🔨 基础构建:$(RESET)"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  $(CYAN)%-18s$(RESET) %s\n", $$1, $$2}' $(MAKEFILE_LIST) | grep -E "(build|run|dev|clean)"
	@echo ""
	@echo "$(YELLOW)🧪 测试和检查:$(RESET)"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  $(CYAN)%-18s$(RESET) %s\n", $$1, $$2}' $(MAKEFILE_LIST) | grep -E "(test|check|lint|coverage)"
	@echo ""
	@echo "$(YELLOW)📦 打包和分发:$(RESET)"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  $(CYAN)%-18s$(RESET) %s\n", $$1, $$2}' $(MAKEFILE_LIST) | grep -E "(fyne-package|dmg|build-all)"
	@echo ""
	@echo "$(YELLOW)🚀 发布流程:$(RESET)"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  $(CYAN)%-18s$(RESET) %s\n", $$1, $$2}' $(MAKEFILE_LIST) | grep -E "(release|tag|push-tag)"
	@echo ""
	@echo "$(YELLOW)🛠️  工具和环境:$(RESET)"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  $(CYAN)%-18s$(RESET) %s\n", $$1, $$2}' $(MAKEFILE_LIST) | grep -E "(install|deps|tidy|dev-setup)"
	@echo ""
	@echo "$(GREEN)💡 常用工作流:$(RESET)"
	@echo "  $(BLUE)开发模式:$(RESET)      make dev"
	@echo "  $(BLUE)完整测试:$(RESET)      make check"
	@echo "  $(BLUE)macOS 应用:$(RESET)     make fyne-package"
	@echo "  $(BLUE)DMG 安装包:$(RESET)     make dmg"
	@echo "  $(BLUE)完整发布:$(RESET)      make quick-release VERSION=v1.0.0"
	@echo ""
	@echo "$(GREEN)📦 macOS 构建产物:$(RESET)"
	@echo "  • Magic Terminal.app - macOS 应用包"
	@echo "  • Magic-Terminal.dmg - 专业安装包 (推荐分发)"
	@echo ""
	@echo ""
	@echo "$(GREEN)使用方法:$(RESET)"
	@echo "  make <target>"
	@echo ""
	@echo "$(GREEN)可用目标:$(RESET)"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  $(CYAN)%-15s$(RESET) %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@echo ""
	@echo "$(GREEN)发布流程:$(RESET)"
	@echo "  1. make pre-release              - 发布前检查"
	@echo "  2. make quick-release VERSION=v1.0.0  - 快速发布"
	@echo "  或者:"
	@echo "  1. make tag VERSION=v1.0.0       - 创建标签"
	@echo "  2. make push-tag VERSION=v1.0.0  - 推送标签触发 CI"

.DEFAULT_GOAL := help

# macOS DMG 相关命令
dmg: fyne-package ## 创建 macOS DMG 安装包
	@if [[ "$$OSTYPE" != "darwin"* ]]; then \
		echo "$(YELLOW)DMG 创建仅支持 macOS 系统$(RESET)"; \
		exit 1; \
	fi
	@echo "$(BLUE)创建 DMG 安装包...$(RESET)"
	@./scripts/create-dmg.sh

dmg-background: ## 创建 DMG 背景图片
	@echo "$(BLUE)创建 DMG 背景图片...$(RESET)"
	@./scripts/create-dmg-background.sh

dmg-full: dmg-background dmg ## 创建带背景的完整 DMG 包
	@echo "$(GREEN)完整 DMG 包创建完成$(RESET)"

# DMG 测试和验证
dmg-test: dmg ## 测试 DMG 安装包
	@echo "$(BLUE)测试 DMG 安装包...$(RESET)"
	@if [ -f "$(DIST_DIR)/Magic-Terminal.dmg" ]; then \
		echo "$(GREEN)✓ DMG 文件存在$(RESET)"; \
		echo "$(BLUE)文件信息:$(RESET)"; \
		ls -lh "$(DIST_DIR)/Magic-Terminal.dmg"; \
		echo "$(BLUE)验证 DMG 完整性...$(RESET)"; \
		hdiutil verify "$(DIST_DIR)/Magic-Terminal.dmg" && \
		echo "$(GREEN)✓ DMG 文件完整性验证通过$(RESET)" || \
		echo "$(RED)✗ DMG 文件验证失败$(RESET)"; \
	else \
		echo "$(RED)✗ DMG 文件不存在$(RESET)"; \
	fi

dmg-mount: ## 挂载 DMG 文件进行测试
	@if [ -f "$(DIST_DIR)/Magic-Terminal.dmg" ]; then \
		echo "$(BLUE)挂载 DMG 文件...$(RESET)"; \
		hdiutil attach "$(DIST_DIR)/Magic-Terminal.dmg"; \
		echo "$(GREEN)DMG 已挂载，可以在 Finder 中查看$(RESET)"; \
		echo "$(YELLOW)测试完成后请运行: make dmg-unmount$(RESET)"; \
	else \
		echo "$(RED)DMG 文件不存在，请先运行: make dmg$(RESET)"; \
	fi

dmg-unmount: ## 卸载 DMG 文件
	@echo "$(BLUE)卸载 DMG 文件...$(RESET)"
	@hdiutil detach "/Volumes/Magic-Terminal" 2>/dev/null || echo "$(YELLOW)DMG 可能已经卸载$(RESET)"
