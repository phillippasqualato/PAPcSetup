#!/usr/bin/env bash
# Tests for papc-core hooks and doctor. Usage: bash tests/run.sh
set -u
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
H="$ROOT/plugins/papc-core/hooks"
export CLAUDE_PLUGIN_ROOT="$ROOT/plugins/papc-core"
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
export TMPDIR="$TMP"
pass=0; fail=0

check() { # name expected actual
  if [ "$2" = "$3" ]; then pass=$((pass+1)); else fail=$((fail+1)); echo "FAIL: $1 (expected $2, got $3)"; fi
}
bash_decision() {
  printf '{"tool_name":"Bash","tool_input":{"command":"%s","description":"x"}}' "$1" \
    | bash "$H/guard-bash.sh" | grep -oE '"permissionDecision":"[a-z]+"' | cut -d'"' -f4 | grep . || echo allow
}
edit_decision() {
  printf '{"tool_name":"Edit","tool_input":{"file_path":"%s"}}' "$1" \
    | bash "$H/protect-config.sh" | grep -oE '"permissionDecision":"[a-z]+"' | cut -d'"' -f4 | grep . || echo allow
}

# guard-bash
check "no-verify"            deny  "$(bash_decision 'git commit -m \"fix\" --no-verify')"
check "no-verify in message" allow "$(bash_decision 'git commit -m \"docs: never use --no-verify\"')"
check "hooksPath"            deny  "$(bash_decision 'git -c core.hooksPath=/dev/null commit -m x')"
check "force main"           deny  "$(bash_decision 'git push --force origin main')"
check "force +master"        deny  "$(bash_decision 'git push origin +master')"
check "force-with-lease main" deny "$(bash_decision 'git push --force-with-lease origin main')"
check "force feature"        allow "$(bash_decision 'git push -f origin feature/x')"
check "push main"            allow "$(bash_decision 'git push origin main')"
check "rm root"              deny  "$(bash_decision 'rm -rf /')"
check "rm home tilde"        deny  "$(bash_decision 'cd x; rm -fr ~')"
check "rm HOME var"          deny  "$(bash_decision 'rm -rf $HOME')"
check "rm node_modules"      allow "$(bash_decision 'rm -rf ./node_modules')"
check "rm tmp path"          allow "$(bash_decision 'rm -rf /tmp/foo')"
check "plain command"        allow "$(bash_decision 'npm test')"
check "multi-line force"     deny  "$(bash_decision 'cd repo\ngit push --force origin main')"
check "multi-line rm"        deny  "$(bash_decision 'cd /tmp\nrm -rf ~')"
check "commit -n"            deny  "$(bash_decision 'git commit -n -m x')"
check "commit -nm"           deny  "$(bash_decision 'git commit -nm x')"
check "push -n dry run"      allow "$(bash_decision 'git push -n origin main')"
check "commit --amend"       allow "$(bash_decision 'git commit --amend --no-edit')"
check "rm no-preserve-root"  deny  "$(bash_decision 'rm -rf --no-preserve-root /')"
check "rm split flags"       deny  "$(bash_decision 'rm -f -r /')"
check "rm double dash"       deny  "$(bash_decision 'rm -rf -- /')"
check "rm second target"     deny  "$(bash_decision 'rm -rf ./build ~')"
check "rm quoted HOME"       deny  "$(bash_decision 'rm -rf \"$HOME\"')"
check "rm HOME subdir"       allow "$(bash_decision 'rm -rf $HOME/tmp/cache')"
check "sudo rm root"         deny  "$(bash_decision 'sudo rm -rf /')"
check "rm non-recursive ~"   allow "$(bash_decision 'rm ~/file.txt')"
check "echo rm text"         allow "$(bash_decision 'echo \"rm -rf / is bad\"')"
check "git -C force main"    deny  "$(bash_decision 'git -C app push -f origin main')"
check "HEAD:main force"      deny  "$(bash_decision 'git push -f origin HEAD:main')"
check "empty payload"        allow "$(echo '{}' | bash "$H/guard-bash.sh"; echo allow)"

