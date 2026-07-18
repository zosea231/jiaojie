---
name: jiaojie
description: "Initialize an extensible agent handoff workspace in the current project with a Codex + Claude Code default. Creates AGENTS.md, CLAUDE.md, scripts/check.sh, and .ai/ handoff, roster, and generated-asset records. Use when the user asks to bootstrap a multi-agent or dual-agent workflow, establish human-orchestrated handoffs, sync progress or conclusions into .ai/ documents, separate planning/implementation/review roles, add image/video agents, or apply Jiaojie collaboration rules. The terms jiaojie and 交接 also trigger this skill."
---

# Jiaojie

Jiaojie bootstraps a disciplined agent collaboration setup on a codebase. It
defaults to Codex + Claude Code and lets the user add specialized agents.

- Every agent reads the same on-disk context instead of relying on
  conversation memory.
- The human talks to one agent at a time and manually switches agents;
  no lock, hook, or write-ownership mechanism is needed.
- Each agent performs one role per turn: plan, implement, review, or fix.
- Every code change is verified through one fixed entrypoint,
  `scripts/check.sh`.
- Repeated failures have a hard stop instead of an endless edit loop.
- Image/video outputs preserve their full prompt and acceptance state.

The default loop is **plan → sync → implement → check → sync → review →
sync → fix → check → human merge**.

## Step 1: Scaffold the workspace

Locate this skill's directory and run:

```bash
bash /path/to/jiaojie/scripts/init_workflow.sh /path/to/target/project
```

If the user does not specify a target, use the current working directory.
The script works from personal, project, or plugin skill installations and
never overwrites existing files.

After running it, report which files were created. Point out that
`scripts/check.sh` needs one project-specific edit: adjust the section for
the repository's actual Python, Node, CMake, Rust, or other toolchain.

## Step 2: Apply the five collaboration rules

Read `references/rules.md` when the user asks for rationale or an edge
case. Apply these rules during normal work:

1. **Human-orchestrated handoff** — only one agent works at a time because
   the human is interacting with one agent at a time. The roster records
   participants and capabilities; it is not a lock or scheduler.
2. **Docs over memory** — at the start of every task, read
   `.ai/brief.md` → `.ai/plan.md` → `.ai/review.md` →
   `.ai/backlog.md` → `.ai/decision-log.md`, then `.ai/roster.md`.
   Read `.ai/asset-manifest.md` when generated assets are involved.
   When the human requests a sync, or a stage naturally completes, follow
   `references/sync-rules.md`, update the relevant files, and stop.
3. **One role per turn** — perform only the requested role. Put out-of-scope
   findings in `.ai/backlog.md` instead of fixing them.
4. **One fixed check entrypoint** — after a code or asset edit, run
   `./scripts/check.sh`. Do not invent a substitute validation command.
5. **Three-strike circuit breaker** — after three consecutive failures with
   the same root cause, stop. Mark the task blocked in `.ai/plan.md` (and
   `.ai/review.md` during a review-fix pass), record the evidence and
   attempted fixes, and ask the human for the missing decision or input.

Both scaffolded instruction files also include shared operating principles:
use the simplest sufficient change, stay in scope, verify claims against
actual results, pause only when necessary, and lead with the conclusion.

## Step 3: Run the human-orchestrated handoff

Use this sequence unless the human assigns different roles. At each stage,
the active agent rereads `.ai/` from disk. When the stage finishes, follow
`references/sync-rules.md`, tell the human what was synchronized, and stop
so the human can switch to the next agent.

### Stage 1 — Claude Code: plan and choose the route

Claude Code reads the project and handoff documents, compares viable routes
using project evidence, and writes an implementable `.ai/plan.md` with
scope, risks, acceptance criteria, and explicit non-goals. It does not edit
product code. It marks the plan ready for implementation, synchronizes any
supporting decision or backlog entries, then stops.

### Stage 2 — Codex: implement and check

Codex rereads the handoff documents, confirms the plan is ready, and
implements only that plan. It runs `./scripts/check.sh`, records
non-obvious decisions and out-of-scope findings in their designated files,
marks the plan `implemented, pending review` (or blocked under the circuit
breaker), synchronizes the handoff documents, then stops. It does not act as
its own independent reviewer.

### Stage 3 — Claude Code: review independently

Claude Code rereads the handoff documents, reviews the actual diff against
`.ai/brief.md` and `.ai/plan.md`, and verifies the recorded check result.
It writes prioritized P0/P1/P2 findings to `.ai/review.md` without fixing
product code, synchronizes the review state, then stops.

If P0/P1 findings exist, the human switches to Codex for a bounded fix turn,
then switches back for another independent review. The human remains the
only merge authority.

## Step 4: Use the example prompts

`assets/ai-templates/prompts-examples.md` is copied to
`.ai/prompts-examples.md`. Adapt task details while preserving the role
boundary, fresh reads of `.ai/`, synchronization before handoff, and the
mandatory `scripts/check.sh` gate.

## Step 5: Add a non-code or generative agent (optional)

Keep the default Codex + Claude Code rows and add a roster row with the
agent's model/tool, capabilities such as `generate-image` or
`generate-video`, file access, and status. The roster is only a registry.

For an agent with `File access: no`, a file-capable planning agent writes a
self-contained prompt containing the relevant context, output specification,
and acceptance criteria. The human switches to the generation agent to
obtain the asset, then switches to a file-capable agent to place it under
`assets/generated/` and append the complete prompt, output path, mechanical
check result, and review state to `.ai/asset-manifest.md`.

Run `./scripts/check.sh` after recording an asset. If
`scripts/checks/assets.sh` exists, the entrypoint may dispatch to it for
file existence, decoding, dimensions, or duration. It must not validate the
handoff synchronization itself. Content quality belongs to a human or review
agent, which records `accepted` or `rejected` with a reason.

Do not add model-specific APIs or integrations unless the user separately
asks for them.

## Reference files

- `references/sync-rules.md` — how to write handoff documents so a new agent
  can resume with zero conversation context; copied into target projects.
- `references/rules.md` — rationale and edge cases for the collaboration
  rules.
- `assets/` — templates copied by `scripts/init_workflow.sh`.
- `assets/ai-templates/roster.md` — participant and capability registry.
- `assets/ai-templates/asset-manifest.md` — generated-asset prompt, output,
  checks, and acceptance record.
