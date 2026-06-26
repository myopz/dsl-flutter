
# Changelog

All notable changes to the DSL Flutter package will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.0.0] - 2026-06-26

### Added
- 🎉 初始稳定版本发布
- ✨ **零括号 DSL 语法**：用缩进代替嵌套括号
- ✨ **组件别名** (`@Alias`)：为常用组件创建简短别名
- ✨ **模板片段** (`@Fragment`)：复用 UI 结构，支持两种调用方式
  - 传统调用：`UserCard(name: '张三')`
  - 前缀调用：`@UserCard name: '张三'`（无括号！）
- ✨ **编译时转换**：零运行时开销，性能无损
- ✨ **完全通用**：支持所有 Flutter 及第三方组件
- 🛡️ **防格式化保护**：一键配置防止 IDE 自动破坏 DSL
- 🧪 **完整测试**：100% 测试覆盖率

### CLI 工具
- ✨ `dsl_flutter setup`：一键配置开发环境
- ✨ `dsl_flutter init`：初始化项目结构
- ✨ `dsl_flutter watch`：监听文件自动转换
- ✨ `dsl_flutter build`：一次性构建所有文件
- ✨ `dsl_flutter check`：检查文件格式

---

## Version Roadmap

| Version | Type | Target Date |主要内容 |
|---------|------|-------------|---------|
| v1.0.0 | Stable | 2026-06-26 | 首个稳定版本 |
---