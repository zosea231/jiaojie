---
name: jiaojie
description: "Initialize or update human-orchestrated project handoffs, maintain concise .ai context and a content index, and separate planning, implementation, and review. Defaults to Codex Astra/Sol sessions, with optional Claude Code, Workbuddy, and asset agents. Use for jiaojie, 交接, or syncing project progress."
---

# Jiaojie

Build a project that a new agent can quickly understand and continue. The defaults are Codex Astra for planning and independent review, and Codex Sol for implementation and fixes. These are roles the human selects, not automatic model switching or delegation. Claude Code and Workbuddy are optional participants.

## Core defaults

- **Codex readability and modular design:** keep stable entrypoints, clear file responsibilities, explicit dependencies, and a concise content index. Split mixed responsibilities as the active work reaches them, control complexity, and introduce no circular dependencies. Keep architecture maintenance bounded by the task.
- **Current context:** keep the goal, core route, current stage, effective decisions, unresolved work, and evidence entrypoints in `.ai/`. Update facts in place; remove stale, duplicated, or route-divergent records. Detailed evidence stays in its source directory.
- **Direct writing:** apply [references/writing-rules.md](references/writing-rules.md) to documentation, reports, comments, and delivery packaging. It integrates the bundled [Anti-Defensive Writing skill](references/anti-defensive-writing.md), including its evidence and precision requirements. Read the bundled text when drafting or revising prose; no separate installation or network request is needed.
- **Proportionate safeguards:** 默认不新增 hash、不冻结 contract、不建 baseline、不加 gate。只有说清具体失败场景，并解释为什么 Git、版本号、主键、事务、唯一约束、类型、普通测试全都挡不住它，才允许增加。已有安全措施一个不删；认证、数据安全、不可逆操作和正式发布继续按项目要求处理。

## Initialize or update a project

For a new project, run:

```bash
bash /path/to/jiaojie/scripts/init_workflow.sh /path/to/project
```

The target defaults to the current directory. The script creates missing files and preserves existing ones. Add `--with-claude` only when Claude Code participates; its optional `CLAUDE.md` points to the shared `AGENTS.md` rules. Configure `scripts/check.sh` for the actual project toolchain before development.

For an existing project, or when the user asks to apply the latest skill rules, read [references/update-rules.md](references/update-rules.md) and merge the defaults into the project's current rules and documents. Running the initializer alone only fills missing files. Updating the installed skill alone does not update existing projects. Preserve project-specific instructions, user work, effective decisions, and existing safeguards; do not replace current `.ai/` content with templates.

## Read and maintain context

At each task start read `.ai/brief.md` → `.ai/plan.md` → `.ai/review.md` → `.ai/backlog.md` → `.ai/decision-log.md` → `.ai/roster.md` → `.ai/index.md`. Read `.ai/asset-manifest.md` when assets are involved. The latest user instruction takes precedence; otherwise current files take precedence over conversation memory.

Update affected status, decisions, and index entries during development. When the user asks to sync, or a stage finishes, follow [references/sync-rules.md](references/sync-rules.md), report the state, and stop for the human to choose the next role. Apply the writing rules to these records too.

## Human-orchestrated workflow

The human selects the current session and role. The roster records capabilities and file access. It does not schedule work. Do not introduce a collaboration lock or synchronization hook.

### Stage 1 — Planner: plan and choose the route

Astra, or the assigned planner, reads project evidence and writes an implementable `.ai/plan.md`: core route, current scope, module boundaries, acceptance criteria, and next action. It synchronizes effective decisions and stops without implementing product code.

### Stage 2 — Implementer: implement and check

Sol, or the assigned implementer, reads the plan, implements the authorized scope, and runs `./scripts/check.sh`. Record out-of-scope findings in the backlog and significant rationale in the decision log. Synchronize state as implemented, pending review, then stop. An author's checks are not an independent review.

### Stage 3 — Reviewer: review independently

Astra, or another assigned reviewer, reviews the actual changes against the goal and plan, checks the validation evidence, and records actionable P0/P1/P2 findings in `.ai/review.md`. The human can then switch to a bounded fix turn or authorize merge. Do not switch roles automatically.

### Three-strike circuit breaker

After three consecutive check failures with the same root cause, stop editing and rerunning. Mark the task blocked in `.ai/plan.md` (also `.ai/review.md` during review fixes), record the command, error signature, attempted fixes, and the missing decision. Reset the count only when the check advances or evidence identifies a different root cause.

Validation uses the existing `scripts/check.sh` entrypoint. Add meaningful missing acceptance checks under `scripts/checks/<name>.sh`; preserve existing checks. Do not build tests or gates for document wording, synchronization, or repeated proof of an unchanged result.

## Other participants and outputs

Register participants actually in use. Workbuddy reads `AGENTS.md`, current handoff documents, and `.ai/index.md`; it stores reports, Q&A notes, and supporting material under `out/workbuddy/<topic>/` unless the project index names an existing destination. Other reports use `out/reports/`, presentations `out/presentations/`, generated image/video assets `assets/generated/`, and source references `references/`. Create directories when needed, and index useful results by purpose, path, source, and adoption state.

An agent without file access receives a self-contained prompt with context, destination, and acceptance criteria. A file-capable agent records the returned output and updates the index. Generated image/video records retain full prompts beside the assets; `.ai/asset-manifest.md` links to them and records checks and acceptance. Keep adverse evidence that still affects the current route.

See [references/rules.md](references/rules.md) for rationale and [assets/ai-templates/prompts-examples.md](assets/ai-templates/prompts-examples.md) for role prompts.
