#!/usr/bin/env bash
# PAPc SessionStart: print the core rulebook + global lessons as session context.
# Plain stdout on SessionStart is added to Claude's context. No model calls.
# Cap: PAPC_MAX_CHARS (default 6000) so the core can never bloat a session.
# Opt out for one session: PAPC_CORE=off

[ "${PAPC_CORE:-on}" = "off" ] && exit 0

ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"
MAX="${PAPC_MAX_CHARS:-6000}"
case "$MAX" in ''|*[!0-9]*) MAX=6000 ;; esac

out="$(
  cat "$ROOT/core/CORE.md" 2>/dev/null
  if [ -f "$ROOT/core/LESSONS.md" ]; then
    printf '\n'
    # Drop the HTML maintenance comment; keep the heading and the lesson lines.
    grep -v '^<!--' "$ROOT/core/LESSONS.md"
  fi
)"

[ -z "$out" ] && exit 0

if [ "${#out}" -gt "$MAX" ]; then
  printf '%s\n\n[papc: core+lessons truncated at %s chars - run /papc-doctor]\n' "${out:0:$MAX}" "$MAX"
else
  printf '%s\n' "$out"
fi
exit 0
