#!/usr/bin/env bash
# PAPc doctor: read-only audit of the Claude setup on this machine/session.
# Finds duplicate plugins, known conflicting plugins, costly hooks, skill-name
# collisions, oversized always-loaded context, stale lessons and secrets in config.
# Ideas from ECC context-budget + security-scan (MIT), rewritten as plain bash.
# Usage: bash doctor.sh [project-dir]

set -u
PROJECT="${1:-$PWD}"
HOME_CLAUDE="${HOME}/.claude"
CORE_ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"
SETTINGS="$HOME_CLAUDE/settings.json"

# Plugins whose job product-studio or papc-core already owns (see docs/DEDUP.md).
KNOWN_DUPES="superpowers pr-review-toolkit feature-dev code-review claude-md-management claude-memory security-guidance frontend-design engineering productivity ecc everything-claude-code mattpocock-skills agent-skills ralph-loop tdd-guard"

count_file="$(mktemp)"
say() { printf '%s\n' "$*"; }
# Count via a file so flags raised inside pipelines (subshells) are counted too.
flag() { echo x >> "$count_file"; printf -- '- [!] %s\n' "$*"; }

say "# PAPc doctor"
say ""
say "## 1. Installed plugins"

roots=""
for r in "$HOME_CLAUDE/plugins/cache" "$HOME_CLAUDE/plugins/marketplaces" "$HOME_CLAUDE/plugins/synced" "$HOME_CLAUDE/plugins/repos"; do
  [ -d "$r" ] && roots="$roots $r"
done
[ -n "$(dirname "$CORE_ROOT")" ] && roots="$roots $(dirname "$CORE_ROOT")"

manifests="$(for r in $roots; do find "$r" -maxdepth 6 -path '*/.claude-plugin/plugin.json' 2>/dev/null; done | sort -u)"
if [ -z "$manifests" ]; then
  say "No plugin manifests found under ~/.claude/plugins. (In Cowork, plugins may be managed by the app; compare with the skill list in your context.)"
fi

names_file="$(mktemp)"; skills_file="$(mktemp)"
trap 'rm -f "$names_file" "$skills_file" "$count_file"' EXIT

enabled_state() {
  # prints enabled/disabled/unknown from ~/.claude/settings.json enabledPlugins
  n="$1"
  [ -f "$SETTINGS" ] || { echo unknown; return; }
  if grep -Eq "\"$n@[^\"]*\"[[:space:]]*:[[:space:]]*false" "$SETTINGS"; then echo disabled
  elif grep -Eq "\"$n@[^\"]*\"[[:space:]]*:[[:space:]]*true" "$SETTINGS"; then echo enabled
  else echo unknown; fi
}

stale=0
synced_active() {
  # Cowork/claude.ai sync: a plugin folder is active only if its server id is in
  # the folder's manifest.json. Folders of switched-off plugins stay on disk as cache.
  d="$1"; parent="$(dirname "$d")"
  [ -f "$parent/manifest.json" ] || return 0
  meta="$d.meta.json"
  [ -f "$meta" ] || return 0
  id="$(grep -oE '"server_plugin_id"[[:space:]]*:[[:space:]]*"[^"]*"' "$meta" | head -n 1 | sed -E 's/.*"([^"]*)"$/\1/')"
  [ -z "$id" ] && return 0
  grep -q "\"$id\"" "$parent/manifest.json"
}

for m in $manifests; do
  dir="$(dirname "$(dirname "$m")")"
  # First "name" key in the file = the plugin's own name (author/owner names come later).
  name="$(grep -oE '"name"[[:space:]]*:[[:space:]]*"[^"]*"' "$m" | head -n 1 | sed -E 's/.*"([^"]*)"$/\1/')"
  [ -z "$name" ] && continue
  if ! synced_active "$dir"; then stale=$((stale+1)); continue; fi
  # Skip old cached versions: keep only the newest dir per plugin name+parent.
  echo "$name|$dir" >> "$names_file"
done