# protect-config
mkdir -p "$TMP/p/.husky"; touch "$TMP/p/eslint.config.mjs" "$TMP/p/app.ts" "$TMP/p/.husky/pre-commit" "$TMP/p/tsconfig.app.json"
check "existing eslint"      ask   "$(edit_decision "$TMP/p/eslint.config.mjs")"
check "tsconfig variant"     ask   "$(edit_decision "$TMP/p/tsconfig.app.json")"
check "husky hook"           ask   "$(edit_decision "$TMP/p/.husky/pre-commit")"
check "new config file"      allow "$(edit_decision "$TMP/p/.prettierrc")"
check "source file"          allow "$(edit_decision "$TMP/p/app.ts")"

# session-start
out="$(bash "$H/session-start.sh")"
check "core loaded"          yes "$(printf '%s' "$out" | grep -q 'PAPc core' && echo yes || echo no)"
check "lessons loaded"       yes "$(printf '%s' "$out" | grep -q 'PAPc lessons' && echo yes || echo no)"
check "comment stripped"     no  "$(printf '%s' "$out" | grep -q '<!--' && echo yes || echo no)"
check "cap respected"        yes "$([ "$(PAPC_MAX_CHARS=500 bash "$H/session-start.sh" | wc -c)" -lt 700 ] && echo yes || echo no)"
check "opt out"              0   "$(PAPC_CORE=off bash "$H/session-start.sh" | wc -c | tr -d ' ')"

# context-check
T="$TMP/t.jsonl"
printf '%s\n' '{"type":"assistant","message":{"usage":{"input_tokens":10,"cache_creation_input_tokens":1000,"cache_read_input_tokens":50000}}}' > "$T"
ctx() { printf '{"session_id":"s1","transcript_path":"%s"}' "$T" | bash "$H/context-check.sh" | wc -l | tr -d ' '; }
check "small context silent" 0 "$(ctx)"
echo '{"type":"assistant","message":{"usage":{"input_tokens":10,"cache_creation_input_tokens":1000,"cache_read_input_tokens":210000}}}' >> "$T"
check "large context nudges" 1 "$(ctx)"
check "no repeat same bucket" 0 "$(ctx)"
echo '{"type":"assistant","message":{"usage":{"input_tokens":10,"cache_creation_input_tokens":1000,"cache_read_input_tokens":320000}}}' >> "$T"
check "next bucket nudges"   1 "$(ctx)"
echo '{"type":"assistant","message":{"usage":{"input_tokens":10,"cache_creation_input_tokens":1000,"cache_read_input_tokens":40000}}}' >> "$T"
check "after compact silent" 0 "$(ctx)"
echo '{"type":"assistant","message":{"usage":{"input_tokens":10,"cache_creation_input_tokens":1000,"cache_read_input_tokens":220000}}}' >> "$T"
check "re-nudge after compact" 1 "$(ctx)"
check "missing transcript"   0 "$(echo '{"session_id":"x"}' | bash "$H/context-check.sh" | wc -l | tr -d ' ')"

# doctor runs and ends with a result line
check "doctor result"        yes "$(bash "$ROOT/plugins/papc-core/scripts/doctor.sh" "$ROOT" | tail -n 1 | grep -q 'Result' && echo yes || echo no)"

# json validity
for j in "$ROOT/.claude-plugin/marketplace.json" "$ROOT/plugins/papc-core/.claude-plugin/plugin.json" "$ROOT/plugins/papc-core/hooks/hooks.json"; do
  check "valid json $(basename "$j")" ok "$(python3 -c 'import json,sys; json.load(open(sys.argv[1])); print("ok")' "$j" 2>/dev/null || echo bad)"
done

echo "passed: $pass  failed: $fail"
[ "$fail" = 0 ]
