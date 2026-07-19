#!/usr/bin/env bash
# ============================================================
# 统一验证入口。任何 AI（Codex / Claude Code）在修改代码后
# 必须运行本脚本，禁止自行猜测或决定检查命令。
# 请根据你的技术栈取消注释 / 修改对应部分。
# ============================================================
set -e

echo "== Running unified checks =="

stack_detected=0

# ---------- Python 项目示例 ----------
if [ -f "pyproject.toml" ] || [ -f "requirements.txt" ]; then
  stack_detected=1
  echo "-- Python project detected --"
  uv run pytest
  uv run ruff check .
  uv run mypy .
fi

# ---------- Node / TypeScript 项目示例 ----------
if [ -f "package.json" ]; then
  stack_detected=1
  echo "-- Node project detected --"
  npm run lint
  npm run typecheck --if-present
  npm test
fi

# ---------- 嵌入式 / C / CMake 项目示例 ----------
if [ -f "CMakeLists.txt" ]; then
  stack_detected=1
  echo "-- CMake project detected --"
  cmake --build build
  ctest --test-dir build
fi

# ---------- Rust 项目示例 ----------
if [ -f "Cargo.toml" ]; then
  stack_detected=1
  echo "-- Rust project detected --"
  cargo check
  cargo clippy -- -D warnings
  cargo test
fi

# 任务专属验收标准：按需 dispatch，不进入总是执行的主流程
if [ -d "scripts/checks" ]; then
  for task_check in scripts/checks/*.sh; do
    [ -e "$task_check" ] || continue
    echo "-- Task-specific check: $(basename "$task_check") --"
    bash "$task_check" || { echo "FAIL: $task_check" >&2; exit 1; }
  done
fi

if [ "$stack_detected" -eq 0 ]; then
  echo "FAIL: no supported project stack detected; customize scripts/check.sh before use" >&2
  exit 1
fi

echo "== All checks passed =="
