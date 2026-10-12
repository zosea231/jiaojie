# Jiaojie 内容索引

| 用途 | 入口 | 内容 |
|---|---|---|
| 用户文档 | [README.md](../README.md) | 安装、已有项目更新、协作与产物目录 |
| 当前路线和状态 | [brief.md](brief.md)、[plan.md](plan.md) | 维护目标、验收及下一步 |
| 决策与审查 | [decision-log.md](decision-log.md)、[review.md](review.md) | 有效理由与独立审查状态 |
| 技能入口 | [SKILL.md](../skills/jiaojie/SKILL.md) | 初始化、规则更新、交接与角色路由 |
| 共享项目规则 | [AGENTS 模板](../skills/jiaojie/assets/AGENTS.md) | 架构、写作、索引、安全与交付要求 |
| 初始化 | [init_workflow.sh](../skills/jiaojie/scripts/init_workflow.sh) | 复制缺失模板及运行规则 |
| 状态与索引模板 | [ai-templates](../skills/jiaojie/assets/ai-templates) | 新项目的当前上下文 |
| 已有项目更新 | [update-rules.md](../skills/jiaojie/references/update-rules.md) | 语义合并和保留现有内容 |
| 写作与来源 | [writing-rules.md](../references/writing-rules.md) | 内置 Anti-Defensive Writing、许可和应用 |
| 统一检查 | [check.sh](../scripts/check.sh) | 打包、复制、初始化和失败传播 |
| 初始化行为测试 | [scaffold.sh](../scripts/checks/scaffold.sh) | 可选 Claude 入口、已有文件保留 |

包内 assets 为输出模板，references 为运行规则与维护说明，scripts 只负责初始化；根运行规则供本仓库使用。Workbuddy 若参与，报告与附件放 `out/workbuddy/<topic>/`，在本索引登记来源和采用状态。测试临时目录由检查退出时清理，不作为项目产物。
