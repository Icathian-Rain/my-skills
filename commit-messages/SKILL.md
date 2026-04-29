---
name: commit-messages
description: 规范 agent 的 git commit message。用于任何支持 skills 的编码 agent 需要起草、检查、格式化、修正或创建提交信息时，尤其适用于执行 git commit 前，或用户要求提交信息遵循 Conventional Commits 风格时。
---

# Commit Messages

使用此技能时，根据仓库的实际改动生成清晰、一致的提交信息。

## 工作流程

1. 写提交信息前先检查改动。
   - 用 `git status --short` 查看变更文件。
   - 对已暂存提交，用 `git diff --cached --stat` 和 `git diff --cached` 查看改动。
   - 如果没有已暂存内容，但用户要求提交，先检查相关未暂存 diff，再决定应该暂存哪些文件。
2. 只提交属于用户当前请求的改动。
3. 如果最近提交历史里有明显的语言和风格，优先匹配仓库既有风格。否则默认使用简洁的 Conventional Commits。
4. 默认生成一个聚焦的提交信息。只有在用户明确要求，或改动明显互不相关时，才拆分为多个提交。
5. 执行提交时使用非交互式 git 命令，例如 `git commit -m "<subject>"`，或用多个 `-m` 参数添加正文和 footer。

## 语言

- 默认使用中文编写 `summary`、`body` 和需要解释的内容。
- 如果最近提交历史全部使用英文，改用英文。
- 如果仓库文档、贡献指南、commitlint 配置或用户明确要求英文提交信息，改用英文。
- 无论使用中文还是英文，`emoji type`、`scope`、`BREAKING CHANGE:`、`Fixes #123` 等结构化部分保持英文格式。

## 格式

使用以下结构：

```text
<emoji> <type>(<scope>): <summary>

<body>

<footer>
```

只有 subject line 是必需的。当 `scope`、`body`、`footer` 没有提供额外价值时，直接省略。

## Subject Line

- subject 尽量控制在 72 个字符以内。
- 使用 `emoji type` 组合，例如 `🎉 init`、`✨ feat`、`🐛 fix`。
- `scope` 可选，用来标记受影响的 package、模块、功能、命令或配置区域。
- `summary` 使用简洁的动作描述，例如 `add`、`fix`、`update`、`remove`、`avoid`，或按仓库语言使用对应表达。
- subject 末尾不要加句号。
- 除非仓库明确要求，不要在提交信息里提到 agent 名称、AI 工具名或实现过程。

## Type

- `🎉 init`: 初始化项目或创建基础结构
- `✨ feat`: 用户可见的新功能或能力
- `🐛 fix`: bug 修复或正确性问题
- `⚡️ perf`: 性能改进
- `♻️ refactor`: 不改变行为的代码结构调整
- `✅ test`: 仅测试或测试基础设施
- `📝 docs`: 仅文档变更
- `🎨 style`: 仅格式调整，不改变行为
- `📦 build`: 依赖、包管理、lockfile 或构建系统变更
- `👷 ci`: CI/CD 流程变更
- `🔧 chore`: 不适合其他类型的维护性变更
- `⏪ revert`: 回滚之前的提交

优先按用户可见影响选择 `emoji type`。如果改动混合了多种性质，选择主导影响，并在正文中说明辅助改动。

## Scope

- 使用短小、稳定的 scope，例如 `api`、`auth`、`ui`、`cli`、`deps`、`docs`，或 package 名。
- 当改动覆盖整个仓库，或没有明确 scope 时，省略 scope。
- 多词 scope 使用小写 kebab-case。

## Body

当 subject 无法完整说明改动时，添加正文。

- 说明改了什么以及为什么改，不要逐个罗列文件。
- 涉及迁移说明、行为变化、限制或风险时，需要在正文中写清楚。
- 行宽尽量控制在 72 个字符左右。

## Footer

只有当元数据确实属于提交信息时才添加 footer。

- 破坏性变更：在 subject 中添加 `!`，例如 `✨ feat!: ...` 或 `✨ feat(api)!: ...`，并添加 `BREAKING CHANGE:` footer。
- 关联 issue：使用仓库既有风格，例如 `Fixes #123` 或 `Refs #123`。
- 回滚提交：使用 `revert: <original subject>`，如果知道 SHA，正文中加入 `This reverts commit <sha>.`。

## 示例

```text
🎉 init: 初始化项目结构
```

```text
✨ feat(auth): 添加密码重置 token 过期时间
```

```text
🐛 fix(api): 处理空搜索过滤条件
```

```text
♻️ refactor(cli): 复用命令配置加载逻辑
```

```text
✨ feat!: 移除旧版导出格式

BREAKING CHANGE: CSV 导出不再包含已废弃的 v1 字段。
```
