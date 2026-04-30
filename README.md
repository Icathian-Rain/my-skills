# My Skills

这是一个用于存放个人 agent skills 的仓库。每个 skill 都独立放在一个顶层目录中，便于维护、同步和按项目安装。

## 目录结构

```text
.
├── commit-messages/
│   ├── SKILL.md
│   └── agents/
│       └── openai.yaml
├── scripts/
│   ├── copy-skill.sh
│   └── install-skill.sh
├── .gitignore
└── AGENTS.md
```

- `commit-messages/`：skill 源目录，所有实际内容都在这里维护。
- `scripts/install-skill.sh`：把本仓库的 skill 软链接安装到指定项目。
- `scripts/copy-skill.sh`：把本仓库的 skill 复制安装到用户目录。
- `AGENTS.md`：给编码 agent 的仓库维护约定。
- `.gitignore`：忽略本地安装目录，避免提交机器相关路径。

本仓库不会跟踪 `.codex/`、`.claude/`、`.opencode/` 或 `.code/`。这些目录只作为本地安装产物存在。

## 已有 Skills

### `commit-messages`

规范 agent 生成 git commit message 的方式。

主要约定：

- 提交前先检查 `git status` 和 diff。
- 只提交当前任务相关改动。
- 默认使用中文；若仓库最近提交历史全英文，或仓库明确要求英文提交信息，则使用英文。
- 使用带 gitmoji 的 Conventional Commits 风格，例如：

```text
🎉 init: 初始化项目结构
✨ feat(auth): 添加登录流程
🐛 fix(api): 处理空搜索条件
```

## 安装到项目

推荐使用软链接安装，这样可以在本仓库集中维护 skill，并让目标项目同步使用最新内容。安装脚本同时支持 Codex、Claude Code 和 OpenCode。

在本仓库根目录执行，将 `/path/to/project` 替换成目标项目路径：

```bash
./scripts/install-skill.sh /path/to/project
```

默认会把所有顶层 skill 安装到三个目录：

```text
.codex/skills/      # Codex
.claude/skills/     # Claude Code
.opencode/skills/   # OpenCode
```

这些项目级安装目录会被 `.gitignore` 忽略，不应提交到仓库。

只安装某个 skill：

```bash
./scripts/install-skill.sh /path/to/project --skill commit-messages
```

只安装到指定工具：

```bash
./scripts/install-skill.sh /path/to/project --tools codex,opencode
```

如果目标位置已经存在指向其他位置的软链接，可以显式替换：

```bash
./scripts/install-skill.sh /path/to/project --skill commit-messages --force
```

## 安装到用户目录

如果希望某个 skill 对当前用户的所有项目默认可用，建议使用复制安装脚本。复制安装不会依赖本仓库路径，也不会让开发中的未提交改动立刻影响全局 skill。

```bash
./scripts/copy-skill.sh "$HOME"
```

这会把所有顶层 skill 安装到当前用户目录下的三个位置：

```text
~/.codex/skills/      # Codex
~/.claude/skills/     # Claude Code
~/.opencode/skills/   # OpenCode
```

只安装某个 skill 到用户目录：

```bash
./scripts/copy-skill.sh "$HOME" --skill commit-messages
```

只安装到指定工具的用户目录：

```bash
./scripts/copy-skill.sh "$HOME" --tools codex,claudecode
```

如果需要刷新用户目录中已有的副本，使用 `--force` 显式替换：

```bash
./scripts/copy-skill.sh "$HOME" --skill commit-messages --force
```

## 新增 Skill

新增 skill 时，建议遵循以下结构：

```text
skill-name/
├── SKILL.md
└── agents/
    └── openai.yaml
```

`SKILL.md` 应包含：

- YAML frontmatter：至少包含 `name` 和 `description`。
- 简洁的使用说明：只写 agent 执行任务真正需要知道的内容。
- 必要的流程、约束和示例。

`agents/openai.yaml` 用于 UI 展示信息，例如：

```yaml
interface:
  display_name: "提交信息规范"
  short_description: "规范 agent 的 git commit message"
  default_prompt: "使用 $commit-messages 为已暂存改动生成带 gitmoji 的规范提交信息。"
```

## 校验

创建或修改 skill 后，可以运行校验脚本：

```bash
python "${CODEX_HOME:-$HOME/.codex}/skills/.system/skill-creator/scripts/quick_validate.py" ./commit-messages
```

校验通过时会输出：

```text
Skill is valid!
```
