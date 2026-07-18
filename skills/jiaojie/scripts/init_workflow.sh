#!/usr/bin/env bash
# ============================================================
# init_workflow.sh
# 在目标项目中一键搭建 Codex + Claude Code 双 Agent 协作工作流。
#
# 用法：
#   bash init_workflow.sh [目标项目路径]
#   不传参数时默认使用当前目录。
#
# 已存在的文件不会被覆盖，可安全地在已有项目上重复运行。
# ============================================================
set -euo pipefail

# 定位本脚本所在目录，从而定位到 skill 内的 assets/ 目录
# (无论这个 skill 被安装在个人级 ~/.claude/skills/、项目级
#  .claude/skills/，还是作为插件安装，这段都能正确解析路径)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"
ASSETS_DIR="$SKILL_DIR/assets"

TARGET_DIR="${1:-.}"
TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"

echo "🚀 正在为项目初始化 Codex + Claude Code 双 Agent 协作工作流"
echo "   目标目录：$TARGET_DIR"
echo ""

if [ ! -d "$ASSETS_DIR" ]; then
  echo "❌ 找不到模板目录：$ASSETS_DIR"
  echo "   请确认 jiaojie skill 安装完整（应包含 assets/ 子目录）。"
  exit 1
fi

mkdir -p "$TARGET_DIR/.ai" "$TARGET_DIR/scripts" "$TARGET_DIR/references"

# ---------- 工具函数：仅在目标文件不存在时才复制，避免覆盖 ----------
copy_if_absent() {
  local src="$1"
  local dest="$2"
  if [ -f "$dest" ]; then
    echo "⚠️  已存在，跳过：${dest#$TARGET_DIR/}"
  else
    cp "$src" "$dest"
    echo "✅ 已创建：${dest#$TARGET_DIR/}"
  fi
}

copy_if_absent "$ASSETS_DIR/AGENTS.md"                          "$TARGET_DIR/AGENTS.md"
copy_if_absent "$ASSETS_DIR/CLAUDE.md"                          "$TARGET_DIR/CLAUDE.md"
copy_if_absent "$ASSETS_DIR/scripts/check.sh"                   "$TARGET_DIR/scripts/check.sh"
copy_if_absent "$ASSETS_DIR/ai-templates/brief.md"              "$TARGET_DIR/.ai/brief.md"
copy_if_absent "$ASSETS_DIR/ai-templates/plan.md"               "$TARGET_DIR/.ai/plan.md"
copy_if_absent "$ASSETS_DIR/ai-templates/review.md"             "$TARGET_DIR/.ai/review.md"
copy_if_absent "$ASSETS_DIR/ai-templates/backlog.md"            "$TARGET_DIR/.ai/backlog.md"
copy_if_absent "$ASSETS_DIR/ai-templates/decision-log.md"       "$TARGET_DIR/.ai/decision-log.md"
copy_if_absent "$ASSETS_DIR/ai-templates/prompts-examples.md"   "$TARGET_DIR/.ai/prompts-examples.md"
copy_if_absent "$ASSETS_DIR/ai-templates/roster.md"             "$TARGET_DIR/.ai/roster.md"
copy_if_absent "$ASSETS_DIR/ai-templates/asset-manifest.md"     "$TARGET_DIR/.ai/asset-manifest.md"
copy_if_absent "$SKILL_DIR/references/sync-rules.md"            "$TARGET_DIR/references/sync-rules.md"

chmod +x "$TARGET_DIR/scripts/check.sh" 2>/dev/null || true

echo ""
echo "🎉 初始化完成！目录结构："
echo ""
if command -v tree >/dev/null 2>&1; then
  (cd "$TARGET_DIR" && tree -a -I '.git')
else
  (cd "$TARGET_DIR" && find . -not -path '*/.git*' | sort)
fi

echo ""
echo "接下来："
echo "先填写 .ai/brief.md，再让 Claude Code 读取 .ai/ 做规划。"
echo "首次使用前，请按项目技术栈调整 scripts/check.sh。"
echo "需要切换 Agent 时，说‘同步进度到交接文档’，同步后由你决定下一位 Agent。"
