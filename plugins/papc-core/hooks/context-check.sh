#!/usr/bin/env bash
# PAPc UserPromptSubmit: when the conversation context is large, print ONE line
# (stdout on UserPromptSubmit becomes context) suggesting a compact/handoff at
# the next phase boundary. Silent otherwise. Re-nudges only after the context
# grows another PAPC_COMPACT_EVERY tokens.
# Idea from ECC suggest-compact.js (MIT): real context size from the last
# `usage` record in the transcript, not a tool-call count.

input="$(cat)"
flat="$(printf '%s' "$input" | tr '\n' ' ')"
transcript="$(printf '%s' "$flat" | sed -nE 's/.*"transcript_path"[[:space:]]*:[[:space:]]*"([^"]*)".*/\1/p')"
session="$(printf '%s' "$flat" | sed -nE 's/.*"session_id"[[:space:]]*:[[:space:]]*"([^"]*)".*/\1/p')"
[ -n "$transcript" ] && [ -f "$transcript" ] || exit 0

AT="${PAPC_COMPACT_AT:-200000}"; case "$AT" in ''|*[!0-9]*) AT=200000 ;; esac
EVERY="${PAPC_COMPACT_EVERY:-100000}"; case "$EVERY" in ''|*[!0-9]*|0) EVERY=100000 ;; esac
[ "$AT" -eq 0 ] && exit 0

usage_line="$(tail -n 400 "$transcript" 2>/dev/null | grep '"usage"' | tail -n 1)"
[ -z "$usage_line" ] && exit 0

num() { printf '%s' "$usage_line" | grep -oE "\"$1\"[[:space:]]*:[[:space:]]*[0-9]+" | head -n 1 | grep -oE '[0-9]+$'; }
a="$(num input_tokens)"; b="$(num cache_read_input_tokens)"; c="$(num cache_creation_input_tokens)"
total=$(( ${a:-0} + ${b:-0} + ${c:-0} ))

dir="${TMPDIR:-/tmp}"
safe="$(printf '%s' "${session:-unknown}" | tr -cd 'A-Za-z0-9_-')"
state="$dir/papc-ctx-$safe"

# Under the threshold (e.g. right after /compact): reset so the next climb nudges again.
if [ "$total" -lt "$AT" ]; then rm -f "$state" 2>/dev/null; exit 0; fi

bucket=$(( (total - AT) / EVERY ))
last="$(cat "$state" 2>/dev/null)"; case "$last" in ''|*[!0-9-]*) last=-1 ;; esac
[ "$bucket" -le "$last" ] && exit 0
printf '%s' "$bucket" > "$state" 2>/dev/null

# Housekeeping: drop state files older than 14 days.
find "$dir" -maxdepth 1 -name 'papc-ctx-*' -mtime +14 -delete 2>/dev/null

printf 'papc: context is ~%sk tokens. Finish the current step, then at the next phase boundary suggest to Phillip (in one line) to run /compact or start fresh with a product-studio:handoff note. Do not interrupt mid-task.\n' "$(( total / 1000 ))"
exit 0
