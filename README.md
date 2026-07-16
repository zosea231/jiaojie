# Agent Workplace Init

[![Agent Skills](https://img.shields.io/badge/Agent%20Skills-agent--workplace--init-blueviolet)](skills/agent-workplace-init/SKILL.md)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

一个 SKILL.md 格式的 Agent Skill：一键在任意项目里搭建 **Codex + Claude
Code 双 Agent 协作工作流**——生成 `AGENTS.md` / `CLAUDE.md` /
`scripts/check.sh` / `.ai/` 交接文档结构，内置五条严格协作规则（单点写入、
文档驱动交接、单角色单轮、统一检查入口、三次同因失败熔断）以及双 agent 都要遵守的行动原则
（直接给建议不列菜单、最简方案、结论要有实证、只在必要时暂停、结论先行）。

同一份 SKILL.md 在 [Claude Code](https://code.claude.com/docs/en/skills) 和
Codex CLI 里都能原生识别和触发，不需要转换格式——你平时用 Codex 调用它，
或者用 Claude Code 调用它，效果完全一致。

```
project/
├── AGENTS.md            # 给 Codex 读
├── CLAUDE.md             # 给 Claude Code 读
├── scripts/
│   └── check.sh          # 统一验证入口
├── .ai/
│   ├── brief.md           # 当前任务说明
│   ├── plan.md            # 设计方案
│   ├── review.md          # 审查意见（P0/P1/P2）
│   ├── backlog.md         # 额外发现的问题
│   ├── decision-log.md    # 决策记录
│   └── prompts-examples.md
```

## 协作架构

```mermaid
flowchart LR
    H["Human<br/>定义任务、分配写入权、最终合并"]
    S[(".ai/ 五件套<br/>跨会话事实源")]
    C["Claude Code<br/>方案分析 / 独立审查"]
    X["Codex<br/>最小实现 / P0-P1 修复"]
    V["scripts/check.sh<br/>唯一验证入口"]
    B["三次同因失败<br/>标记阻塞并交还人类"]

    H -->|brief + 本轮角色| S
    S --> C
    S --> X
    C -->|plan / review| S
    X -->|实现状态 / 决策| S
    X --> V
    V -->|通过| C
    V -->|连续三次同一根因| B
    B --> H
    C -->|审查通过| H
```

`.ai/` 是共享状态，不是共享写入权：任一时刻仍然只有一个 Agent 可以改文件。
典型闭环是 **分析 → 实现 → 统一检查 → 独立审查 → 定向修复 → 人工合并**。

## 一行安装

在终端运行，或让 Agent 执行下面这条命令。它会安装到共享目录，并连接到
Codex 和 Claude Code：

```bash
npx skills add zosea231/agent-workplace-init --skill agent-workplace-init --agent codex claude-code -g -y
```

安装完成后，重启对应 Agent 或新开一个会话，然后直接说：

```text
为当前项目初始化 Codex + Claude Code 单写入协作工作区。
```

## 使用

安装好之后，直接在对话里说明意图即可，不需要记住任何命令，例如：

> "帮我在这个项目里搭建 Codex + Claude Code 的双 agent 协作工作流"
> "给这个仓库初始化 AGENTS.md / CLAUDE.md 和 .ai 目录"
> "我想让两个 agent 协作开发但不要互相踩踏，怎么设置"

Codex / Claude Code 可以根据这个意图调用 Skill，并用内置脚本完成搭建。已有
文件不会被覆盖，可以在老项目上重复运行来补齐缺失文件。

## 目录结构（本仓库自身）

```
agent-workplace-init/
├── .ai/                        # 本仓库自身的任务状态与交接记录
├── .gitattributes              # 固定脚本与文档的跨平台换行规则
├── .gitignore                  # 排除生成 ZIP 和本地临时文件
├── AGENTS.md                   # Codex 在本仓库内的协作规则
├── CLAUDE.md                   # Claude Code 在本仓库内的协作规则
├── LICENSE
├── README.md
├── scripts/
│   └── check.sh                # 本仓库自己的唯一验证入口
└── skills/
    └── agent-workplace-init/   # 可安装的 Skill 包
        ├── SKILL.md
        ├── agents/
        │   └── openai.yaml     # Codex 展示元数据与默认提示词
        ├── assets/             # 只包含会写入目标项目的模板
        │   ├── AGENTS.md
        │   ├── CLAUDE.md
        │   ├── scripts/
        │   │   └── check.sh
        │   └── ai-templates/
        │       ├── brief.md
        │       ├── plan.md
        │       ├── review.md
        │       ├── backlog.md
        │       ├── decision-log.md
        │       └── prompts-examples.md
        ├── references/
        │   └── rules.md        # 协作规则的设计依据与边界说明
        └── scripts/
            └── init_workflow.sh
```

根目录的 `AGENTS.md`、`CLAUDE.md` 和 `.ai/` 是本仓库使用自身 Skill 的
工作副本；`skills/agent-workplace-init/assets/` 中的同名文件才是安装到目标
项目的模板源。两层文件用途不同，`scripts/check.sh` 会校验它们保持同步，并
要求提交到仓库的 `.ai/` 文件恢复为干净的初始模板。

## License

MIT
