#!/usr/bin/env bash
# ============================================================
# 统一验证入口。任何 AI（Codex / Claude Code）在修改代码后
# 必须运行本脚本，禁止自行猜测或决定检查命令。
# 请根据你的技术栈取消注释 / 修改对应部分。
# ============================================================
set -e

echo "== Running unified checks =="

# ---------- Python 项目示例 ----------
if [ -f "pyproject.toml" ] || [ -f "requirements.txt" ]; then
  echo "-- Python project detected --"
  uv run pytest
  uv run ruff check .
  uv run mypy .
fi

# ---------- Node / TypeScript 项目示例 ----------
if [ -f "package.json" ]; then
  echo "-- Node project detected --"
  npm run lint
  npm run typecheck --if-present
  npm test
fi

# ---------- 嵌入式 / C / CMake 项目示例 ----------
if [ -f "CMakeLists.txt" ]; then
  echo "-- CMake project detected --"
  cmake --build build
  ctest --test-dir build
fi

# ---------- Rust 项目示例 ----------
if [ -f "Cargo.toml" ]; then
  echo "-- Rust project detected --"
  cargo check
  cargo clippy -- -D warnings
  cargo test
fi

# ---------- 可选：图片 / 视频等生成资产 ----------
# assets/generated/ 是非代码产出目录；配置上面的代码检查时不要把它当作源码输入。
# 这里仅分发存在性、格式、尺寸、时长等机械校验，不判断内容质量。
if [ -f ".ai/roster.md" ] && [ -f "scripts/checks/assets.sh" ] && \
   awk -F '|' 'tolower($4) ~ /generate-(image|video)/ { found=1 } END { exit !found }' \
     ".ai/roster.md"; then
  echo "-- Generated asset checks --"
  bash scripts/checks/assets.sh
fi

echo "== All checks passed =="
