# My Skills

这是一个用于存放个人 agent skills 的仓库。每个 skill 都独立放在一个顶层目录中，便于维护、同步和按项目安装。

## 目录结构

```text
.
├── commit-messages/
│   ├── SKILL.md
│   └── agents/
│       └── openai.yaml
├── leetcode-weekly-coach/
│   ├── SKILL.md
│   ├── agents/
│   │   └── openai.yaml
│   └── references/
│       ├── output-templates.md
│       ├── review-rubric.md
│       └── topic-ladders.md
├── scripts/
│   ├── copy-skill.sh
│   └── install-skill.sh
├── .gitignore
└── AGENTS.md
```

- `commit-messages/`：skill 源目录，所有实际内容都在这里维护。
- `leetcode-weekly-coach/`：生成 LeetCode 周计划、总结当天完成题目并更新周计划，以及输出单题点评。
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

### `leetcode-weekly-coach`

规划、跟进并点评按主题分周的 LeetCode 训练，适合用于生成周计划、总结当天完成题目并更新周计划，以及对特定题目生成中文点评。

主要能力：

- 生成按主题组织的 LeetCode 周计划，安排每日题单、训练目标和难度梯度。
- 总结当天完成的题目，记录完成质量、复盘重点和下一步安排，并同步更新周计划进度。
- 对特定题目生成点评，分析用户解法、复杂度、边界风险和改进方向，并给出推荐最优解与 C++20 `class Solution` 代码。
- 在总结当天题目时，可同步对每道已完成题目生成独立点评，并在周计划中引用对应点评文档。
- 读取 `references/topic-ladders.md`、`references/output-templates.md` 和 `references/review-rubric.md`，保持题单选择、计划更新和点评格式稳定；必要时联网校准题目信息。

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
./scripts/install-skill.sh /path/to/project --skill leetcode-weekly-coach
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
./scripts/copy-skill.sh "$HOME" --skill leetcode-weekly-coach
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
python "${CODEX_HOME:-$HOME/.codex}/skills/.system/skill-creator/scripts/quick_validate.py" ./leetcode-weekly-coach
```

校验通过时会输出：

```text
Skill is valid!
```
