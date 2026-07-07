# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概述

这是 **Spring Boot** 的主源码仓库（版本 4.1.1-SNAPSHOT），基于 Spring Framework 7.x，最低运行时要求 Java 17，构建工具要求 Java 25。

---

## 常用命令

### 构建与验证

```bash
# 完整构建（含测试、Checkstyle）
./gradlew build

# 只运行校验（测试 + Checkstyle，不打包）
./gradlew check

# 代码格式化（违反格式规则时运行）
./gradlew format

# 仅格式化 buildSrc 中的代码
./gradlew -p buildSrc format

# 运行 Checkstyle
./gradlew checkstyleMain checkstyleTest
```

### 测试

```bash
# 运行某个模块的所有测试
./gradlew :core:spring-boot:test

# 运行某个具体测试类（Gradle 过滤器语法）
./gradlew :core:spring-boot:test --tests "org.springframework.boot.SpringApplicationTests"

# 运行集成测试（intTest 源集）
./gradlew :core:spring-boot:intTest

# 避免测试环境变量干扰
unset SPRING_PROFILES_ACTIVE && ./gradlew check
```

### 单模块操作

```bash
# 只构建某个模块（不递归依赖）
./gradlew :module:spring-boot-web-server:build

# 在子项目中运行任意任务（以冒号分隔路径）
./gradlew :starter:spring-boot-starter-web:dependencies
```

### 上游同步

本仓库是 `spring-projects/spring-boot` 的 fork，提供了辅助脚本同步上游：

```bash
# 添加 upstream remote 并拉取所有分支和 tag（已存在则跳过添加）
./scripts/fetch-upstream.sh

# 基于上游分支创建本地跟踪分支
git checkout -b 4.0.x upstream/4.0.x
```

---

## 代码架构

### 顶层目录结构

仓库按功能分为以下几个顶层目录（在 `settings.gradle` 中以 `include` 定义）：

| 目录 | 说明 |
|------|------|
| `core/` | Spring Boot 核心模块（`spring-boot`、`spring-boot-autoconfigure`、测试框架等） |
| `module/` | 各技术集成模块（Web、数据库、消息、监控等，每个模块对应一项技术） |
| `starter/` | Starter POM 模块，仅做依赖聚合，不含任何源码 |
| `platform/` | BOM（Bill of Materials）依赖管理平台 |
| `loader/` | JAR 启动加载器（`spring-boot-loader`、`spring-boot-loader-tools`） |
| `build-plugin/` | Gradle 插件、Maven 插件、Ant 插件 |
| `configuration-metadata/` | 配置元数据处理器与生成器 |
| `buildSrc/` | 项目内 Gradle 插件和构建约定（见下文） |
| `smoke-test/` | 端到端冒烟测试（各场景独立应用） |
| `integration-test/` | 跨模块集成测试 |
| `system-test/` | 系统级测试（部署、镜像） |

### 核心模块（`core/`）

- **`spring-boot`**：`SpringApplication`、`@SpringBootConfiguration`、`EnvironmentPostProcessor`、Banner、启动监听器等核心类。
- **`spring-boot-autoconfigure`**：`@EnableAutoConfiguration` 机制，所有内置自动配置类通过 `META-INF/spring/org.springframework.boot.autoconfigure.AutoConfiguration.imports` 注册。
- **`spring-boot-test`** / **`spring-boot-test-autoconfigure`**：`@SpringBootTest`、测试切片注解（`@WebMvcTest` 等）。
- **`spring-boot-testcontainers`** / **`spring-boot-docker-compose`**：容器化测试支持。

### 模块层（`module/`）

每个 `module/spring-boot-xxx` 模块：
- 包含针对某项技术的 `@AutoConfiguration` 类和 `@ConfigurationProperties` 类。
- 使用 Gradle 插件 `org.springframework.boot.auto-configuration` 和 `org.springframework.boot.configuration-properties`。
- 与其他模块之间通过 `:module:xxx` 项目引用建立依赖，而非 Maven 坐标。
- 可选依赖（`optional`）通过自定义 `OptionalDependenciesPlugin` 声明，不传递给下游。

### Starter 层（`starter/`）

Starter 模块仅有 `build.gradle`，无 Java 源码，通过 `org.springframework.boot.starter` 插件生成 starter 元数据。

### 自动配置注册机制

新增自动配置类必须同时：
1. 使用 `@AutoConfiguration` 注解（或 `@AutoConfigureAfter`/`@AutoConfigureBefore` 控制顺序）。
2. 在所属模块的 `src/main/resources/META-INF/spring/org.springframework.boot.autoconfigure.AutoConfiguration.imports` 中注册全限定类名。

构建时 `CheckAutoConfigurationImports` 任务会校验两者一致性。

### 构建约定（`buildSrc/`）

`buildSrc/src/main/java/org/springframework/boot/build/` 包含所有自定义 Gradle 插件：

- `JavaConventions`：强制 Java 17 源码兼容性，构建需 Java 25（`BUILD_JAVA_VERSION=25`，`RUNTIME_JAVA_VERSION=17`）。
- `AutoConfigurationPlugin`：为含自动配置的模块添加注解处理器依赖，并执行 imports 文件检查。
- `StarterPlugin`：为 starter 模块生成元数据并检查依赖冲突。
- `IntegrationTestPlugin`：添加 `intTest` 源集，任务名 `intTest`。
- `ConventionsPlugin`：聚合 Spring JavaFormat、Checkstyle 等统一约定。

### 平台 BOM（`platform/`）

- `spring-boot-dependencies`：对外发布的依赖管理 BOM。
- `spring-boot-internal-dependencies`：内部构建使用的依赖版本，不对外发布。

---

## 代码规范

- 所有提交必须包含 `Signed-off-by` trailer（DCO）。
- 使用 Spring JavaFormat 进行代码格式化（`./gradlew format`）。
- 新增 `.java` 文件需包含 ASF License 头、Javadoc 类注释及 `@author` 标签。
- 提交信息遵循 [Tim Pope 规范](https://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html)。