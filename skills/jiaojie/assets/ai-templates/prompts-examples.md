# 提示词示例：默认双 Agent 与可选生成式 Agent

以下示例都遵循同一个交接方式：当前 Agent 在阶段结束时按
`references/sync-rules.md` 同步进度到 `.ai/`，然后停止并等待人类切换到
下一个 Agent。

## 场景 A：嵌入式 DMA 修改——阶段 1：Claude Code 规划

```text
本轮只做规划，只更新 .ai/plan.md，不修改产品代码。

目标：理解 ETH DMA RX 接收路径。
请输出到 .ai/plan.md：
1. 关键函数调用链
2. DMA 描述符所有权流转
3. cache invalidate 的位置是否合理
4. 可能的并发/中断风险
5. 最小修改建议
6. 验收标准和明确不做项

完成后将状态标为“待实现”，按 references/sync-rules.md 同步进度到 .ai/
文档，然后停止，等待人类切换到 Codex。
```

## 场景 A：嵌入式 DMA 修改——阶段 2：Codex 实施

```text
先读取全部 .ai/ 交接文件，确认 .ai/plan.md 已标为“待实现”。
只实现“最小修改建议”，不要重构无关代码。
完成后只运行 ./scripts/check.sh，将状态标为“已实现，待审查”，按
references/sync-rules.md 同步进度到 .ai/ 文档，然后停止，等待人类切换到
Claude Code。检查失败时先解释原因，再做范围内的最小修复。
```

## 场景 A：嵌入式 DMA 修改——阶段 3：Claude Code 审查

```text
先读取全部 .ai/ 交接文件。本轮只做独立审查，只更新 .ai/review.md，不修改
产品代码。

对照 .ai/brief.md 和 .ai/plan.md 审查实际 diff，核对 ./scripts/check.sh 结果，
把发现按 P0/P1/P2 写入 .ai/review.md。存在 P0/P1 时标为“待修复”，否则标为
“通过”。按 references/sync-rules.md 同步进度到 .ai/ 文档，然后停止，等待
人类决定切换到 Codex 修复或进入合并。
```

## 场景 B：声学定位算法改进——阶段 1：Claude Code 规划与路线选择

```text
目标项目：<目标项目根目录>

本轮只做规划和路线选择，只更新 .ai/plan.md；确需记录长期决策理由时可追加
.ai/decision-log.md。不要修改产品代码。

按顺序读取 .ai/brief.md、.ai/plan.md、.ai/review.md、.ai/backlog.md、
.ai/decision-log.md，再读取项目代码、配置、数据、测试和现有验证入口。不要预设
阵列结构、定位算法、问题根因或评价指标；所有判断以项目内证据和用户目标为准，
无法确认的内容明确标为待验证。

请把以下内容写入 .ai/plan.md：
1. 当前角色、本轮范围和移交条件
2. 现状调用链/数据流、问题证据与已知约束
3. 与当前项目相符的候选路线及权衡，并直接推荐一条路线、说明选择依据
4. Codex 可逐项执行的最小改动范围、涉及文件和明确不做项
5. 基于项目现有能力定义的验证方法、验收标准、风险与回退条件
6. 状态设为“待实现”

完成后按 references/sync-rules.md 同步进度到 .ai/ 文档，然后停止，不在本轮
开始实施，等待人类切换到 Codex。
```

## 场景 B：声学定位算法改进——阶段 2：Codex 实施与检查

```text
目标项目：<目标项目根目录>

按顺序读取 .ai/ 五个核心交接文件。只有当 .ai/plan.md 已标为“待实现”时才
开始；否则停止并报告交接缺口。

本轮仅实施：严格执行 .ai/plan.md 选定的路线和范围，不自行改选路线，不顺手
处理计划外问题。遇到会实质改变方案的证据时停止实施，把证据同步回
.ai/plan.md，并请人类切回规划 Agent。

完成改动后：
1. 只运行 ./scripts/check.sh，不发明或替换验证命令
2. 如实记录检查结果；同一根因连续三次失败时按熔断规则停止
3. 非显而易见的决策追加到 .ai/decision-log.md，计划外发现追加到
   .ai/backlog.md
4. 将 .ai/plan.md 标为“已实现，待审查”或“阻塞”
5. 按 references/sync-rules.md 同步进度到 .ai/ 文档，然后停止，等待人类切换
   到独立审查 Agent
6. 不要把自己的实现当作独立审查结论
```

