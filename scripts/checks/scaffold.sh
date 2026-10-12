#!/usr/bin/env bash
# Observable scaffold behavior; invoked only by scripts/check.sh.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/../.."
skill_dir="$PWD/skills/jiaojie"
task_tmp="$(mktemp -d)"
trap 'rm -rf "$task_tmp"' EXIT
project="$task_tmp/project with spaces"

bash "$skill_dir/scripts/init_workflow.sh" "$project" >/dev/null
test ! -e "$project/CLAUDE.md"
test -f "$project/.ai/index.md"
for name in sync-rules.md writing-rules.md anti-defensive-writing.md anti-defensive-writing.LICENSE; do
  cmp "$skill_dir/references/$name" "$project/references/$name"
  cmp "$skill_dir/references/$name" "references/$name"
done
test -f "$skill_dir/references/update-rules.md"
test ! -e "$project/out"
test ! -e "$project/assets/generated"

# Populate an existing project: reruns must retain every customized file.
for file in "$project/AGENTS.md" "$project/.ai/"*.md "$project/references/"* "$project/scripts/check.sh"; do
  printf '\nProject-specific content: %s\n' "${file#$project/}" >> "$file"
done
cp -R "$project" "$task_tmp/before"
bash "$skill_dir/scripts/init_workflow.sh" "$project" >/dev/null
diff -r "$task_tmp/before" "$project"

bash "$skill_dir/scripts/init_workflow.sh" --with-claude "$project" >/dev/null
cmp "$skill_dir/assets/CLAUDE.md" "$project/CLAUDE.md"
printf '\nProject-specific Claude instruction\n' >> "$project/CLAUDE.md"
cp "$project/CLAUDE.md" "$task_tmp/claude-before"
bash "$skill_dir/scripts/init_workflow.sh" "$project" --with-claude >/dev/null
cmp "$task_tmp/claude-before" "$project/CLAUDE.md"
bash "$skill_dir/scripts/init_workflow.sh" "$project" >/dev/null
cmp "$task_tmp/claude-before" "$project/CLAUDE.md"

if bash "$skill_dir/scripts/init_workflow.sh" --invalid "$task_tmp/invalid" >"$task_tmp/error" 2>&1; then
  echo 'FAIL: accepted an unknown initialization option' >&2
  exit 1
fi
test ! -e "$task_tmp/invalid"
echo '-- Scaffold defaults, optional Claude, and existing content preservation passed --'
