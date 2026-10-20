# Jiaojie 当前目标

让项目在扩展和跨会话协作中保持可读、模块化、路线明确。默认由用户切换 Codex Astra 规划／审查会话与 Sol 执行会话，按需加入 Claude Code、Workbuddy 和生成 agent。

当前交付已完成：支持 small／large 两种项目初始化与维护。small 保留轻量入口并预留渐进升级；large 使用全局概览、局部 workflow 文档、依赖导航和按需 worktree。技能、脚本、模板与说明已验证，本机安装已同步，GitHub main 已推送实现提交。本仓库自身继续采用 small，验收与提交入口见 plan。

验收使用 `scripts/check.sh`，检查包内文件、初始化行为、保留已有内容、可选 Claude 入口及既有检查的失败传播。用户已授权提交并推送到 zosea231/jiaojie。
