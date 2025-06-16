---
name: 发布版本
about: 创建新版本发布的 checklist
title: 'Release v[VERSION]'
labels: 'release'
assignees: ''

---

## 版本发布 Checklist

### 准备工作
- [ ] 确认所有功能已完成并测试通过
- [ ] 更新 CHANGELOG.md
- [ ] 更新版本号相关文件
- [ ] 所有 CI 检查通过

### 发布步骤
- [ ] 创建并推送版本标签：`git tag v[VERSION] && git push origin v[VERSION]`
- [ ] 确认 GitHub Actions 自动构建成功
- [ ] 检查发布的制品（二进制文件和 GUI 应用）
- [ ] 测试下载的制品是否正常工作

### 发布后
- [ ] 更新 README.md 中的下载链接（如需要）
- [ ] 发布公告（如需要）
- [ ] 关闭相关的 issues 和 pull requests

### 版本信息
**版本号：** v[VERSION]
**发布日期：** [DATE]
**主要变更：**
- 功能1
- 功能2
- 修复问题1

### 测试清单
- [ ] macOS 应用包能正常运行
- [ ] Windows 可执行文件能正常运行
- [ ] Linux 二进制文件能正常运行
- [ ] 命令行参数正常工作
- [ ] 终端功能正常（输入、颜色、滚动等）
