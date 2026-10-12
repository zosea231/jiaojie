# Jiaojie 维护计划

更新：2026-10-12。当前角色：实施、作者检查与提交推送。

## 概览

- 核心路线：共享规则在 AGENTS 模板维护，SKILL.md 路由到同步、写作与已有项目更新说明；默认由用户切换 Astra／Sol。
- 当前任务：[按任务读取与依赖维护](#按任务读取与依赖维护)。保留文档精简、写作、产物目录与安全约束。
- 适用约束：初始化只创建缺失文件；已有项目语义合并；作者检查与独立审查分别记录。审查状态见 [review.md](review.md)。
- 下一动作：用户安排独立审查或在目标项目应用最新规则；本轮提交推送已获授权。

## 按任务读取与依赖维护

- 目标与范围：共同入口保持简短，按角色读取相关材料，在现有 plan 中表达任务输入、依赖和交付关系。
- 输入与来源：[SKILL.md](../skills/jiaojie/SKILL.md)、[AGENTS 模板](../skills/jiaojie/assets/AGENTS.md)、[plan 模板](../skills/jiaojie/assets/ai-templates/plan.md)、[index 模板](../skills/jiaojie/assets/ai-templates/index.md)、[更新规则](../skills/jiaojie/references/update-rules.md)、[README](../README.md)。
- 前置条件：沿用已采用的人工切换、文档精简、写作与安全默认值，理由见 [decision-log.md](decision-log.md)。用户已授权更新并推送。
- 实施与输出：更新 skill、AGENTS、brief／plan／index 和提示词模板、同步与更新规则、README；同步根规则和本机安装。
- 执行／验收角色：当前会话实施与作者检查；用户另行安排独立审查。
- 验收：阅读核对共同入口和角色路由、全局约束可见性、任务来源和真实依赖、变更影响、已有项目合并说明；从 `scripts/check.sh` 运行既有行为检查与 skill 校验。
- 当前状态：已实现，作者检查通过，本机安装已同步；独立审查尚未安排。
- 下一动作与接收方：用户安排独立审查；后续项目使用最新 skill 按更新说明合并。

## 既有验证与维护

统一检查覆盖模板复制、默认初始化、可选 Claude、重复执行保留已有文件及检查失败传播，使用现有 `scripts/checks/scaffold.sh`。文档语义通过阅读核对；Windows Python 调用使用 UTF-8。核心路线保持，详细模板内容见来源文件。

本轮 `bash scripts/check.sh` 退出 0，初始化行为与 skill-creator 校验通过。本机安装文件已与仓库包逐文件比较一致。
