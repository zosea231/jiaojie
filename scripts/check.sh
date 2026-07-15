#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."

echo "== Checking agent-workplace-init =="

required=(
  SKILL.md README.md LICENSE AGENTS.md CLAUDE.md agents/openai.yaml
  scripts/init_workflow.sh scripts/check.sh
  references/rules.md
  assets/AGENTS.md assets/CLAUDE.md assets/check.sh
  assets/ai-templates/brief.md assets/ai-templates/plan.md
  assets/ai-templates/review.md assets/ai-templates/backlog.md
  assets/ai-templates/decision-log.md
  assets/ai-templates/prompts-examples.md
  .ai/brief.md .ai/plan.md .ai/review.md .ai/backlog.md
  .ai/decision-log.md .ai/prompts-examples.md
)

for path in "${required[@]}"; do
  test -f "$path" || { echo "FAIL: missing $path" >&2; exit 1; }
done

test ! -e agent-workplace-init || {
  echo "FAIL: redundant nested agent-workplace-init/ directory" >&2
  exit 1
}
test ! -e agent-workplace-init.zip || {
  echo "FAIL: generated ZIP should not be committed at repository root" >&2
  exit 1
}

cmp -s AGENTS.md assets/AGENTS.md || {
  echo "FAIL: AGENTS.md and its scaffold template differ" >&2
  exit 1
}
cmp -s CLAUDE.md assets/CLAUDE.md || {
  echo "FAIL: CLAUDE.md and its scaffold template differ" >&2
  exit 1
}
for name in brief plan review backlog decision-log prompts-examples; do
  cmp -s ".ai/$name.md" "assets/ai-templates/$name.md" || {
    echo "FAIL: .ai/$name.md is not in the clean initial template state" >&2
    exit 1
  }
done

grep -q '^name: agent-workplace-init$' SKILL.md
grep -q '^description:' SKILL.md
grep -q 'display_name: "Agent Workplace Init"' agents/openai.yaml
grep -q '\$agent-workplace-init' agents/openai.yaml
grep -q 'Three-strike circuit breaker' SKILL.md
grep -q '声学定位算法改进' assets/ai-templates/prompts-examples.md
grep -q 'Stage 1 — Claude Code: plan and choose the route' SKILL.md
grep -q 'Stage 2 — Codex: implement and check' SKILL.md
grep -q 'Stage 3 — Claude Code: review independently' SKILL.md
grep -q '阶段 1：Claude Code 规划与路线选择' assets/ai-templates/prompts-examples.md
grep -q '阶段 2：Codex 实施与检查' assets/ai-templates/prompts-examples.md
grep -q '阶段 3：Claude Code 独立审查' assets/ai-templates/prompts-examples.md
if grep -R -E -q '[[:alpha:]]:\\[^[:space:]<]' \
  SKILL.md README.md AGENTS.md CLAUDE.md agents assets references .ai; then
  echo 'FAIL: public docs or templates contain a Windows absolute path' >&2
  exit 1
fi
bash -n scripts/init_workflow.sh scripts/check.sh assets/check.sh

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT
bash scripts/init_workflow.sh "$tmp_dir" >/dev/null
printf '\nPRESERVE_EXISTING_FILE\n' >> "$tmp_dir/AGENTS.md"
bash scripts/init_workflow.sh "$tmp_dir" >/dev/null
grep -q 'PRESERVE_EXISTING_FILE' "$tmp_dir/AGENTS.md"
for path in AGENTS.md CLAUDE.md scripts/check.sh .ai/brief.md .ai/plan.md \
  .ai/review.md .ai/backlog.md .ai/decision-log.md \
  .ai/prompts-examples.md; do
  test -f "$tmp_dir/$path" || {
    echo "FAIL: scaffold did not create $path" >&2
    exit 1
  }
done

validator="${CODEX_HOME:-$HOME/.codex}/skills/.system/skill-creator/scripts/quick_validate.py"
if test -f "$validator"; then
  if command -v python >/dev/null 2>&1 && python -c 'import yaml' >/dev/null 2>&1; then
    python "$validator" .
  elif command -v python3 >/dev/null 2>&1 && python3 -c 'import yaml' >/dev/null 2>&1; then
    python3 "$validator" .
  elif command -v py >/dev/null 2>&1 && py -3 -c 'import yaml' >/dev/null 2>&1; then
    py -3 "$validator" .
  else
    echo "WARN: quick_validate.py found but no runnable Python with PyYAML is available"
  fi
else
  echo "INFO: optional skill-creator validator not installed"
fi

echo "== All checks passed =="
