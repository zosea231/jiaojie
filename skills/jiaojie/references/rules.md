# Agent Collaboration Rules — Rationale

This reference explains the five rules in `SKILL.md`. Read it when the
user asks why the workflow is structured this way or when an edge case is
not covered by the scaffolded AGENTS.md / CLAUDE.md.

## 1. Human-orchestrated handoff, not locking

Only one agent works at a time because the human interacts with one agent at
a time and decides when to switch. There is no concurrent-write scenario to
mediate, so Jiaojie does not create a lock file, lock command, hook, or write-owner
field. `.ai/roster.md` is only a participant and capability registry.

At the start of each task, the selected agent reads the current handoff files
from disk. At the natural end of a stage, it synchronizes conclusions and
status, tells the human what changed, and stops. The human then switches to
the next agent. Conversation handoff alone is insufficient because the next
agent may start with zero conversation context.

Synchronization is a documentation behavior, not a security boundary. Do
not add a hook or validation script for it.

## 2. Documentation over conversation memory

The durable collaboration state lives in these files:

| File | Purpose |
|---|---|
| `.ai/brief.md` | Current task goal |
| `.ai/plan.md` | Design, implementation plan, and current stage |
| `.ai/review.md` | Review findings split by P0/P1/P2 |
| `.ai/backlog.md` | Out-of-scope issues, appended rather than overwritten |
| `.ai/decision-log.md` | Non-obvious rationale, appended rather than rewritten |
| `.ai/roster.md` | Participating agents, capabilities, file access, and status |
| `.ai/asset-manifest.md` | Generated-asset prompts, paths, checks, and acceptance |

At the start of every task, file-capable agents read the first five files in
that order, then `roster.md`, and `asset-manifest.md` when assets are
involved. If conversation memory conflicts with the files, the files win.

When the human explicitly requests a sync with natural language such as
"同步进度到交接文档" or "sync progress to the handoff docs", immediately
follow `references/sync-rules.md`. A natural stage completion is also an
appropriate sync point. Route facts to their proper files; do not turn one
file into a conversation transcript.

An agent with `File access: no` cannot read or update the repository. Give
it one self-contained prompt, then let the human switch to a file-capable
agent to record the returned result.

## 3. One role per turn

Each invocation performs exactly one role:

- "只做架构分析，不要修改产品代码" — plan only.
- "只根据 .ai/review.md 修复 P0/P1，不要处理 P2" — bounded fix only.
- "只实现 .ai/plan.md 中的最小修改建议，不要重构无关代码" — implementation
  only.

This prevents scope creep and preserves independent review. Put findings
outside the current role in `.ai/backlog.md`; do not silently fix them.

## 4. One fixed check entrypoint

`./scripts/check.sh` is the only validation command file-capable agents run
after edits. This gives every agent and the human directly comparable
results and closes the change → check → fix loop.

规划或审查阶段确定验收标准时，若 `check.sh` 尚未覆盖对应检查，追加一段
条件化的检查（复用 `scripts/checks/<name>.sh` 的按需 dispatch 模式，不要
写进总是执行的主流程），并在 `.ai/decision-log.md` 记一行原因；若已覆盖，
不要重新评估或重写现有内容。

Generated assets use the same entrypoint for optional mechanical checks. If
`scripts/checks/assets.sh` exists, `check.sh` runs it to verify existence,
decodability, dimensions, or duration. Subjective content acceptance belongs in
`.ai/asset-manifest.md`. The check script must not inspect or enforce
handoff synchronization.

## 5. Three-strike circuit breaker

Count consecutive failures by root cause, not exact log text:

1. Diagnose the first failure and make the smallest in-scope fix.
2. On the second failure with the same root cause, re-check the evidence and
   try at most one materially different in-scope fix.
3. On the third, stop editing and checking. Mark the task blocked in
   `.ai/plan.md`; also mark `.ai/review.md` when this is a review-fix pass.
   Record the command, stable error signature, attempted fixes, and the input
   or authority needed from the human.

Reset the count only after the check advances or evidence identifies a
different root cause.

## Typical end-to-end workflow

```text
1. Claude Code: read .ai/ → write plan → sync handoff docs → stop
2. Human:       switch to Codex
3. Codex:       read .ai/ → implement → run check.sh → sync → stop
4. Human:       switch to Claude Code
5. Claude Code: read .ai/ → review diff → write P0/P1/P2 → sync → stop
6. Human:       switch to Codex for a bounded P0/P1 fix, or merge
```

Any file-capable agent can review, including Codex's dedicated review mode.
The important boundary is that the implementation turn does not pretend to
be an independent review and that findings are persisted in
`.ai/review.md`.

For an optional generated-asset task:

```text
planner:    write a self-contained prompt and acceptance criteria → sync → stop
human:      switch to the registered generator
 generator: return the image/video → stop
human:      switch to a file-capable agent
recorder:   place the file and append asset-manifest.md → run check.sh → sync → stop
human:      switch to an independent reviewer
reviewer:   record accepted/rejected and the reason → sync → stop
```

## Operating principles

The scaffolded AGENTS.md and CLAUDE.md share these principles:

1. Act once enough information is available; recommend instead of listing a
   menu of unused options.
2. Make the simplest change that solves the task; avoid unrelated refactors
   and speculative features.
3. Verify every reported conclusion against evidence from the current task.
4. Pause only for destructive actions, a real scope change, or missing input
   only the human can provide.
5. Lead with the conclusion, then provide supporting detail.

## Embedded / low-level constraints (adapt as needed)

The templates include conservative defaults for embedded projects:

- Treat ISR context, DMA ownership, cache coherency, alignment, and volatile
  access carefully.
- Do not add dynamic allocation to low-level drivers without approval.
- Record public protocol changes and their rationale in
  `.ai/decision-log.md`.

Remove or adapt these constraints when they do not fit the target project.
