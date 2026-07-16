# Agent Roster（Agent 花名册）

> 参与者、能力和写入权的唯一事实源。新增 Agent 是可选操作；默认双 Agent
> 工作流只使用下表预填的 Codex 与 Claude Code。

## 当前分配
- Current writer: `none`
- Write proxy: `none`
- 当前角色：
- 允许写入范围：

`Current writer` 必须是下表中的一个 Agent 名称或 `none`。只有当前写入者可以
持有逻辑写入权。若其 `File access` 为 `no`，`Write proxy` 必须明确指向上一个
具备文件访问能力的 Agent；该代理只能交付完整 prompt、把返回文件放入
`assets/generated/`，并更新 `.ai/asset-manifest.md`。

## 参与 Agent

| Agent | Model / tool | Capabilities | File access | Status |
|---|---|---|---|---|
| Claude Code | Claude Code | plan, review | yes | idle |
| Codex | Codex | implement, fix, review | yes | idle |

允许的 `Status`：`idle`、`active`、`blocked`。能力按需填写，例如 `plan`、
`implement`、`review`、`generate-image`、`generate-video`。同一时刻最多一行是
`active`，且必须与 `Current writer` 一致；`Current writer: none` 时所有行应为
`idle` 或 `blocked`。
