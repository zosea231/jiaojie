# Claude Code project entrypoint

Claude Code 参与本项目时，先读取并遵守 [AGENTS.md](AGENTS.md)，再按其中顺序读取 `.ai/`。共享规则统一在 AGENTS.md 维护。

## Handoff is human-orchestrated, not locked
执行用户指定的规划、实施、独立审查或修复角色；角色结束按 `references/sync-rules.md` 同步后停止。检查统一从 `scripts/check.sh` 进入，必要的任务检查放 `scripts/checks/<name>.sh`。写作与产物位置遵守 AGENTS.md 及 `.ai/index.md`。
