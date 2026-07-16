# Agent Collaboration Rules — Rationale

This is the detailed reference behind the five hard rules mentioned in
`SKILL.md`. Read this when the user wants the "why", not just the
"what", or when you need to resolve an edge case not explicitly
covered by AGENTS.md / CLAUDE.md.

## 1. Single-writer

Only one agent may hold logical write authority at any given time. The
agent is named by `Current writer` in `.ai/roster.md`; the default roster
contains only Codex and Claude Code. This isn't just a politeness
convention — concurrent edits from multiple agents on the same files is
how you get silently-clobbered changes and unreviewable diffs.

- **Codex side**: controlled via approval modes (read / edit / run
  permissions). Default `Auto` mode is a reasonable safe default.
- **Claude Code side**: `CLAUDE.md` is context, not an enforced
  security boundary. If a restriction must actually be enforced (e.g.
  "never write outside `src/`", or "never write while Codex is mid-task"),
  it needs to be implemented as a Claude Code hook
  (pre-tool-use / post-tool-use), not just prose in CLAUDE.md.

Before making any edit, check `.ai/roster.md`, `.ai/plan.md`, and the
human's current instruction. If the assignment changed, record the new
writer in the roster before work starts. If it's ambiguous, ask rather
than assume you have write access.

## 2. Documentation over conversation memory

All collaboration and handoff state must live in `.ai/`, not in
conversation history:

| File | Purpose |
|---|---|
| `.ai/brief.md` | Current task goal |
| `.ai/plan.md` | Design / implementation plan |
| `.ai/review.md` | Review findings, split by priority (P0/P1/P2) |
| `.ai/backlog.md` | Issues noticed but out of scope for this task |
| `.ai/decision-log.md` | Why past decisions were made |
| `.ai/roster.md` | Participating agents, capabilities, file access, status, and current writer |
| `.ai/asset-manifest.md` | Complete prompts, paths, checks, and acceptance state for generated assets |

At the start of *every* task — and especially at the start of a new
session — file-capable agents actively read the original five files in
the documented order, then `roster.md`, and `asset-manifest.md` when the
task involves generated assets. Long conversations and cross-session
work are exactly where key context gets lost or misremembered, which is
how a project quietly drifts off track. If something in this
conversation contradicts what's written in `.ai/`, the files win.

An agent with `file-access: no` is the explicit exception: never tell it
to read `.ai/`. A file-capable agent must translate the relevant context
and acceptance criteria into one self-contained prompt.

## 3. One role per turn

Each invocation of an agent should do exactly one thing:

- "只做架构分析，不要修改文件" (analysis only, no file edits)
- "只根据 .ai/review.md 修复 P0/P1 问题，不要处理 P2" (fix only P0/P1,
  leave P2 alone)
- "只实现 .ai/plan.md 中的最小修改建议，不要重构无关代码" (implement
  only the minimal plan, no unrelated refactors)

This exists specifically to prevent scope creep: an agent noticing
something else wrong and "helpfully" fixing it, or starting to edit
files during what was supposed to be a read-only analysis pass.
Anything noticed outside the current role goes into `.ai/backlog.md`,
not into the diff.

## 4. One fixed check entrypoint

`./scripts/check.sh` is the *only* validation command any file-capable
agent may run — never invent, guess, or substitute a different
lint/test/build command. This matters for two reasons:

- **Consistency**: all agents (and the human) get directly comparable
  feedback, since it's always the same checks.
- **Closes the loop**: this is what turns agent work from "freeform and
  hard to trust" into "change → check → feedback → fix", repeated until
  clean. Claude Code's own best-practice guidance is explicit about
  this: give an agent a runnable way to verify its own work, or it will
  fall back on "looks done to me" as its stopping condition — which is
  a real risk when changes are incomplete or contain hidden bugs.

Generated assets use the same entrypoint but a different kind of check.
When the roster contains a `generate-image` or `generate-video` agent and
`scripts/checks/assets.sh` exists, `check.sh` dispatches to that script
for mechanical checks such as file existence, decodability, dimensions,
or duration. Subjective or semantic acceptance belongs in
`.ai/asset-manifest.md`, not in a shell exit code.