say ""
say "| plugin | copies | skills (auto/manual) | agents | hooks | state |"
say "|---|---|---|---|---|---|"
for name in $(cut -d'|' -f1 "$names_file" | sort -u); do
  dirs="$(grep "^$name|" "$names_file" | cut -d'|' -f2)"
  copies="$(printf '%s\n' "$dirs" | wc -l | tr -d ' ')"
  dir="$(printf '%s\n' "$dirs" | while read -r d; do printf '%s %s\n' "$(stat -c %Y "$d" 2>/dev/null || stat -f %m "$d" 2>/dev/null || echo 0)" "$d"; done | sort -rn | head -n 1 | cut -d' ' -f2-)"
  sk=0; man=0
  if [ -d "$dir/skills" ]; then
    for s in "$dir"/skills/*/SKILL.md; do
      [ -f "$s" ] || continue
      sk=$((sk+1))
      grep -Eq '^(disable-model-invocation:[[:space:]]*true|user-invocable:[[:space:]]*false)' "$s" && man=$((man+1))
      echo "$(basename "$(dirname "$s")")|$name" >> "$skills_file"
    done
  fi
  ag="$(ls "$dir"/agents/*.md 2>/dev/null | wc -l | tr -d ' ')"
  hk="-"
  if [ -f "$dir/hooks/hooks.json" ]; then
    hk="$(grep -oE '"(SessionStart|UserPromptSubmit|PreToolUse|PostToolUse|Stop|SubagentStop|PreCompact|SessionEnd|Notification)"' "$dir/hooks/hooks.json" | tr -d '"' | sort -u | tr '\n' ' ')"
  fi
  st="$(enabled_state "$name")"
  say "| $name | $copies | $((sk-man))/$man | $ag | $hk | $st |"

  # Where copies differ in parent (e.g. marketplace + synced upload), that is a real duplicate.
  parents="$(printf '%s\n' "$dirs" | sed -E 's#/(cache|marketplaces|synced|repos)/.*#/\1#' | sort -u | wc -l | tr -d ' ')"
  [ "$parents" -gt 1 ] && flag "$name is installed through $parents channels (e.g. marketplace + upload). Keep one."
  for d in $KNOWN_DUPES; do
    [ "$name" = "$d" ] && [ "$st" != "disabled" ] && flag "$name overlaps product-studio/papc-core (PAPcSetup docs/DEDUP.md). Disable it."
  done
  if [ -f "$dir/hooks/hooks.json" ]; then
    if grep -rEqs 'claude -p|claude --model|api\.anthropic\.com|llm_review|review_api' "$dir/hooks" 2>/dev/null; then
      [ "$st" != "disabled" ] && flag "$name has hooks that call a model (costs credits on every trigger)."
    fi
    if grep -Eq '"matcher"[[:space:]]*:[[:space:]]*"\.\*"' "$dir/hooks/hooks.json"; then
      [ "$st" != "disabled" ] && flag "$name runs hooks on EVERY tool call (matcher .*): latency on each step."
    fi
  fi
done

[ "$stale" -gt 0 ] && say "" && say "($stale switched-off plugin folder(s) still cached on disk were ignored - they do not load.)"
say ""
say "## 2. Skill name collisions (same name in two plugins)"
coll="$(cut -d'|' -f1 "$skills_file" | sort | uniq -d)"
if [ -z "$coll" ]; then say "None."; else
  # Group per plugin pair so the report stays short.
  for c in $coll; do
    owners="$(grep "^$c|" "$skills_file" | cut -d'|' -f2 | sort -u | tr '\n' ' ' | sed 's/ $//')"
    [ "$(printf '%s' "$owners" | wc -w | tr -d ' ')" -gt 1 ] && printf '%s|%s\n' "$owners" "$c"
  done | sort | awk -F'|' '{ if ($1 != prev) { if (prev != "") print prev "|" list; prev=$1; list=$2 } else list=list ", " $2 } END { if (prev != "") print prev "|" list }' |
  while IFS='|' read -r owners list; do
    flag "same skill names in [$owners]: $list"
  done
fi
say ""
say "## 3. Always-loaded context"
core_chars="$(cat "$CORE_ROOT/core/CORE.md" "$CORE_ROOT/core/LESSONS.md" 2>/dev/null | wc -c | tr -d ' ')"
say "- papc core + lessons: ${core_chars} chars (cap ${PAPC_MAX_CHARS:-6000})"
[ "${core_chars:-0}" -gt "${PAPC_MAX_CHARS:-6000}" ] && flag "core + lessons exceed the cap - merge or retire lessons."
for f in "$HOME_CLAUDE/CLAUDE.md" "$PROJECT/CLAUDE.md" "$PROJECT/AGENTS.md"; do
  [ -f "$f" ] || continue
  c="$(wc -c < "$f" | tr -d ' ')"
  say "- $f: $c chars"
  [ "$c" -gt 12000 ] && flag "$f is large (>12k chars) and loads every session - trim it."
done

say ""
say "## 4. Lessons"
L="$CORE_ROOT/core/LESSONS.md"
if [ -f "$L" ]; then
  n="$(grep -c '^- [0-9]' "$L" | tr -d ' ')"
  say "- global lessons: $n / 25"
  [ "$n" -gt 25 ] && flag "more than 25 global lessons - merge or retire."
  cutoff="$(date -d '-90 days' +%Y-%m-%d 2>/dev/null || date -v-90d +%Y-%m-%d 2>/dev/null)"
  if [ -n "$cutoff" ]; then
    old="$(grep -E '^- [0-9]{4}-[0-9]{2}-[0-9]{2}' "$L" | awk -v c="$cutoff" '{ if ($2 < c) print }' | wc -l | tr -d ' ')"
    [ "$old" -gt 0 ] && flag "$old lesson(s) older than 90 days - review: still true? still needed?"
  fi
fi

say ""
say "## 5. Secrets in config (names only, values never printed)"
found=0
for f in "$SETTINGS" "$HOME_CLAUDE/settings.local.json" "$HOME/.claude.json" "$PROJECT/.mcp.json" "$PROJECT/.claude/settings.json" "$PROJECT/.claude/settings.local.json"; do
  [ -f "$f" ] || continue
  if grep -Eq '(sk-[A-Za-z0-9_-]{20,}|ghp_[A-Za-z0-9]{20,}|github_pat_[A-Za-z0-9_]{20,}|sbp_[A-Za-z0-9]{20,}|xox[bp]-[A-Za-z0-9-]{10,}|AKIA[0-9A-Z]{16}|eyJhbGciOi[A-Za-z0-9._-]{40,})' "$f"; then
    flag "$f contains what looks like a literal secret. Move it to an env var."
    found=1
  fi
done
[ "$found" = 0 ] && say "None found."

warn="$(wc -l < "$count_file" | tr -d ' ')"
say ""
if [ "$warn" = 0 ]; then say "**Result: clean.**"; else say "**Result: $warn issue(s).** Fix from the top; re-run /papc-doctor."; fi
exit 0
