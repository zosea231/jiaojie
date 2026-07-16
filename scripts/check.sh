#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."

echo "== Checking agent-workplace-init =="

skill_dir="skills/agent-workplace-init"

required=(
  README.md LICENSE AGENTS.md CLAUDE.md scripts/check.sh
  "$skill_dir/SKILL.md" "$skill_dir/agents/openai.yaml"
  "$skill_dir/scripts/init_workflow.sh"
  "$skill_dir/references/rules.md"
  "$skill_dir/assets/AGENTS.md" "$skill_dir/assets/CLAUDE.md"
  "$skill_dir/assets/scripts/check.sh"
  "$skill_dir/assets/ai-templates/brief.md"
  "$skill_dir/assets/ai-templates/plan.md"
  "$skill_dir/assets/ai-templates/review.md"
  "$skill_dir/assets/ai-templates/backlog.md"
  "$skill_dir/assets/ai-templates/decision-log.md"
  "$skill_dir/assets/ai-templates/prompts-examples.md"
  .ai/brief.md .ai/plan.md .ai/review.md .ai/backlog.md
  .ai/decision-log.md .ai/prompts-examples.md
)

for path in "${required[@]}"; do
  test -f "$path" || { echo "FAIL: missing $path" >&2; exit 1; }
done

test ! -e agent-workplace-init.zip || {
  echo "FAIL: generated ZIP should not be committed at repository root" >&2
  exit 1
}
test ! -e "$skill_dir/assets/check.sh" || {
  echo "FAIL: check template must live at assets/scripts/check.sh" >&2
  exit 1
}

cmp -s AGENTS.md "$skill_dir/assets/AGENTS.md" || {
  echo "FAIL: AGENTS.md and its scaffold template differ" >&2
  exit 1
}
cmp -s CLAUDE.md "$skill_dir/assets/CLAUDE.md" || {
  echo "FAIL: CLAUDE.md and its scaffold template differ" >&2
  exit 1
}
for name in brief plan review backlog decision-log prompts-examples; do
  cmp -s ".ai/$name.md" "$skill_dir/assets/ai-templates/$name.md" || {
    echo "FAIL: .ai/$name.md is not in the clean initial template state" >&2
    exit 1
  }
done

grep -q '^name: agent-workplace-init$' "$skill_dir/SKILL.md"
grep -q '^description:' "$skill_dir/SKILL.md"
grep -q 'display_name: "Agent Workplace Init"' "$skill_dir/agents/openai.yaml"
grep -q '\$agent-workplace-init' "$skill_dir/agents/openai.yaml"
grep -q 'Three-strike circuit breaker' "$skill_dir/SKILL.md"
grep -q '声学定位算法改进' "$skill_dir/assets/ai-templates/prompts-examples.md"
grep -q 'Stage 1 — Claude Code: plan and choose the route' "$skill_dir/SKILL.md"
grep -q 'Stage 2 — Codex: implement and check' "$skill_dir/SKILL.md"
grep -q 'Stage 3 — Claude Code: review independently' "$skill_dir/SKILL.md"
grep -q '阶段 1：Claude Code 规划与路线选择' "$skill_dir/assets/ai-templates/prompts-examples.md"
grep -q '阶段 2：Codex 实施与检查' "$skill_dir/assets/ai-templates/prompts-examples.md"
grep -q '阶段 3：Claude Code 独立审查' "$skill_dir/assets/ai-templates/prompts-examples.md"

if grep -R -E -q '[[:alpha:]]:\\[^[:space:]<]' README.md AGENTS.md CLAUDE.md skills .ai; then
  echo 'FAIL: public docs or templates contain a Windows absolute path' >&2
  exit 1
fi

bash -n "$skill_dir/scripts/init_workflow.sh" scripts/check.sh \
  "$skill_dir/assets/scripts/check.sh"

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT
bash "$skill_dir/scripts/init_workflow.sh" "$tmp_dir" >/dev/null
printf '\nPRESERVE_EXISTING_FILE\n' >> "$tmp_dir/AGENTS.md"
bash "$skill_dir/scripts/init_workflow.sh" "$tmp_dir" >/dev/null
grep -q 'PRESERVE_EXISTING_FILE' "$tmp_dir/AGENTS.md"
for path in AGENTS.md CLAUDE.md scripts/check.sh .ai/brief.md .ai/plan.md \
  .ai/review.md .ai/backlog.md .ai/decision-log.md \
  .ai/prompts-examples.md; do
  test -f "$tmp_dir/$path" || {
    echo "FAIL: scaffold did not create $path" >&2
    exit 1
  }
done
test ! -e "$tmp_dir/src" || {
  echo "FAIL: scaffold created unrelated src/ directory" >&2
  exit 1
}

validator="${CODEX_HOME:-$HOME/.codex}/skills/.system/skill-creator/scripts/quick_validate.py"
if test -f "$validator"; then
  if command -v python >/dev/null 2>&1 && python -c 'import yaml' >/dev/null 2>&1; then
    python "$validator" "$skill_dir"
  elif command -v python3 >/dev/null 2>&1 && python3 -c 'import yaml' >/dev/null 2>&1; then
    python3 "$validator" "$skill_dir"
  elif command -v py >/dev/null 2>&1 && py -3 -c 'import yaml' >/dev/null 2>&1; then
    py -3 "$validator" "$skill_dir"
  else
    echo "WARN: quick_validate.py found but no runnable Python with PyYAML is available"
  fi
else
  echo "INFO: optional skill-creator validator not installed"
fi

echo "== All checks passed =="
