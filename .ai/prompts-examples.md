# 提示词示例：默认双 Agent 与可选生成式 Agent

## 场景 A：嵌入式 DMA 修改——阶段 1：Claude Code 规划
```
本轮只做规划。当前唯一写入者是 Claude Code，只允许写 .ai/plan.md，不要修改产品代码。

目标：理解 ETH DMA RX 接收路径。
请输出到 .ai/plan.md：
1. 关键函数调用链
2. DMA 描述符所有权流转
3. cache invalidate 的位置是否合理
4. 可能的并发/中断风险
5. 最小修改建议
6. 验收标准、明确不做项和交给 Codex 的允许写入范围

完成后把状态标为“待实现”并释放写入权。
```

## 场景 A：嵌入式 DMA 修改——阶段 2：Codex 实施
```
确认 Claude Code 已停止写入、人类已把唯一写入权分配给 Codex，再读取全部 .ai/ 交接文件。
请只实现"最小修改建议"，不要重构无关代码。
完成后只运行 ./scripts/check.sh，将状态标为“已实现，待审查”并释放写入权。
如果失败，先解释失败原因，再修复。
```

## 场景 A：嵌入式 DMA 修改——阶段 3：Claude Code 审查
```
确认 Codex 已停止写入、人类已把唯一写入权重新分配给 Claude Code。当前只做独立审查，只允许写 .ai/review.md，不修改产品代码。

对照 .ai/brief.md 和 .ai/plan.md 审查实际 diff，核对 ./scripts/check.sh 结果，把发现按 P0/P1/P2 写入 .ai/review.md。存在 P0/P1 时标为“待修复”并释放写入权；无阻塞问题时标为“通过”并释放写入权。
```

## 场景 B：声学定位算法改进——阶段 1：Claude Code 规划与路线选择
```
目标项目：<目标项目根目录>

本轮只做规划和路线选择，不修改产品代码。当前唯一写入者是 Claude Code，允许写入范围仅为 .ai/plan.md；确需记录长期决策理由时可追加 .ai/decision-log.md。

按顺序读取 .ai/brief.md、.ai/plan.md、.ai/review.md、.ai/backlog.md、.ai/decision-log.md，再读取项目代码、配置、数据、测试和现有验证入口。不要预设阵列结构、定位算法、问题根因或评价指标；所有判断以项目内证据和用户目标为准，无法确认的内容明确标为待验证。

请把以下内容写入 .ai/plan.md：
1. 当前写入者、当前角色、允许写入范围和移交条件
2. 现状调用链/数据流、问题证据与已知约束
3. 与当前项目相符的候选路线及权衡，并直接推荐一条路线、说明选择依据
4. Codex 可逐项执行的最小改动范围、涉及文件和明确不做项
5. 基于项目现有能力定义的验证方法、验收标准、风险与回退条件
6. 状态设为“待实现”，随后释放写入权；不要在本轮开始实施
```

## 场景 B：声学定位算法改进——阶段 2：Codex 实施与检查
```
目标项目：<目标项目根目录>

按顺序读取 .ai/ 五个交接文件。只有当 .ai/plan.md 已标为“待实现”、Claude Code 已释放写入权、且人类明确把当前写入权分配给 Codex 时才开始；否则停止并报告交接缺口。

当前角色仅为实施：严格执行 .ai/plan.md 选定的路线和范围，不自行改选路线，不顺手处理计划外问题。遇到会实质改变方案的证据时停止实施，把证据写回 .ai/plan.md 并请求重新规划。

完成改动后：
1. 只运行 ./scripts/check.sh，不发明或替换验证命令
2. 如实记录检查结果；同一根因连续三次失败时按熔断规则停止
3. 非显而易见的决策写入 .ai/decision-log.md，计划外发现写入 .ai/backlog.md
4. 将 .ai/plan.md 标为“已实现，待审查”或“阻塞”，然后释放写入权
5. 不要把自己的实现当作独立审查结论
```

