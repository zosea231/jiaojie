---
name: agent-workplace-init
description: "Initialize a Codex + Claude Code agent workplace in the current project — creates AGENTS.md, CLAUDE.md, scripts/check.sh, and the .ai/ handoff docs (brief.md, plan.md, review.md, backlog.md, decision-log.md). Use when the user asks to initialize an agent workplace, set up a multi-agent or dual-agent workflow, make Codex and Claude Code collaborate on a repository, bootstrap AGENTS.md/CLAUDE.md, or establish single-writer rules, documentation-driven handoffs, role-separated planning/implementation/review, and a unified validation entrypoint. Also use it to explain or apply those collaboration rules even when the user is not asking for scaffolding files."
license: MIT
---

# Agent Workplace Init

A skill for bootstrapping and operating a disciplined two-agent
(Codex + Claude Code) collaboration setup on a codebase, so that:

- Each agent reads the same on-disk context instead of relying on
  conversation memory (important across new sessions).
- Only one agent writes at a time.
- Each agent does exactly one role per turn (analyze, implement,
  review, or fix — never several at once).
- Every change is verified through one fixed entrypoint
  (`scripts/check.sh`), not ad-hoc, agent-invented commands.
- A repeated failure has a hard stop, so an agent cannot loop forever
  while making increasingly speculative edits.

This turns "two AIs poking at the same repo" into a closed loop:
**plan → implement → check → review → fix → check → human merge.**

## When to use this skill

- The user wants to set up a new project (or retrofit an existing one)
  for Codex + Claude Code collaboration.
- The user asks to bootstrap `AGENTS.md` / `CLAUDE.md` / a `.ai/` docs
  folder / a unified check script.
- The user asks how to keep two coding agents from conflicting, losing
  context between sessions, or scope-creeping into unrelated changes.
- The user wants example prompts for handing a task from one agent to
  the other (e.g. "Claude Code analyzes, Codex implements").

## Step 1: Scaffold the workspace

This skill works identically in Claude Code and Codex CLI (both read
the same SKILL.md / skills-folder format, whether installed at
`~/.claude/skills/`, `.claude/skills/`, `~/.codex/skills/`, or
`.codex/skills/`). Don't hardcode any of those paths — locate the
skill's own directory the same way regardless of host: it's the
directory containing this `SKILL.md` (the script itself resolves this
automatically from its own file location, so you normally don't need
to compute it yourself — just invoke it with the path you found this
file under):

```bash
bash /path/to/agent-workplace-init/scripts/init_workflow.sh /path/to/target/project
```

If the user doesn't specify a target, assume the current working
directory. The script is idempotent: existing files are never
overwritten, so it's safe to re-run on a project that already has some
of these files.

After running it, briefly tell the user what was created and point out
that `scripts/check.sh` needs one edit: uncomment/adjust the section
matching their tech stack (Python / Node / CMake / Rust / other).

## Step 2: Explain the five hard rules (when relevant)

If the user asks *how* to use this setup, or you're the one about to
act as one of the two agents in this workflow, apply these rules
strictly — see `references/rules.md` for the full rationale:

1. **Single-writer** — only one agent has write access at any moment.
   Before editing anything, confirm it's actually your turn.
2. **Docs over memory** — all context and handoffs live in `.ai/`.
   At the start of any task (especially a new session), read
   `.ai/brief.md` → `.ai/plan.md` → `.ai/review.md` → `.ai/backlog.md`
   → `.ai/decision-log.md`, in that order, before doing anything else.
   Don't rely on what an earlier turn in this conversation said if it
   conflicts with what the files say.
3. **One role per turn** — do only what was asked (e.g. "only analyze,
   don't edit files" or "only fix P0/P1 from `.ai/review.md`, skip
   P2"). Log out-of-scope findings in `.ai/backlog.md` instead of
   fixing them.
4. **One fixed check entrypoint** — after any edit, run
   `./scripts/check.sh`. Never invent or guess a different validation
   command. If it fails, fix only the failure caused by this task.
5. **Three-strike circuit breaker** — if the same root-cause failure
   appears in three consecutive check runs, stop editing. Mark the task
   blocked in `.ai/plan.md` (and `.ai/review.md` when fixing review
   findings), record the failing command, evidence, and attempted fixes,
   then hand the decision to the human. Reset the count only when the
   check advances past that failure or evidence identifies a different
   root cause.

Both `AGENTS.md` and `CLAUDE.md` also ship with a shared "Operating
principles" section that applies on every turn regardless of role: act
once you have enough information (recommend, don't list a menu of
options), ship the simplest solution that solves the problem, verify
every reported conclusion against actual results from this task, only
pause the human when truly necessary, and lead with the conclusion
before details. See `references/rules.md` for the full rationale.

## Step 3: Run the three-stage handoff

Use this sequence unless the human explicitly assigns different roles.
Never let two agents hold write access at the same time. Before each
stage, record the current writer, current role, and allowed write scope
in `.ai/plan.md`. A conversation handoff is not enough; the on-disk
state is authoritative.

### Stage 1 — Claude Code: plan and choose the route

Give Claude Code write access only to `.ai/plan.md` (and
`.ai/decision-log.md` only when the planning decision itself needs a
durable rationale). Claude Code reads the project and all five `.ai/`
files, compares viable routes using project evidence, recommends one
route, and writes an implementable plan with scope, risks, acceptance
criteria, and explicit non-goals. It does not modify product code.

The stage ends when `.ai/plan.md` is marked ready for implementation
and Claude Code releases write access. Do not start implementation while
the planner is still writing.

### Stage 2 — Codex: implement and check

Assign write access to Codex only after the planning handoff is complete.
Codex rereads the five `.ai/` files, confirms that the plan is ready
and its own write scope is explicit, then implements only that plan. It
runs `./scripts/check.sh` as the sole validation entrypoint, records
non-obvious decisions and out-of-scope findings in the designated
`.ai/` files, and does not review its own work as an independent
reviewer.

The stage ends only when the check result is recorded, the plan is marked
`implemented, pending review` (or blocked under the circuit breaker),
and Codex releases write access.

### Stage 3 — Claude Code: review independently

Assign write access back to Claude Code, limited to `.ai/review.md`,
after Codex stops writing. Claude Code reviews the actual diff against
`.ai/brief.md` and `.ai/plan.md`, verifies the recorded check result
(and may run the same `./scripts/check.sh`), then writes prioritized,
actionable findings to `.ai/review.md`. It does not fix the code during
the review turn.

If P0/P1 findings exist, Claude Code releases write access and the human
assigns a new, bounded fix turn to Codex. Repeat Stage 2 → Stage 3 until
review passes; the human remains the only merge authority.

## Step 4: Use the example handoff prompts

`assets/ai-templates/prompts-examples.md` (copied into the target
project as `.ai/prompts-examples.md`) has ready-to-use prompts for the
full planning → implementation → independent review chain. Adapt the
task details to the target project, but preserve the role boundary,
single-writer handoff, on-disk documentation, and mandatory
`scripts/check.sh` gate.

## Reference files

- `references/rules.md` — full rationale for the five hard rules, the
  difference between prose rules (AGENTS.md/CLAUDE.md) and enforced
  rules (Claude Code hooks / Codex approval modes), and the typical
  end-to-end workflow (plan → implement → check → review → fix →
  merge).
- `assets/` — the actual templates copied into a target project by
  `scripts/init_workflow.sh`. Edit these to change what gets scaffolded.
