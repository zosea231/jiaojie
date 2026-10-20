# 两种项目架构与渐进升级

## 选择方式

| 模式 | 适用情况 | 文档组织 |
|---|---|---|
| small（默认） | 一个共同计划能清楚表达当前工作，各任务上下文紧密相关 | 根 brief／plan／index 加现有审查、决策等记录 |
| large | 多个长期工作流有各自的输入、实现与验收，频繁需要读取其他任务结果 | 根三份概览加 `.ai/workflows/<workflow>/{brief,plan}.md` |

Agent 先查看目标、目录和当前工作，给出模式与依据后实施用户授权的初始化。多 agent、文件多或代码多不自动要求升级；按需并行也不要求每个任务都建立 worktree。

## 大型项目的目录与文档职责

```text
project/
  AGENTS.md
  .ai/
    brief.md                 # 共同目标、路线与约束
    plan.md                  # 每条 workflow 的简短结果、下一步和依赖
    index.md                 # 局部文档、代码、证据、分支及外部位置导航
    workflows/<workflow>/
      brief.md               # 本任务目标、边界、输入与输出
      plan.md                # 当前状态、实施计划、验收和下一步
  projects/<project>/        # 按稳定职责组织源码与开发工具
  artifacts/<topic>/         # 采用稿、可编辑文件与证据，按需创建
  references/                # 资料原文、来源与许可证
  scripts/check.sh           # 根验证入口，调用实际子项目检查
  worktrees/<workflow>/      # 按需创建的完整 checkout，本机忽略
```

workflow 表达持续任务，project 表达代码职责，两者可以多对多。按用途命名；复现和备用实现放相关项目的 `repro/` 或 `reference-implementations/`，写作工具放专门的 project，产物放 artifacts。已有有效目录沿用，跨平台路径相对当前 checkout 根目录。

全局只保留影响所有任务的规则与概览，局部计划是详细状态的来源。根 AGENTS.md 规定读取和协作方式，子目录规则补充技术约束。审查、决策、backlog、名册、资产记录只在有实际内容时新增；大型模式可放根或局部，依据影响范围选择一个位置并由 index 链接，避免两份正文。

有本机大数据、环境或服务器时，index 记录用途、位置／连接别名、对应代码目录、读取方式与最后核对时间或部署版本；不写密钥。数据保持原位，worktree 显式引用。Git 只备份已跟踪内容，外置数据的备份策略另行记录。

## 按依赖读取和同步

1. 开始：根 AGENTS → 根 brief／plan 概览／index → 当前 workflow brief／plan → 本轮需要的代码与证据。相关 workflow 只在输入、接口或结论影响当前任务时展开。
2. 推进：局部 plan 原位更新当前结果、证据和下一步；全局 plan 每条 workflow 保留一句结果及下一步／真实依赖。index 只导航。可交付步骤、阻塞或跨任务输入变化时同步概览，无需每个工具调用后写文档。
3. 依赖：以工作流和资产作为节点、以真实输入输出作为边组织可读取的任务依赖图。局部计划链接上游任务、具体所需结果、接受条件和下游用途；上游实际变化时指出需复核的下游结果与原因。仅在关系难以阅读时画简短 Mermaid 图，不维护另一份状态表或图数据库。
4. 交接：记录当前分支、提交、验证与证据入口；作者检查与独立审查分别记录，用户选择下一角色。用户安排并行时，各 agent 使用独立 checkout 和分支，推进分配给自己的 workflow。

稳定入口、短概览、按任务补读能减少重复输入；具体 token 和缓存收益取决于调用环境。保持结构与有效正文稳定，局部更新，不每轮改名或重排文件；不复制全局规则到每个局部 brief。

## Git 与 worktree 的构建

以一个 Git 仓库维护代码和交接；先查看已有仓库、分支、worktree 及未提交改动。新项目在确认忽略数据、环境、密钥后正常初始化并创建首个提交；初始化脚本只提供文档，不自动提交或发布。

实际并行且有改动隔离需要时，在主 checkout 根目录执行，例如：

```bash
git rev-parse --show-toplevel
git status --short
git worktree list
# 已有首个提交；把 /worktrees/ 合并到根 .gitignore 后创建。
git worktree add -b codex/data-generation worktrees/data-generation HEAD
# 若分支已经存在，用以下命令替代上一条，不能同时执行：
# git worktree add worktrees/data-generation codex/data-generation
```

`git worktree add ... HEAD` 从最近提交创建 checkout，不包含主目录的未提交改动。先查看 `git status --short`；需要带入的改动留在原工作区或按项目规则提交后再创建，不要假设 worktree 自动复制。分支默认 `codex/<workflow>`，用户指定的名称优先。路径已存在、分支已在别处 checkout 时，核对并复用合适工作区，不覆盖、强制切换或删除已有工作。worktree 是整个仓库的 checkout，不是单个 project 的副本，也不是实时共享目录。进入后从该 checkout 根读取规范文档和执行检查。将实际分支和路径登记在 index；不因每个 agent 或每轮对话新建分支。

各 worktree 中的 `.ai` 随分支保存。另一分支尚未合并的进度用以下方式查看：

```bash
MSYS_NO_PATHCONV=1 git show codex/data-generation:.ai/workflows/data-generation/plan.md
# 跨机器读取已推送进度时：
git fetch origin
MSYS_NO_PATHCONV=1 git show origin/codex/data-generation:.ai/workflows/data-generation/plan.md
```

`MSYS_NO_PATHCONV=1` 防止 Windows Git Bash 改写 `branch:path` 参数；其他 Bash 环境可原样使用，PowerShell 中直接执行 `git show`。

未提交内容只在对应 worktree 可见；上述命令读的是分支最新提交，尚未 fetch 的远端引用也可能过期。交付节点提交当前 workflow 的文档及相关实现；在用户授权远端同步时推送。合入主分支时核对局部状态并同步全局概览，重读共享文件、保留其他任务条目，按普通 Git 方式解决冲突。主分支未合并的概览不能作为所有任务的实时状态。清理 worktree 前确认改动和提交已保留，不使用强制删除来收尾。

## 小型项目的适配与升级

小型模式保留当前轻量模板与技术栈原生布局：根 AGENTS、brief／plan／index 入口稳定；plan 用稳定任务名表达输入、输出与依赖；index 登记模块、产物和外部数据位置。有新模块时按职责放置，不预建空的 projects、artifacts 或 worktrees。

升级分两步，先文档后路径：

1. 查看实际独立工作流，运行 `init_workflow.sh <project> --mode large --workflow <name> ...` 补齐局部文件和架构说明。脚本保留已有 AGENTS、全局文档、检查及 `.gitignore`，不会自动把旧任务内容搬进新局部模板。
2. Agent 将对应任务的目标、有效决策、待办、验收和证据入口语义整理到局部 brief／plan，根 plan 压缩为状态行，根 index 补齐导航并明确 large 模式。合并根规则和 `/worktrees/` 忽略项；已有 out、src、数据、环境、历史和服务器部署保持有效。新工作从局部入口接手，旧入口保留指向。

文档升级通常不需要停止其他 loop；提前说明变动，仅在交接节点切换读取入口。代码路径重组独立评估调用、脚本、环境和运行进程，列出映射、验证与恢复方式后执行；存在运行中的求解或服务时保持其文件和路径。已有 Git 历史直接保留。通过当前项目的 `scripts/check.sh` 验证实际受影响的行为，再按需要逐步引入 worktree。