## 场景 B：声学定位算法改进——阶段 3：Claude Code 独立审查
```
目标项目：<目标项目根目录>

只有当 Codex 已停止写入、.ai/plan.md 标为“已实现，待审查”、且人类明确把写入权重新分配给 Claude Code 时才开始。当前允许写入范围仅为 .ai/review.md；本轮不修改产品代码。

按顺序读取 .ai/ 五个交接文件，审查实际 diff 是否符合 .ai/brief.md 和 .ai/plan.md，并核对 Codex 记录的 ./scripts/check.sh 结果；需要复验时仍只运行同一个 ./scripts/check.sh。

把发现按 P0/P1/P2 写入 .ai/review.md，每条包含证据位置、影响和可执行的修复要求。若有 P0/P1，状态标为“待修复”并释放写入权，等待人类把一个新的定向修复轮次交给 Codex；若无阻塞问题，标为“通过”并释放写入权。不要在审查轮次直接修代码。
```

## 场景 C：接入图片 / 视频生成 Agent——Claude Code 规划与完整闭环
```
目标项目：<目标项目根目录>
生成任务：<图片或视频需求>

本轮只做规划，不生成资产、不修改产品代码。先按既定顺序读取 .ai/ 核心五个文件，
再读取 .ai/roster.md 和 .ai/asset-manifest.md。确认 Claude Code 是 roster.md
中的 Current writer，允许写入范围仅为 .ai/plan.md；只有生成 Agent 尚未登记时，
才额外允许在 .ai/roster.md 增加一行，填写唯一名称、底层模型/工具、
generate-image 或 generate-video 能力、file-access: no、idle。

请把以下内容写入 .ai/plan.md：
1. 资产用途、输出路径（assets/generated/<filename>）和明确不做项
2. 可机械检查的规格：格式、尺寸、文件大小，以及视频时长/编码等
3. 需要人工或审查 Agent 判断的内容验收标准
4. 一条交给生成 Agent 的自包含完整 prompt；它不能引用“见项目文件”或依赖
   对话记忆，必须包含必要背景、画面/镜头要求、禁用项和验收标准
5. 后续责任人：哪个文件型 Agent 作为 Write proxy 落盘并登记，哪个 Agent
   独立验收内容

规划完成后释放写入权，等待人类在 roster.md 中把 Current writer 切换到指定
生成 Agent，并把 Write proxy 指向刚才指定的文件型 Agent；本轮不要开始生成。
```

执行闭环：

1. 人类把 `.ai/plan.md` 中的完整 prompt 原样交给已登记的生成 Agent。
2. 生成 Agent 只返回资产；它不需要也不应被要求读取本地文件。
3. `Write proxy` 只把返回文件放入 `assets/generated/`，并把完整 prompt、
   输出路径和 `pending` 状态登记到 `.ai/asset-manifest.md`。
4. 代理只运行 `./scripts/check.sh`；存在 `scripts/checks/assets.sh` 时由统一
   入口检查存在性、格式、尺寸或时长，并把结果登记回清单。
5. 人类把写入权交给独立审查 Agent。审查者按计划中的内容标准把该记录标为
   `accepted`，或标为 `rejected` 并写明打回理由；审查轮不重新生成资产。

## 通用角色限定提示词模板
- 只做架构/方案分析，不要修改任何文件。
- 规划完成后把结论写入 .ai/plan.md，释放写入权后再交给实施 Agent。
- 只根据 .ai/review.md 修复 P0/P1 问题，不要处理 P2。
- 只实现 .ai/plan.md 中列出的最小修改，不要重构无关代码。
- 完成后必须运行 ./scripts/check.sh；如果失败，先解释原因再修复。
- 审查只写 .ai/review.md，不在同一轮修改产品代码。
- 同一根因连续三次检查失败时停止修改，记录阻塞证据并交还人类决策。
