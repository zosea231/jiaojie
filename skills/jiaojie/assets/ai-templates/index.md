# 项目内容索引

按用途维护能帮助新 agent 定位的入口。新增、移动或采用有用产物时更新对应项，详细记录留在来源文件。已有目录优先，不逐项枚举整个文件树。

## 当前工作与模块

| 内容 | 入口 | 用途 |
|---|---|---|
| 目标与核心路线 | [brief.md](brief.md) | 当前目标、范围 |
| 实施与验收 | [plan.md](plan.md) | 阶段、状态、下一步 |
| 审查与决策 | [review.md](review.md)、[decision-log.md](decision-log.md) | 有效问题与理由 |
| 待办与参与者 | [backlog.md](backlog.md)、[roster.md](roster.md) | 后续事项、角色与文件访问 |
| 生成资产 | [asset-manifest.md](asset-manifest.md) | 提示词、检查与接受状态 |
| 项目规则 | [AGENTS.md](../AGENTS.md) | 架构、协作、安全与产物要求 |
| 写作 | [writing-rules.md](../references/writing-rules.md) | 正文与最终包装要求 |
| 统一检查 | [check.sh](../scripts/check.sh) | 项目验证入口 |

有代码后补充主要模块的职责、入口和依赖方向，链接到模块说明。

## 产物存放约定

| 类型 | 默认目录 | 维护要求 |
|---|---|---|
| 参考资料 | `references/` | 来源和用途 |
| 普通报告 | `out/reports/` | 采用稿与可编辑源文件 |
| 演示文稿 | `out/presentations/` | 采用状态及配套材料 |
| Workbuddy 报告、问答与附件 | `out/workbuddy/<topic>/` | 来源、作者、采用状态；不散落根目录或 .ai |
| 生成图片／视频 | `assets/generated/` | 完整提示词放产物旁，asset-manifest 保存入口 |

目录随产物按需创建，已有项目可在本表记录实际存放位置。

## 有用产物与证据

| 用途 | 路径 | 来源／作者 | 当前状态 |
|---|---|---|---|

在此登记采用稿、可编辑源文件和影响当前路线的证据入口。
