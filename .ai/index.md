# Jiaojie 内容索引

先读 brief、plan 概览与本轮任务，再按本索引定位材料。任务状态在 plan 维护。

| 用途 | 入口 | 何时读取／内容 |
|---|---|---|
| 用户文档 | [README.md](../README.md) | 安装、已有项目更新、协作与产物目录 |
| 当前路线和状态 | [brief.md](brief.md)、[plan.md](plan.md) | 任务共同入口，概览与相关任务 |
| 决策 | [decision-log.md](decision-log.md) | 修改规则、模板或维护方式时读相关理由 |
| 审查 | [review.md](review.md) | 实施、审查或修复时读相关状态 |
| 技能入口 | [SKILL.md](../skills/jiaojie/SKILL.md) | 修改初始化、规则更新、上下文路由或角色流程时读取 |
| 共享项目规则 | [AGENTS 模板](../skills/jiaojie/assets/AGENTS.md) | 架构、写作、索引、安全与交付要求 |
| 初始化 | [init_workflow.sh](../skills/jiaojie/scripts/init_workflow.sh) | 复制缺失模板及运行规则 |
| 任务计划模板 | [plan.md](../skills/jiaojie/assets/ai-templates/plan.md) | 调整共同概览、任务输入／依赖／交付时读取 |
| 内容索引模板 | [index.md](../skills/jiaojie/assets/ai-templates/index.md) | 调整模块入口、读取时机和产物导航时读取 |
| 其他交接模板 | [ai-templates](../skills/jiaojie/assets/ai-templates) | 修改对应交接内容时读取相关模板 |
| 已有项目更新 | [update-rules.md](../skills/jiaojie/references/update-rules.md) | 语义合并和保留现有内容 |
| 同步与依赖维护 | [sync-rules.md](../references/sync-rules.md) | 状态同步、索引维护和变更影响处理 |
| 写作与来源 | [writing-rules.md](../references/writing-rules.md) | 内置 Anti-Defensive Writing、许可和应用 |
| 统一检查 | [check.sh](../scripts/check.sh) | 打包、复制、初始化和失败传播 |
| 初始化行为测试 | [scaffold.sh](../scripts/checks/scaffold.sh) | 可选 Claude 入口、已有文件保留 |

包内 assets 为输出模板，references 为运行规则与维护说明，scripts 只负责初始化；根运行规则供本仓库使用。Workbuddy 若参与，报告与附件放 `out/workbuddy/<topic>/`，在本索引登记来源和采用状态。测试临时目录由检查退出时清理，不作为项目产物。
