# 项目内容索引

先确认共同目标和阶段，再进入当前 workflow。按任务展开源码、原始证据和相关工作流；进度在局部 plan 维护。

## 目录与资料

| 内容 | 位置／读取时机 |
|---|---|
| 共同目标与计划 | [brief](brief.md)、[plan](plan.md)，任务开始时读取 |
| 架构与 worktree | [project-architecture.md](../references/project-architecture.md)，新增工作流或工作区时读取 |
| 源码与开发工具 | `projects/<project>/`，按稳定职责命名，实际模块出现时登记入口 |
| 产物与证据 | `artifacts/<topic>/`，按需创建并登记来源、采用状态和可编辑源文件 |
| 参考资料 | `references/`，链接资料原文，保留来源和许可证 |
| 统一检查 | [check.sh](../scripts/check.sh)，首次开发前配置真实工具链与子项目检查 |
| 审查、决策与资产记录 | 需要时在全局或对应 workflow 创建，按影响范围维护并在此链接 |

## 数据与运行环境

有外置数据或服务器时填写：用途、位置／连接别名、关联的本机代码目录、读取方式、部署版本或最后核对时间。数据和环境不复制到 worktree；不记录密钥。

## 工作流导航

| workflow | 局部目标与计划 | 源码／证据入口 | 分支与 worktree（相对主 checkout） |
|---|---|---|---|
