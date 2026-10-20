#!/usr/bin/env bash
# Create missing handoff files; shared project rules live in AGENTS.md.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"
ASSETS_DIR="$SKILL_DIR/assets"

usage() {
  echo "Usage: bash init_workflow.sh [project-directory] [--mode small|large] [--workflow name]... [--with-claude]"
  echo "Creates missing files. Existing files are preserved."
}

TARGET_DIR="."
target_set=0
with_claude=0
mode="small"
workflows=()
while [ "$#" -gt 0 ]; do
  case "$1" in
    --mode)
      if [ "$#" -lt 2 ] || [[ "$2" != small && "$2" != large ]]; then
        echo "--mode requires small or large" >&2; exit 2
      fi
      mode="$2"; shift
      ;;
    --workflow)
      if [ "$#" -lt 2 ] || [[ ! "$2" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]] || [ "${#2}" -gt 64 ]; then
        echo "--workflow requires a lowercase name of up to 64 letters, digits and hyphens" >&2; exit 2
      fi
      case "$2" in
        con|con.*|prn|prn.*|aux|aux.*|nul|nul.*|com[1-9]|com[1-9].*|lpt[1-9]|lpt[1-9].*)
          echo "Reserved workflow name: $2" >&2; exit 2 ;;
      esac
      duplicate=0
      for existing in "${workflows[@]}"; do
        if [ "$existing" = "$2" ]; then duplicate=1; fi
      done
      if [ "$duplicate" -eq 0 ]; then workflows+=("$2"); fi
      shift
      ;;
    --with-claude) with_claude=1 ;;
    --help|-h) usage; exit 0 ;;
    --*) echo "Unknown option: $1" >&2; usage >&2; exit 2 ;;
    *)
      if [ "$target_set" -eq 1 ]; then
        echo "Only one project directory is accepted" >&2
        exit 2
      fi
      TARGET_DIR="$1"
      target_set=1
      ;;
  esac
  shift
done

if [ "$mode" = small ] && [ "${#workflows[@]}" -gt 0 ]; then
  echo "--workflow requires --mode large" >&2; exit 2
fi
if [ ! -d "$ASSETS_DIR" ]; then
  echo "Missing skill assets: $ASSETS_DIR" >&2
  exit 1
fi
mkdir -p "$TARGET_DIR"
TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"
mkdir -p "$TARGET_DIR/.ai" "$TARGET_DIR/scripts" "$TARGET_DIR/references"

echo "Initializing Jiaojie ($mode): $TARGET_DIR"
copy_if_absent() {
  local src="$1" dest="$2"
  if [ -e "$dest" ] || [ -L "$dest" ]; then
    echo "Preserved: ${dest#$TARGET_DIR/}"
  else
    cp "$src" "$dest"
    echo "Created: ${dest#$TARGET_DIR/}"
  fi
}

copy_if_absent "$ASSETS_DIR/AGENTS.md" "$TARGET_DIR/AGENTS.md"
if [ "$with_claude" -eq 1 ]; then
  copy_if_absent "$ASSETS_DIR/CLAUDE.md" "$TARGET_DIR/CLAUDE.md"
fi
copy_if_absent "$ASSETS_DIR/scripts/check.sh" "$TARGET_DIR/scripts/check.sh"
if [ "$mode" = small ]; then
  for name in brief plan review backlog decision-log prompts-examples roster asset-manifest index; do
    copy_if_absent "$ASSETS_DIR/ai-templates/$name.md" "$TARGET_DIR/.ai/$name.md"
  done
else
  for name in brief plan index; do
    dest="$TARGET_DIR/.ai/$name.md"
    if [ -e "$dest" ] || [ -L "$dest" ]; then
      echo "Preserved: .ai/$name.md (merge workflow entries with Jiaojie)"
      continue
    fi
    cp "$ASSETS_DIR/large-templates/$name.md" "$dest"
    if [ "$name" = plan ] || [ "$name" = index ]; then
      for workflow in "${workflows[@]}"; do
        if [ "$name" = plan ]; then
          printf '| [%s](workflows/%s/plan.md) | 待规划 | 在局部计划填写下一步和真实依赖 |\n' "$workflow" "$workflow" >> "$dest"
        else
          printf '| %s | [brief](workflows/%s/brief.md) / [plan](workflows/%s/plan.md) | 待填写实际代码入口 | 按需创建后登记 |\n' "$workflow" "$workflow" "$workflow" >> "$dest"
        fi
      done
    fi
    echo "Created: .ai/$name.md"
  done
  for workflow in "${workflows[@]}"; do
    mkdir -p "$TARGET_DIR/.ai/workflows/$workflow"
    for name in brief plan; do
      dest="$TARGET_DIR/.ai/workflows/$workflow/$name.md"
      if [ -e "$dest" ] || [ -L "$dest" ]; then
        echo "Preserved: ${dest#$TARGET_DIR/}"
      else
        sed "s/__WORKFLOW__/$workflow/g" "$ASSETS_DIR/large-templates/workflow-$name.md" > "$dest"
        echo "Created: ${dest#$TARGET_DIR/}"
      fi
    done
  done
  mkdir -p "$TARGET_DIR/projects"
  copy_if_absent "$ASSETS_DIR/large-templates/gitignore" "$TARGET_DIR/.gitignore"
  copy_if_absent "$SKILL_DIR/references/project-architecture.md" "$TARGET_DIR/references/project-architecture.md"
  echo "Large mode: fill workflow documents and merge root summaries/index, AGENTS.md and /worktrees/ ignore rules."
  echo "Source, data, Git history and running jobs are not moved. Worktrees are created only when needed."
fi
for name in sync-rules.md writing-rules.md anti-defensive-writing.md anti-defensive-writing.LICENSE; do
  copy_if_absent "$SKILL_DIR/references/$name" "$TARGET_DIR/references/$name"
done

chmod +x "$TARGET_DIR/scripts/check.sh" 2>/dev/null || true
echo "Fill .ai/brief.md and .ai/index.md, then configure scripts/check.sh for the project."
if [ "$mode" = large ]; then
  echo "Fill each .ai/workflows/<name>/{brief,plan}.md and merge its summary into the global plan and index."
fi
echo "Default roles: Codex Astra plans/reviews; Codex Sol implements/fixes."
echo "For an existing project, ask Jiaojie to merge the latest rules using references/update-rules.md in the skill."
