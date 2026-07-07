# scripts

本目录存放仓库维护相关的辅助脚本。

## fetch-upstream.sh

同步官方上游仓库（`spring-projects/spring-boot`）的所有分支和 tag 到本地。

**用途**：本仓库是官方 fork，GitHub 的 "Sync fork" 只能同步默认分支，历史分支和 tag 需手动拉取。

**使用方式**：

```bash
./scripts/fetch-upstream.sh
```

**行为**：

- 若本地尚未添加 `upstream` remote，自动添加并指向 `https://github.com/spring-projects/spring-boot.git`
- 若 `upstream` 已存在，跳过添加步骤
- 执行 `git fetch upstream --tags`，拉取全部分支（`upstream/1.0.x` … `upstream/main`）和所有历史 tag
- 打印当前所有 `upstream/*` 分支列表

**基于上游分支创建本地跟踪分支**：

```bash
git checkout -b 4.0.x upstream/4.0.x
```
