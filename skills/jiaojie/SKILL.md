---
name: jiaojie
description: "Initialize or update small or multi-workflow project architectures with concise agent handoffs, task dependencies, and optional Git worktrees. Defaults to human-directed Codex Astra/Sol roles, with optional Claude Code and Workbuddy. Use for jiaojie, 交接, syncing project progress, or project-agent architecture."
---

# Jiaojie

Build a project that a new agent can quickly understand and continue. The defaults are Codex Astra for planning and independent review, and Codex Sol for implementation and fixes. These are roles the human selects, not automatic model switching or delegation. Claude Code and Workbuddy are optional participants.

## Choose a project mode

Choose based on independent workflows and cross-workflow dependencies, not repository size or agent count. Use **small** when one shared brief, plan, and index are enough; it remains the default and preserves the existing scaffold. Use **large** when several durable workflows need separate detailed context, a short global status, dependency navigation, or occasional parallel branches/worktrees. Read [references/project-architecture.md](references/project-architecture.md) only for large projects or an upgrade. Multiple agents working on one tightly coupled task do not by themselves require large mode.

## Core defaults

- **Codex readability and modular design:** keep stable entrypoints, clear file responsibilities, explicit dependencies, and a concise content index. Split mixed responsibilities as the active work reaches them, control complexity, and introduce no circular dependencies. Keep architecture maintenance bounded by the task.
- **Task context and dependencies:** keep a short shared goal and route, then use `.ai/index.md` to load the current task's inputs and module evidence. Keep dependencies, outputs, acceptance, and next actions in the relevant task plan; link to source material instead of duplicating it.
- **Current context:** keep the goal, core route, current stage, effective decisions, unresolved work, and evidence entrypoints in `.ai/`. Update facts in place; remove stale, duplicated, or route-divergent records. Detailed evidence stays in its source directory.
- **Direct writing:** apply [references/writing-rules.md](references/writing-rules.md) to documentation, reports, comments, and delivery packaging. It integrates the bundled [Anti-Defensive Writing skill](references/anti-defensive-writing.md), including its evidence and precision requirements. Read the bundled text when drafting or revising prose; no separate installation or network request is needed.
- **Proportionate safeguards:** 默认不新增 hash、不冻结 contract、不建 baseline、不加 gate。只有说清具体失败场景，并解释为什么 Git、版本号、主键、事务、唯一约束、类型、普通测试全都挡不住它，才允许增加。已有安全措施一个不删；认证、数据安全、不可逆操作和正式发布继续按项目要求处理。

## Initialize or update a project

For a new project, run:

```bash
bash /path/to/jiaojie/scripts/init_workflow.sh /path/to/project
```

For a new multi-workflow project, initialize its shared skeleton and named workflow documents:

```bash
bash /path/to/jiaojie/scripts/init_workflow.sh /path/to/project --mode large \
  --workflow data-generation --workflow prediction
```

The default `--mode small` keeps the current lightweight files. `--mode large` creates global `.ai/brief.md`, `plan.md`, `index.md`, local `.ai/workflows/<name>/{brief,plan}.md`, a `projects/` code area, and the architecture reference. It preserves existing files; for an existing project, read [references/update-rules.md](references/update-rules.md) and semantically merge missing links and rules. The initializer does not move code or data, change Git history, or create branches/worktrees. In large mode the agent and human decide whether worktrees help, then follow the architecture reference.

The target defaults to the current directory. The script creates missing files and preserves existing ones. Add `--with-claude` only when Claude Code participates; its optional `CLAUDE.md` points to the shared `AGENTS.md` rules. Configure `scripts/check.sh` for the actual project toolchain before development.

For an existing project, or when the user asks to apply the latest skill rules, read [references/update-rules.md](references/update-rules.md) and merge the defaults into the project's current rules and documents. Running the initializer alone only fills missing files. Updating the installed skill alone does not update existing projects. Preserve project-specific instructions, user work, effective decisions, and existing safeguards; do not replace current `.ai/` content with templates.

## Read and maintain context

At each task start follow `AGENTS.md`, then read `.ai/brief.md`, the overview and current task in `.ai/plan.md`, and relevant entries in `.ai/index.md`. In large mode, also read the assigned `.ai/workflows/<workflow>/{brief,plan}.md`; global plan rows stay concise and local plans hold details. Keep shared files short and use stable workflow names and index links instead of loading every handoff file in full. The latest user instruction takes precedence; otherwise current files take precedence over conversation memory.

