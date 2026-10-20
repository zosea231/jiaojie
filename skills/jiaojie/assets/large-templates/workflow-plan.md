# __WORKFLOW__：实施计划

## 当前状态与下一步

- 本轮角色、分支与 worktree：待实际安排。
- 当前结果、证据入口、下一动作：待填写。
- 真实依赖及受影响的后续 workflow：存在时链接。

## 本轮步骤与验收

按当前任务填写模块边界、输入、实施步骤、输出位置与验收依据。保持有界，完成的步骤压缩为结论和证据链接。

验证从当前 checkout 根目录的 `bash scripts/check.sh` 进入。缺少必要行为验收时新增 `scripts/checks/<name>.sh`，记录理由并保留既有检查；同根因连续三次失败停止，记录命令、错误、尝试和所需决策。作者检查与独立审查分别记录。

## 交接

在交付节点、阻塞或跨任务输入变化时更新本文，并简要同步根 plan 对应行。可交付提交及证据在此链接；另一分支的进度通过 `git show <branch>:.ai/workflows/<workflow>/plan.md` 读取，跨机器先 fetch，再读 `origin/<branch>`。Windows Git Bash 在 git show 前加 `MSYS_NO_PATHCONV=1`。
