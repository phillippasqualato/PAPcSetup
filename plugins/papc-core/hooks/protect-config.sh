#!/usr/bin/env bash
# PAPc PreToolUse(Edit|Write|MultiEdit): ask Phillip before an EXISTING
# lint/format/type-check config is changed. Agents often loosen these to make
# checks pass instead of fixing the code. Creating a new config is allowed.
# Idea from ECC config-protection.js (MIT), rewritten as a small bash check.

input="$(cat)"
path="$(printf '%s' "$input" | tr '\n' ' ' | sed -nE 's/.*"file_path"[[:space:]]*:[[:space:]]*"(([^"\\]|\\.)*)".*/\1/p')"
[ -z "$path" ] && exit 0
[ -f "$path" ] || exit 0

name="$(basename "$path")"
case "$name" in
  .eslintrc|.eslintrc.js|.eslintrc.cjs|.eslintrc.json|.eslintrc.yml|.eslintrc.yaml|\
  eslint.config.js|eslint.config.mjs|eslint.config.cjs|eslint.config.ts|eslint.config.mts|\
  .prettierrc|.prettierrc.js|.prettierrc.cjs|.prettierrc.json|.prettierrc.yml|.prettierrc.yaml|\
  prettier.config.js|prettier.config.cjs|prettier.config.mjs|\
  biome.json|biome.jsonc|.ruff.toml|ruff.toml|.stylelintrc|.stylelintrc.json|\
  .markdownlint.json|.markdownlint.yaml|tsconfig.json|tsconfig.*.json|\
  vitest.config.ts|vitest.config.js|jest.config.js|jest.config.ts|playwright.config.ts|\
  .semgrep.yml|.gitleaks.toml|lefthook.yml)
    hit=1 ;;
esac
case "$path" in
  */.husky/*|*/.git/hooks/*) hit=1 ;;
esac
if [ "${hit:-0}" = 1 ]; then
    printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"ask","permissionDecisionReason":"papc: %s is a lint/test/type config. Changing it can hide real errors - approve only if the change is intended, not to make a check pass."}}\n' "$name"
fi
exit 0
