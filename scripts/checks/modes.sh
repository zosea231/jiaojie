#!/usr/bin/env bash
# Behavior checks for large initialization, upgrade, and the documented worktree usage.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/../.."
skill_dir="$PWD/skills/jiaojie"
task_tmp="$(mktemp -d)"
trap 'rm -rf "$task_tmp"' EXIT

large="$task_tmp/large project"
bash "$skill_dir/scripts/init_workflow.sh" "$large" --mode large \
  --workflow data-generation --workflow prediction --workflow prediction >/dev/null
test -d "$large/projects"
test ! -e "$large/artifacts"
test ! -e "$large/worktrees"
test ! -e "$large/.git"
test ! -e "$large/.ai/review.md"
cmp "$skill_dir/references/project-architecture.md" "$large/references/project-architecture.md"
for workflow in data-generation prediction; do
  for name in brief plan; do
    test -s "$large/.ai/workflows/$workflow/$name.md"
  done
  # Links emitted in both global documents must resolve to the local files.
  for name in plan index; do
    grep -F -q "workflows/$workflow/plan.md" "$large/.ai/$name.md"
  done
done
test "$(grep -F -c '](workflows/prediction/plan.md)' "$large/.ai/plan.md")" -eq 1
cp -R "$large" "$task_tmp/large-before"
bash "$skill_dir/scripts/init_workflow.sh" --mode large "$large" --workflow prediction >/dev/null
diff -r "$task_tmp/large-before" "$large"

small="$task_tmp/small project"
bash "$skill_dir/scripts/init_workflow.sh" "$small" >/dev/null
test ! -e "$small/.ai/workflows"
test ! -e "$small/projects"
mkdir -p "$small/src" "$small/data"
printf 'user source\n' > "$small/src/model.py"
printf 'user dataset\n' > "$small/data/sample.bin"
printf '/user-data/\n' > "$small/.gitignore"
for file in "$small/AGENTS.md" "$small/.ai/"*.md "$small/references/"* "$small/scripts/check.sh"; do
  printf '\nCustomized project content\n' >> "$file"
done
cp -R "$small" "$task_tmp/small-before"
bash "$skill_dir/scripts/init_workflow.sh" "$small" --mode large --workflow prediction >/dev/null
# The upgrade supplements rather than overwrites every pre-existing file, including code/data.
while IFS= read -r -d '' original; do
  relative="${original#"$task_tmp/small-before/"}"
  cmp "$original" "$small/$relative"
done < <(find "$task_tmp/small-before" -type f -print0)
test -f "$small/.ai/workflows/prediction/plan.md"
test -f "$small/references/project-architecture.md"
printf '\nLocal accepted result\n' >> "$small/.ai/workflows/prediction/plan.md"
cp "$small/.ai/workflows/prediction/plan.md" "$task_tmp/local-before"
bash "$skill_dir/scripts/init_workflow.sh" "$small" --mode large --workflow prediction --workflow reports >/dev/null
cmp "$task_tmp/local-before" "$small/.ai/workflows/prediction/plan.md"
cmp "$task_tmp/small-before/.ai/plan.md" "$small/.ai/plan.md"
test -f "$small/.ai/workflows/reports/brief.md"

reject() {
  if bash "$skill_dir/scripts/init_workflow.sh" "$task_tmp/rejected" "$@" >"$task_tmp/error" 2>&1; then
    echo "FAIL: accepted invalid initialization arguments: $*" >&2; exit 1
  fi
  test ! -e "$task_tmp/rejected"
}
for invalid in ../escape BadName con con.txt COM1 lpt2.log 'bad name' '-leading' 'trailing-' ''; do
  reject --mode large --workflow "$invalid"
done
reject --workflow accidental
reject --mode medium
reject --mode
reject --mode large --workflow

# Exercise the documented worktree/branch progress mechanics in an isolated repository.
(
  cd "$large"
  git init -q
  git config core.autocrlf false
  git config commit.gpgsign false
  git config user.name 'Jiaojie test'
  git config user.email 'jiaojie-test@example.invalid'
  git add .
  git -c core.hooksPath=/dev/null commit -qm 'Initial project'
  git worktree add -q -b codex/data-generation worktrees/data-generation HEAD
  git check-ignore -q worktrees/data-generation/AGENTS.md
  test -f worktrees/data-generation/.ai/workflows/prediction/brief.md
  printf '\nCommitted workflow progress\n' >> worktrees/data-generation/.ai/workflows/data-generation/plan.md
  git -C worktrees/data-generation add .ai/workflows/data-generation/plan.md
  git -C worktrees/data-generation -c core.hooksPath=/dev/null commit -qm 'Update workflow progress'
  MSYS_NO_PATHCONV=1 git show codex/data-generation:.ai/workflows/data-generation/plan.md > "$task_tmp/branch-plan"
  cmp "$task_tmp/branch-plan" worktrees/data-generation/.ai/workflows/data-generation/plan.md
  if cmp -s .ai/workflows/data-generation/plan.md "$task_tmp/branch-plan"; then
    echo 'FAIL: worktree progress unexpectedly replaced the main checkout document' >&2; exit 1
  fi
  git worktree remove worktrees/data-generation
)
echo '-- Large scaffolding, lossless incremental upgrade, arguments, and worktree progress passed --'
