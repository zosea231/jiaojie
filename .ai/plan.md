# Jiaojie 维护计划

更新：2026-10-20。当前角色：实施、作者检查与提交推送。项目模式：small。

## 概览

- 核心路线：稳定共同入口、按任务读取、有效状态原位维护；用户安排规划、实施和独立审查。
- 本轮任务：[双模式项目架构](#双模式项目架构)。用户授权更新技能、本机安装和 GitHub 同步。
- 适用约束：初始化只补缺失文件；已有项目语义合并；不移动产品代码、数据或运行作业；审查状态见 [review](review.md)。
- 当前进度：实现与说明已更新；完整检查、模式行为和 skill 校验通过；28 个安装文件已逐文件同步核对；提交推送待完成。

## 双模式项目架构

- 目标与范围：为 small／large 提供初始化、维护、模式选择及渐进升级方式，复用全局入口而不绑定特定领域。
- 输入与来源：[skill](../skills/jiaojie/SKILL.md)、[初始化脚本](../skills/jiaojie/scripts/init_workflow.sh)、[AGENTS 模板](../skills/jiaojie/assets/AGENTS.md)、[架构说明](../skills/jiaojie/references/project-architecture.md)。吸收已采用的全局／局部与分支工作区实践。
- 输出：双模式 CLI、大型模板、共享规则、README、安装副本和远端提交。旧 small 默认和已有文件保持兼容。
- 边界：workflow 管任务、project 管代码职责；全局 plan 只概览，局部 plan 保存细节；worktree 按需，文档按分支版本读取。代码／数据迁移及部署不属于本轮。
- 实施／验收角色：本会话实施与作者检查；独立审查另行安排。
- 验收：从 `bash scripts/check.sh` 运行既有检查及 [modes.sh](../scripts/checks/modes.sh)，覆盖大型初始化、重复运行、增量升级保留、参数拒绝、实际 worktree 和分支进度；技能格式校验及安装副本逐文件核对。
- 当前状态：实现和验证已完成，安装副本已同步且一致；下一步复核变更、提交并推送 main。