## 场景 B：声学定位算法改进——阶段 3：Claude Code 独立审查

```text
目标项目：<目标项目根目录>

先读取 .ai/ 五个核心交接文件。只有当 .ai/plan.md 标为“已实现，待审查”时才
开始；否则停止并报告交接缺口。本轮只更新 .ai/review.md，不修改产品代码。

审查实际 diff 是否符合 .ai/brief.md 和 .ai/plan.md，并核对 Codex 记录的
./scripts/check.sh 结果；需要复验时仍只运行同一个 ./scripts/check.sh。

把发现按 P0/P1/P2 写入 .ai/review.md，每条包含证据位置、影响和可执行的修复
要求。若有 P0/P1，状态标为“待修复”；若无阻塞问题，标为“通过”。按
references/sync-rules.md 同步进度到 .ai/ 文档，然后停止，等待人类切换到
Codex 修复或进入合并。不要在审查轮次直接修代码。
```

## 场景 C：接入图片 / 视频生成 Agent——规划与完整闭环

```text
目标项目：<目标项目根目录>
生成任务：<图片或视频需求>

本轮只做规划，不生成资产、不修改产品代码。先按既定顺序读取 .ai/ 核心五个
文件，再读取 .ai/roster.md 和 .ai/asset-manifest.md。只有生成 Agent 尚未登记
时，才在 .ai/roster.md 增加一行，填写唯一名称、底层模型/工具、
generate-image 或 generate-video 能力、File access 和 idle 状态。

请把以下内容写入 .ai/plan.md：
1. 资产用途、输出路径（assets/generated/<filename>）和明确不做项
2. 可机械检查的规格：格式、尺寸、文件大小，以及视频时长/编码等
3. 需要人工或审查 Agent 判断的内容验收标准
4. 一条交给生成 Agent 的自包含完整 prompt；它不能引用“见项目文件”或依赖
   对话记忆，必须包含必要背景、画面/镜头要求、禁用项和验收标准
5. 后续顺序：人类先切换到生成 Agent 获取资产，再切换到文件型 Agent 落盘
   并登记，最后切换到独立审查 Agent 验收

规划完成后按 references/sync-rules.md 同步进度到 .ai/ 文档，然后停止，等待
人类切换到生成 Agent；本轮不要开始生成。
```

执行闭环：

1. 人类把 `.ai/plan.md` 中的完整 prompt 原样交给已登记的生成 Agent。
2. 生成 Agent 只返回资产；它不需要也不应被要求读取本地文件，然后停止。
3. 人类切换到文件型 Agent；该 Agent 把返回文件放入
   `assets/generated/`，并把完整 prompt、输出路径和 `pending` 状态追加到
   `.ai/asset-manifest.md`。
4. 文件型 Agent 只运行 `./scripts/check.sh`；存在
   `scripts/checks/assets.sh` 时由统一入口检查存在性、格式、尺寸或时长，
   然后同步交接文档并停止。
5. 人类切换到独立审查 Agent。审查者按计划中的内容标准把记录标为
   `accepted`，或标为 `rejected` 并写明理由；审查轮不重新生成资产。
6. 审查者同步交接文档后停止，把下一步切换决定交给人类。

## 通用角色限定提示词模板

- 只做架构/方案分析，不要修改产品代码。
- 规划完成后按 `references/sync-rules.md` 同步进度到 `.ai/` 文档，停止并
  等待人类切换到实施 Agent。
- 只根据 `.ai/review.md` 修复 P0/P1 问题，不要处理 P2。
- 只实现 `.ai/plan.md` 中列出的最小修改，不要重构无关代码。
- 完成代码修改后必须运行 `./scripts/check.sh`；失败时先解释原因再修复。
- 审查只更新 `.ai/review.md`，不在同一轮修改产品代码。
- 同一根因连续三次检查失败时停止修改，记录阻塞证据并交还人类决策。
- 每个阶段同步交接文档后停止，不要自行进入下一个 Agent 的角色。