## 5. Three-strike circuit breaker

A check failure is actionable once; the same failure repeating without
new evidence is a loop. Count consecutive failures by root cause, not by
word-for-word log text:

1. On the first failure, diagnose it and make the smallest in-scope fix.
2. On the second consecutive failure with the same root cause, re-check
   the evidence and try at most one materially different in-scope fix.
3. On the third, stop editing and stop re-running the check. Mark the
   current task blocked in `.ai/plan.md`; if the task is a review-fix
   pass, mark `.ai/review.md` blocked too. Record the failing command,
   a short error signature, both attempted fixes, and what input or
   authority is needed from the human.

Reset the counter only when the unified check gets past that failure, or
when concrete evidence shows the next failure has a different root
cause. Renaming the same problem or running an ad-hoc substitute command
does not reset the counter.

## Typical end-to-end workflow

```
1. Claude Code:  read .ai/brief.md  → write .ai/plan.md   (architecture / plan only, no edits)
2. Codex:        read .ai/plan.md   → implement minimal diff → run ./scripts/check.sh
3. Claude Code:  review the diff    → write .ai/review.md  (P0 / P1 / P2)
4. Codex:        fix only P0/P1 from .ai/review.md → rerun ./scripts/check.sh
5. Human:        review and merge
```

Codex's `/review` command (a dedicated reviewer that reads a diff and
produces prioritized, actionable findings) is a good fit for step 3 as
well — any file-capable agent may be assigned as reviewer; the important
thing is that findings land in `.ai/review.md` so the fixing agent
doesn't depend on having seen the review conversation directly.

For an optional generated-asset task, insert this bounded branch without
changing the default stages:

```
planner:   write asset specification and self-contained prompt in .ai/plan.md
human:     assign the registered generation agent in .ai/roster.md
generator: return an image/video without being expected to read local files
proxy:     place it in assets/generated/ and record the full prompt in asset-manifest.md
check:     run ./scripts/check.sh for optional mechanical validation
reviewer:  record accepted/rejected and the reason in asset-manifest.md
```

If the current writer has `file-access: no`, the previous file-capable
writer may be named as the sole write proxy. That proxy is a transport
and recorder only: it may deliver the prompt, place the returned asset,
and update the manifest, but may not edit product code or broaden scope.

## Operating principles (all agents, every turn)

Independent of the five collaboration rules above, both AGENTS.md and
CLAUDE.md carry a shared "Operating principles" section that applies
regardless of which role an agent is playing:

1. Act once you have enough information — don't re-derive settled
   facts or list options you wouldn't actually pick; if a tradeoff
   needs resolving, give a recommendation, not a menu.
2. Ship the simplest solution that solves the problem — no
   out-of-scope features, no unrelated refactors/abstractions, no
   designing for future needs that haven't materialized.
3. Before reporting progress, verify each conclusion against actual
   results from this task — only report what you have evidence for;
   say plainly if something failed or wasn't verified.
4. Only pause when you genuinely need the human — a destructive
   action, a real scope change, or missing information only they can
   provide.
5. Lead with the conclusion — the first sentence answers "what
   happened," details follow.

These exist to keep all agents terse, evidence-based, and
low-maintenance to supervise — the same failure modes (menu-of-options
answers, silent scope creep, unverified "looks done" reports) show up
in both Codex and Claude Code if not explicitly guarded against.

## Embedded / low-level project constraints (adapt as needed)

For embedded or systems-level codebases, both AGENTS.md and CLAUDE.md
include a constraints section by default:

- Be careful with ISR context, DMA ownership, cache coherency,
  alignment, and volatile access.
- Do not introduce dynamic allocation in low-level drivers unless
  explicitly approved.
- Do not change public protocol behavior without documenting it in
  `.ai/decision-log.md`.

Remove or adapt this section for projects where it doesn't apply — it
was written with embedded/driver work (e.g. STM32, grblHAL) in mind.
