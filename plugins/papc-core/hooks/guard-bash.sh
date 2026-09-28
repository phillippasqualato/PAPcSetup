#!/usr/bin/env bash
# PAPc PreToolUse(Bash) guard. Denies three things agents do to "make it pass":
#   1. skipping git hooks (--no-verify, commit -n, core.hooksPath=)
#   2. force-pushing to main/master
#   3. recursive delete of /, ~ or $HOME
# Idea from ECC block-no-verify.js (MIT), rewritten as a small bash check.
# Portable to bash 3.2 + BSD tools. Never fails closed: any parsing problem -> allow.

set -f   # no globbing when splitting words

input="$(cat)"

# Pull tool_input.command out of the hook JSON (escaped quotes allowed).
cmd="$(printf '%s' "$input" | tr '\n' ' ' | sed -nE 's/.*"command"[[:space:]]*:[[:space:]]*"(([^"\\]|\\.)*)".*/\1/p')"
[ -z "$cmd" ] && exit 0

# JSON escapes for line breaks/tabs become command separators/spaces, so a
# multi-line script is checked line by line.
cmd="$(printf '%s' "$cmd" | sed -e 's/\\[nr]/; /g' -e 's/\\t/ /g')"

deny() {
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"%s"}}\n' "$1"
  exit 0
}

# Split into simple commands on ; & | ( ) { } ` and newlines.
segments() { printf '%s\n' "$1" | tr ';&|(){}`' '\n\n\n\n\n\n\n\n'; }

# --- git: quoted text (commit messages, echo strings) is removed first -------
bare="$(printf '%s' "$cmd" | sed -E 's/\\"([^\\]|\\[^"])*\\"//g' | sed -E "s/'[^']*'//g")"

while IFS= read -r seg; do
  # shellcheck disable=SC2086
  set -- $seg
  # Skip prefixes (sudo, env assignments, command) until the program word.
  while [ $# -gt 0 ]; do
    case "$1" in sudo|command|env|nohup|time|*=*) shift ;; *) break ;; esac
  done
  [ $# -gt 0 ] || continue
  case "$1" in git|*/git) ;; *) continue ;; esac
  shift
  for w in "$@"; do
    case "$w" in --no-verify|*core.hooksPath=*|*core.hookspath=*)
      deny "papc: skipping git hooks is blocked. Fix what the hook reports instead. If Phillip explicitly wants to skip them, he runs the command himself." ;;
    esac
  done
  # Find the subcommand (skip -c key=val / -C dir).
  sub=""; skip=0
  for w in "$@"; do
    if [ "$skip" = 1 ]; then skip=0; continue; fi
    case "$w" in -c|-C) skip=1 ;; -*) ;; *) sub="$w"; break ;; esac
  done
  if [ "$sub" = "commit" ]; then
    for w in "$@"; do
      case "$w" in --*) ;; -*n*) deny "papc: 'git commit -n' skips git hooks and is blocked. Fix what the hook reports instead." ;; esac
    done
  fi
  if [ "$sub" = "push" ]; then
    force=0; main=0
    for w in "$@"; do
      case "$w" in
        --force|--force-with-lease|--force-with-lease=*|--force-if-includes) force=1 ;;
        --*) ;;
        -*f*) force=1 ;;
        +*) force=1 ;;
      esac
      case "$w" in main|master|+main|+master|refs/heads/main|refs/heads/master|*:main|*:master|*:refs/heads/main|*:refs/heads/master) main=1 ;; esac
    done
    [ "$force" = 1 ] && [ "$main" = 1 ] && deny "papc: force-push to main/master is blocked. Push a branch and open a PR."
  fi
done <<EOF
$(segments "$bare")
EOF

# --- rm: quote characters removed (the words inside them are kept) -----------
dq="$(printf '%s' "$cmd" | sed -e 's/\\"//g' -e "s/'//g" -e 's/"//g')"

while IFS= read -r seg; do
  # shellcheck disable=SC2086
  set -- $seg
  while [ $# -gt 0 ]; do
    case "$1" in sudo|command|env|nohup|time|*=*) shift ;; *) break ;; esac
  done
  [ $# -gt 0 ] || continue
  case "$1" in rm|*/rm) ;; *) continue ;; esac
  shift
  rec=0; opts=1; hit=0
  for w in "$@"; do
    if [ "$opts" = 1 ]; then
      case "$w" in
        --) opts=0; continue ;;
        --recursive) rec=1; continue ;;
        --*) continue ;;
        -*[rR]*) rec=1; continue ;;
        -*) continue ;;
      esac
    fi
    case "$w" in
      /|/\*|//|\~|\~/|\~/\*|\$HOME|\$HOME/|\$HOME/\*|\$\{HOME\}|\$\{HOME\}/|\$\{HOME\}/\*) hit=1 ;;
    esac
  done
  [ "$rec" = 1 ] && [ "$hit" = 1 ] && deny "papc: recursive delete of /, ~ or \$HOME is blocked."
done <<EOF
$(segments "$dq")
EOF

exit 0
