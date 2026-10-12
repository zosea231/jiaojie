# Jiaojie 维护计划

更新：2026-10-12。当前角色：实施，已完成作者检查。

## 路线与状态

1. 将共享项目约束放入 AGENTS 模板，SKILL.md 路由到同步、写作与已有项目更新说明。
2. 默认 Astra／Sol 分工，Claude Code 按需创建薄入口；Workbuddy 遵守共享索引及输出目录。
3. 初始化只创建缺失文件；已有项目通过 agent 语义合并，保留当前路线、用户修改和安全措施。
4. 内置 Anti-Defensive Writing 原文及 MIT 许可，项目写作规则负责应用和最终包装约束。
5. 从 `scripts/check.sh` 验证，同步本机安装，提交并推送。

模板、脚本与说明已实现，本机安装已更新。统一入口 `bash scripts/check.sh` 退出 0：初始化默认行为、可选 Claude、已有文件保留、原有失败传播和 skill-creator 校验通过。Windows Python 调用显式使用 UTF-8。独立审查由用户另行安排。

## 验收

初始化默认生成索引和写作资料，--with-claude 创建共享规则入口；重复执行保留全部已有文件。验证统一检查对未知技术栈和失败任务检查的既有处理。新行为检查位于 `scripts/checks/scaffold.sh`，仍由统一入口运行。
