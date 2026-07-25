#!/bin/bash
#
# Blocks ALL git operations that modify state (commit, push, pull, fetch, merge,
# rebase, reset, checkout/switch, restore, stash, clean, branch create/delete,
# add, rm, mv, tag create/delete, cherry-pick, revert, config set, gc, worktree
# add/remove, etc.). Read-only git commands are allowed.
#
# When a write is blocked, Claude is told to ask the user to run it and to
# suggest the exact command instead of doing it itself.

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Cheap pre-filter: nothing to do if there's no `git` token at all.
if ! echo "$COMMAND" | grep -qE '(^|[^A-Za-z.])git([[:space:]]|$)'; then
  exit 0
fi

block() {
  local reason="$1"
  cat >&2 <<EOF
BLOCKED: git write operations are disabled for you.

Command:  $COMMAND
Reason:   $reason

You (Claude) do NOT have authority to run git commands that change repository
state. This includes: commit, push, pull, fetch, merge, rebase, reset,
checkout/switch, restore, stash, clean, add, rm, mv, branch create/delete/rename,
tag create/delete, cherry-pick, revert, apply/am, config (set), gc, worktree
add/remove, submodule update, and similar.

DO NOT try a workaround. Instead, ask the user to run it themselves and suggest
the exact command, e.g.:

    Please run this yourself:
        $COMMAND

Only read-only git commands (status, log, diff, show, branch --list, remote -v,
stash list, config --get, ...) are allowed for you.
EOF
  exit 2
}

# Read-only git subcommands that are always safe.
READ_ONLY=" status log diff show blame reflog shortlog describe rev-parse rev-list \
ls-files ls-remote ls-tree cat-file whatchanged grep show-branch show-ref var help \
version name-rev merge-base diff-tree diff-index diff-files cherry annotate fsck \
count-objects verify-commit verify-tag "

# First non-flag token in a space-separated arg string ("" if none).
first_positional() {
  echo "$1" | tr ' ' '\n' | grep -vE '^-' | grep -vE '^$' | head -n1
}

# Split the command line on shell separators so each git invocation is checked
# independently (handles `git add . && git commit`, `git log | head`, etc.).
SEGMENTS=$(echo "$COMMAND" | tr ';&|()' '\n')

while IFS= read -r seg; do
  # Trim leading whitespace.
  seg=$(echo "$seg" | sed -E 's/^[[:space:]]+//')
  # Strip leading env-var assignments (FOO=bar) and common command prefixes so
  # `GIT_DIR=x git commit` / `sudo git push` are still recognized as git.
  seg=$(echo "$seg" | sed -E 's/^([A-Za-z_][A-Za-z0-9_]*=[^[:space:]]*[[:space:]]+)*//')
  seg=$(echo "$seg" | sed -E 's/^(sudo|env|command|time|nice|nohup)[[:space:]]+//')

  # The segment must START with git — this avoids false positives on quoted
  # text like `echo 'git push is blocked'`.
  case "$seg" in
    git|git[[:space:]]*) ;;
    *) continue ;;
  esac

  rest=$(echo "$seg" | sed -E 's/^git[[:space:]]*//')

  # Walk tokens: skip git global options (-C/-c consume the next token); the
  # first bare token is the subcommand, everything after it is its arguments.
  subcmd=""
  args=""
  skip_next=0
  found=0
  for tok in $rest; do
    if [ "$found" -eq 1 ]; then args="$args $tok"; continue; fi
    if [ "$skip_next" -eq 1 ]; then skip_next=0; continue; fi
    case "$tok" in
      -C|-c|--namespace|--git-dir|--work-tree|--exec-path)
        skip_next=1; continue ;;
      -*)
        continue ;;
      *)
        subcmd="$tok"; found=1 ;;
    esac
  done

  # Bare `git` (no subcommand) just prints help — allow.
  [ -z "$subcmd" ] && continue

  # Always-safe read-only subcommands.
  case "$READ_ONLY" in
    *" $subcmd "*) continue ;;
  esac

  # Dual-use subcommands: allow only their read-only forms.
  case "$subcmd" in
    branch)
      if echo " $args " | grep -qE ' -(d|D|m|M|c|C|f|u) | --(delete|move|copy|force|edit-description|set-upstream-to|unset-upstream|create-reflog) '; then
        block "git branch with a write flag modifies refs"
      fi
      pos=$(first_positional "$args")
      if [ -n "$pos" ] && ! echo " $args " | grep -qE ' (-l|--list) '; then
        block "git branch <name> creates a branch"
      fi
      continue ;;
    tag)
      if echo " $args " | grep -qE ' -(d|a|s|m|f) | --(delete|annotate|sign|force) '; then
        block "git tag create/delete modifies refs"
      fi
      pos=$(first_positional "$args")
      if [ -n "$pos" ] && ! echo " $args " | grep -qE ' (-l|--list|-n) '; then
        block "git tag <name> creates a tag"
      fi
      continue ;;
    remote)
      nxt=$(first_positional "$args")
      case "$nxt" in
        ""|show|get-url) continue ;;
        *) block "git remote $nxt modifies remotes" ;;
      esac ;;
    config)
      if echo " $args " | grep -qE ' (--get|--get-all|--get-regexp|--get-urlmatch|-l|--list) '; then
        continue
      fi
      block "git config without --get/--list writes configuration" ;;
    stash)
      nxt=$(first_positional "$args")
      case "$nxt" in
        show|list) continue ;;
        *) block "git stash modifies the working tree / stash" ;;
      esac ;;
    worktree)
      nxt=$(first_positional "$args")
      case "$nxt" in
        list) continue ;;
        *) block "git worktree $nxt modifies worktrees" ;;
      esac ;;
    submodule)
      nxt=$(first_positional "$args")
      case "$nxt" in
        status|summary) continue ;;
        *) block "git submodule $nxt modifies submodules" ;;
      esac ;;
  esac

  # Everything else (commit, push, pull, fetch, merge, rebase, reset, checkout,
  # switch, restore, clean, add, rm, mv, cherry-pick, revert, apply, am, gc,
  # prune, and any unknown subcommand) is treated as a write and blocked.
  block "git $subcmd is a state-modifying (or unrecognized) command"
done <<EOF
$SEGMENTS
EOF

exit 0
