# AGENTS.md

本仓库用于维护个人使用的 agent skills。任何 agent 在本仓库工作时，应优先遵循本文件。

## 仓库约定

- 顶层的每个 skill 目录都是源目录，例如 `commit-messages/`。
- `.codex/skills/`、`.claude/skills/`、`.opencode/skills/` 是安装目录；项目内安装优先使用指向源目录的软链接，用户目录安装优先复制 skill 目录。
- 修改 skill 内容时，编辑源目录里的文件，不要直接替换安装目录里的软链接。
- 新增 skill 时，使用小写短横线命名，例如 `commit-messages`。
- 每个 skill 至少包含 `SKILL.md`；如需 UI 元数据，可包含 `agents/openai.yaml`。

## 修改 Skill

- `SKILL.md` 的 frontmatter 只保留必要字段，至少包含 `name` 和 `description`。
- `description` 应说明 skill 做什么，以及什么时候触发。
- 正文只写 agent 执行任务真正需要知道的流程、约束和示例。
- 不要为单个 skill 添加无关的 `README.md`、安装指南或变更日志。
- 如果改动影响安装方式，同步更新 `README.md` 和 `scripts/install-skill.sh`。

## 安装

使用脚本把本仓库的 skill 软链接安装到目标项目：

```bash
./scripts/install-skill.sh /path/to/project
```

常用参数：

```bash
./scripts/install-skill.sh /path/to/project --skill commit-messages
./scripts/install-skill.sh /path/to/project --tools codex,opencode
./scripts/install-skill.sh /path/to/project --skill commit-messages --force
```

安装到用户目录时，优先复制而不是软链接：

```bash
./scripts/copy-skill.sh "$HOME"
./scripts/copy-skill.sh "$HOME" --skill commit-messages
./scripts/copy-skill.sh "$HOME" --skill commit-messages --force
```

脚本应同时支持：

- Codex: `.codex/skills/`
- Claude Code: `.claude/skills/`
- OpenCode: `.opencode/skills/`

## 校验

修改 skill 后运行校验：

```bash
python "${CODEX_HOME:-$HOME/.codex}/skills/.system/skill-creator/scripts/quick_validate.py" ./commit-messages
```

修改安装脚本后至少运行：

```bash
bash -n scripts/install-skill.sh
bash -n scripts/copy-skill.sh
scripts/install-skill.sh --help
scripts/copy-skill.sh --help
```

## 提交

提交本仓库改动时使用 `commit-messages` skill：

- 默认使用中文提交信息。
- 若最近提交历史全英文，或仓库明确要求英文提交信息，则使用英文。
- 使用带 gitmoji 的 Conventional Commits 风格，例如 `🎉 init: 初始化项目结构`。
- 提交前检查 `git status --short`、已暂存 diff 和相关未暂存 diff。
