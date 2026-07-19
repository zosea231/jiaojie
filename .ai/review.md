# Review（审查意见）

> 由负责"审查"角色的 Agent 填写（例如 Claude Code 审查 Codex 的 diff，
> 或 Codex `/review` 审查 Claude Code 的 diff）。
> 修复方（另一个 Agent）只处理 P0/P1，除非明确被要求处理 P2。

## 审查范围
（对应哪次 diff / commit / .ai/plan.md 中的哪个阶段）

## P0（阻塞，必须修）
-

## P1（重要，本轮应修）
-

## P2（次要，记录即可，默认不修）
-

## 验收标准缺口
（本次审查中发现现有 `check.sh` / `scripts/checks/` 未覆盖但应该覆盖的
验收点，说明要追加哪个 `scripts/checks/<name>.sh`，不要直接改主流程。）

## 状态
- [ ] 待修复
- [ ] 修复中
- [ ] 已修复，待复核
- [ ] 通过
- [ ] 阻塞，待人类决策

阻塞时记录：连续失败的命令、稳定错误特征、已尝试的两种修复、需要人类提供的信息或授权。
