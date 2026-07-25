#!/usr/bin/env bash
# PreToolUse hook: deny any tool call that touches a global/system temp directory.
#
# Rationale: scratch files, intermediate outputs and working files should live
# inside the current project/repository, not in system temp. This keeps work
# discoverable, reviewable and cleaned up with the repo instead of leaking into
# /tmp, /var/folders, $TMPDIR, etc.
#
# Reads the PreToolUse hook payload on stdin and, when a forbidden path is
# detected, emits a JSON deny decision. Silence (exit 0, no output) = allow.

input=$(cat)
tool=$(printf '%s' "$input" | jq -r '.tool_name // empty')

# Pick the field(s) worth inspecting for this tool.
target=""
case "$tool" in
    Write | Edit | MultiEdit | Read)
        target=$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty')
        ;;
    NotebookEdit)
        target=$(printf '%s' "$input" | jq -r '.tool_input.notebook_path // empty')
        ;;
    Glob | Grep)
        target=$(printf '%s' "$input" | jq -r '.tool_input.path // empty')
        ;;
    Bash)
        target=$(printf '%s' "$input" | jq -r '.tool_input.command // empty')
        ;;
    *)
        exit 0
        ;;
esac

[ -z "$target" ] && exit 0

# Absolute global/system temp locations. Anchored to a path boundary (start,
# whitespace, quote, =, :, redirection, etc.) so a repo-relative "./tmp" or
# "src/tmp/foo" is NOT matched -- only true system temp paths are.
tmp_re='(^|[[:space:]"'\''=:(><&|])(/tmp|/var/tmp|/usr/tmp|/private/tmp|/private/var/tmp|/dev/shm|/var/folders|/private/var/folders)([/[:space:]"'\'':;,)&|]|$)'

# Bash commands may reference temp via env vars instead of a literal path.
env_re='\$\{?(TMPDIR|TMPPREFIX|TMP|TEMP)\}?'

if printf '%s' "$target" | grep -qE "$tmp_re" \
    || printf '%s' "$target" | grep -qE "$env_re"; then
    cat <<'JSON'
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"Access to global/system temp directories (/tmp, /var/tmp, /private/tmp, /var/folders, /dev/shm, $TMPDIR, etc.) is forbidden. Do not read, write, glob, or run shell commands against system temp. Keep all scratch files, intermediate outputs and working files inside the current project/repository -- e.g. a ./tmp or ./.scratch directory under the working directory -- and act inside the repo at all times."}}}
JSON
fi

exit 0
