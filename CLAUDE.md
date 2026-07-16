<!-- Repository self-hosting copy. Installed template: skills/agent-workplace-init/assets/CLAUDE.md -->

# Project Rules (for Claude Code)

## Role
You are working on an embedded/software engineering project.
Prioritize correctness, minimal diffs, and debuggability.

## Operating principles
1. 信息足够时直接行动，不复述已知事实、不列举不会采用的选项；需要权衡时直接给建议，不抛选择题。
2. 用能解决问题的最简方案，不做任务外功能、无关重构或面向未来的过度设计。
3. 汇报前逐条核实结论有本次任务的实证支持；只汇报有证据的部分，失败或未验证的要如实说明。
4. 仅在确有必要时暂停：操作有破坏性、任务范围实质变化、或缺少只有你能提供的信息。
5. 结论先行：第一句话说清"发生了什么"，细节后置。

## Context source of truth
Do NOT rely on conversation memory across sessions — this file is
context, not a substitute for reading current state. At the start of
every task (especially a new session), actively read:
1. `.ai/brief.md`      — what the current task is
2. `.ai/plan.md`       — the design/implementation plan
3. `.ai/review.md`     — outstanding review findings (if any)
4. `.ai/backlog.md`    — known non-blocking issues (do NOT fix unless asked)
5. `.ai/decision-log.md` — why past decisions were made, do not relitigate them
6. `.ai/roster.md`     — participating agents and the current writer
7. `.ai/asset-manifest.md` — generated-asset prompts and acceptance state, when applicable

If prior conversation turns and these files disagree, trust the files.

## Single-writer rule
At most one agent may exercise local write access at a time. The active
assignee is the `Current writer` in `.ai/roster.md`; before editing,
confirm the roster matches the human's instruction for this session.

If the current writer has `file-access: no`, it cannot edit local files.
The previous file-capable writer may be named as its sole write proxy,
limited to delivering a self-contained prompt, placing the returned file
under `assets/generated/`, and recording the result in
`.ai/asset-manifest.md`. The proxy must not change product code or any
other files during that handoff.

This file describes context, not a security policy — if you need a hard,
enforced restriction (e.g. "never touch src/vendor/"), implement it as a
Claude Code hook, not just prose here.

## Role scoping (one role per turn)
Do exactly the role you were asked to do, nothing more:
- "只做架构分析，不要修改文件" → read-only, output to `.ai/plan.md` only.
- "只根据 .ai/review.md 修复 P0/P1，不要处理 P2" → stay in scope; log
  anything else in `.ai/backlog.md` instead of fixing it.
Do not silently expand scope or refactor unrelated code.

## Workflow
Before editing, explain the suspected root cause.
Make the smallest safe change.
Do not refactor unrelated code.
After editing, run `./scripts/check.sh`. This is the ONLY validation
entry point — never guess or invent your own check commands.
If checks fail, fix only the failure introduced by this task.
If the same root-cause failure occurs in three consecutive check runs,
stop editing and re-running checks. Mark the task blocked in
`.ai/plan.md` (and `.ai/review.md` during a review-fix pass), record
the failing command, error signature, and attempted fixes, then hand the
decision to the human. Reset the count only after the check advances or
evidence identifies a different root cause.
Record other issues you notice (but aren't fixing) in `.ai/backlog.md`.
Record non-obvious "why" decisions in `.ai/decision-log.md`.

## Embedded constraints
Be careful with ISR context, DMA ownership, cache coherency, alignment,
and volatile access.
Do not introduce dynamic allocation in low-level drivers unless
explicitly approved.
Do not change public protocol behavior without documenting it in
`.ai/decision-log.md`.

## Handoff
When your task is done and checks pass, update `.ai/plan.md` /
`.ai/review.md` with status, and stop. Do not silently proceed to
the next agent's role (e.g. don't review your own diff as if you
were an independent reviewer — hand off for that instead).

## Note on enforcement
This file shapes behavior but is not a hard boundary. For anything
that must be actually blocked (not just requested), configure it via
`.claude/settings.json` hooks (pre-tool-use / post-tool-use), not just
prose in this file.