Expand context by role and scope: read relevant review findings for implementation, review, or fixes; effective decisions for affected modules or route choices; backlog entries when they affect scope or are requested; the roster when roles or access matter; and the asset manifest when assets are involved. Read module entrypoints and original evidence needed for the task. Reviewers inspect actual changes and source evidence; Workbuddy uses adopted results and supporting sources. If routing is incomplete, inspect headings and directories, then expand the relevant reading.

For each real task, record its goal/scope, linked inputs, prerequisites where present, output destination, implementation/review roles, acceptance evidence, status, and next action in the task plan: root `.ai/plan.md` for small mode, local workflow plan for large mode. A small task can use one short section. Link related tasks by stable name; keep detailed module context beside the module or in existing references. When upstream inputs, interfaces, or conclusions change, identify affected downstream work and mark the relevant results for reassessment, with reasons. Keep task status in the plan and source records; the index is navigation. See [references/sync-rules.md](references/sync-rules.md) for maintenance.

Update affected status, decisions, and index entries during development. When the user asks to sync, or a stage finishes, follow [references/sync-rules.md](references/sync-rules.md), report the state, and stop for the human to choose the next role. Apply the writing rules to these records too.

## Human-orchestrated workflow

The human selects the current session and role. The roster records capabilities and file access. It does not schedule work. Do not introduce a collaboration lock or synchronization hook.

### Stage 1 — Planner: plan and choose the route

Astra, or the assigned planner, reads project evidence and writes an implementable task plan: a short shared overview and task details with inputs, dependencies, outputs, module boundaries, acceptance, and next action. In large mode details go in the workflow plan. It synchronizes effective decisions and stops without implementing product code.

### Stage 2 — Implementer: implement and check

Sol, or the assigned implementer, reads the current task and its linked inputs, implements the authorized scope, and runs `./scripts/check.sh`. Record affected downstream work in the plan, out-of-scope findings in the backlog, and significant rationale in the decision log. Synchronize state as implemented, pending review, then stop. An author's checks are not an independent review.

### Stage 3 — Reviewer: review independently

Astra, or another assigned reviewer, reviews the actual changes against the goal and plan, checks the validation evidence, and records actionable P0/P1/P2 findings in `.ai/review.md` or the relevant workflow's review record. The human can then switch to a bounded fix turn or authorize merge. Do not switch roles automatically.

### Three-strike circuit breaker

After three consecutive check failures with the same root cause, stop editing and rerunning. Mark the task blocked in the task plan (also its review record during review fixes), record the command, error signature, attempted fixes, and the missing decision. Reset the count only when the check advances or evidence identifies a different root cause.

Validation uses the existing `scripts/check.sh` entrypoint. Add meaningful missing acceptance checks under `scripts/checks/<name>.sh`; preserve existing checks. Do not build tests or gates for document wording, synchronization, or repeated proof of an unchanged result.

## Other participants and outputs

Register participants actually in use. Workbuddy follows the shared context entrypoints, then reads the requested topic's adopted results and source evidence through `.ai/index.md`; it stores reports, Q&A notes, and supporting material under `out/workbuddy/<topic>/` unless the project index names an existing destination. Other reports use `out/reports/`, presentations `out/presentations/`, generated image/video assets `assets/generated/`, and source references `references/`. Create directories when needed, and index useful results by purpose, path, source, and adoption state.

Those are small-mode defaults. New large projects use `artifacts/{reports,presentations,workbuddy,generated}/` for outputs and `projects/` for code/tools; existing projects keep their indexed destinations. Large mode creates auxiliary review/decision/roster/asset records only when useful, at the global or local scope they affect.

An agent without file access receives a self-contained prompt with context, destination, and acceptance criteria. A file-capable agent records the returned output and updates the index. Generated image/video records retain full prompts beside the assets; `.ai/asset-manifest.md` links to them and records checks and acceptance. Keep adverse evidence that still affects the current route.

See [references/rules.md](references/rules.md) for rationale and [assets/ai-templates/prompts-examples.md](assets/ai-templates/prompts-examples.md) for role prompts.
