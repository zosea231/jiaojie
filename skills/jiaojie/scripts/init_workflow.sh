#!/usr/bin/env bash
# Create missing handoff files; shared project rules live in AGENTS.md.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"
ASSETS_DIR="$SKILL_DIR/assets"

usage() {
  echo "Usage: bash init_workflow.sh [project-directory] [--with-claude]"
  echo "Creates missing files. Existing files are preserved."
}

TARGET_DIR="."
target_set=0
with_claude=0
while [ "$#" -gt 0 ]; do
  case "$1" in
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

if [ ! -d "$ASSETS_DIR" ]; then
  echo "Missing skill assets: $ASSETS_DIR" >&2
  exit 1
fi
mkdir -p "$TARGET_DIR"
TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"
mkdir -p "$TARGET_DIR/.ai" "$TARGET_DIR/scripts" "$TARGET_DIR/references"

echo "Initializing Jiaojie: $TARGET_DIR"
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
for name in brief plan review backlog decision-log prompts-examples roster asset-manifest index; do
  copy_if_absent "$ASSETS_DIR/ai-templates/$name.md" "$TARGET_DIR/.ai/$name.md"
done
for name in sync-rules.md writing-rules.md anti-defensive-writing.md anti-defensive-writing.LICENSE; do
  copy_if_absent "$SKILL_DIR/references/$name" "$TARGET_DIR/references/$name"
done

chmod +x "$TARGET_DIR/scripts/check.sh" 2>/dev/null || true
echo "Fill .ai/brief.md and .ai/index.md, then configure scripts/check.sh for the project."
echo "Default roles: Codex Astra plans/reviews; Codex Sol implements/fixes."
echo "For an existing project, ask Jiaojie to merge the latest rules using references/update-rules.md in the skill."
