---
name: papc-doctor
description: Audit Phillip's Claude setup for duplicates, conflicting plugins, credit-burning hooks, skill-name collisions, oversized always-loaded context, stale lessons and secrets in config, then give a short fix list in Danish. Use when the user types "/papc-doctor", says the setup feels slow, expensive, confused or duplicated, after installing or removing any plugin, skill pack or MCP, or before trying something like ECC.
---

# PAPc doctor

Read-only. Never disable, delete or edit anything yourself here - produce the fix list; Phillip flips the switches.

1. Run the audit script (plain bash, no model calls):
   `bash "${CLAUDE_PLUGIN_ROOT}/scripts/doctor.sh" "$PWD"`
   If the variable is unset, find the script with `ls ~/.claude/plugins/cache/*/papc-core/*/scripts/doctor.sh` (Code tab) or run step 2 alone (Cowork may manage plugins outside `~/.claude`).
2. Cross-check with what is actually loaded: look at the skill and agent list in your own context. Any skill or agent that exists both as `product-studio:<name>` and under another plugin is a duplicate, even if the script missed it. Also flag any enabled plugin from the blocklist in PAPcSetup `docs/DEDUP.md` (superpowers, pr-review-toolkit, feature-dev, code-review, claude-md-management, claude-memory, security-guidance, frontend-design, engineering, productivity, ECC).
3. Report in Danish, max ~15 lines:
   - **Slå fra** (plugin → why, one line each). Where: the plugin settings in the Claude app (covers Cowork and synced uploads), or `/plugin` in Claude Code.
   - **Koster credits** (hooks that call a model or run on every tool call).
   - **Kontekst** (always-loaded files over budget; lessons over 25 or older than 90 days → suggest `/papc-learn review`).
   - **Sikkerhed** (literal secrets in config → move to env vars).
   - End with "Kør /papc-doctor igen bagefter".
4. If everything is clean, say so in one line.

Owner rule when two tools do the same job: product-studio owns product work, papc-core owns rules/guards/learning, business plugins (sales, data, design, canva, pendo, zapier, sanity, sp-global, amazon) own their domains. Everything else is a candidate to switch off.
