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
│   └── install-skill.sh
└── .codex/
    └── skills/
        └── commit-messages -> ../../commit-messages
```

- `commit-messages/`：skill 源目录，所有实际内容都在这里维护。
- `scripts/install-skill.sh`：把本仓库的 skill 软链接安装到指定项目。
- `.codex/skills/`：Codex 的项目级 skill 安装目录。
- `.codex/skills/commit-messages`：指向源目录的软链接，修改源目录后会自动生效。

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
