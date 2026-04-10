#!/usr/bin/env zsh
# claude.plugin.zsh — Inline Claude Code assistance via fzf
#
# Press Ctrl+P (configurable) to open a prompt, type a natural-language
# request, and get a shell command or short answer from Claude.  All
# terminal UI is handled by fzf — no escape sequences, stty, or manual
# input loops.

# ── Configuration ────────────────────────────────────────────────────
# All settings are read at invocation time via ${VAR:-default}.
# Export any of these to override:
#   CLAUDE_ASSIST_KEYBIND   — ZLE keybind (default: ^p)
#   CLAUDE_ASSIST_HISTORY   — history entries sent as context (default: 20)
#   CLAUDE_ASSIST_EFFORT    — claude --effort flag (default: low)
#   CLAUDE_ASSIST_MODEL     — claude --model flag (default: unset)
#   CLAUDE_ASSIST_FZF_OPTS  — extra fzf flags for every fzf call
#   CLAUDE_ASSIST_FZF_COLOR — fzf --color spec override

# ── Helpers ──────────────────────────────────────────────────────────

# Strip markdown code fences and inline backticks from Claude output.
_claude_assist_fzf__clean() {
  local text="$1"
  if [[ "$text" == '```'* ]]; then
    text="${text#*$'\n'}"
    text="${text%$'\n'\`\`\`*}"
  fi
  if [[ "$text" == \`*\` && ${#text} -gt 2 ]]; then
    text="${text#\`}"
    text="${text%\`}"
  fi
  while [[ "$text" == $'\n'* ]]; do text="${text#$'\n'}"; done
  while [[ "$text" == *$'\n' ]]; do text="${text%$'\n'}"; done
  print -r -- "$text"
}

# ── Main ZLE widget ─────────────────────────────────────────────────

_claude_assist_fzf_widget() {
  setopt localoptions pipefail no_aliases 2>/dev/null

  # Pre-flight
  if ! command -v fzf &>/dev/null; then
    zle -M 'claude-assist-fzf: fzf not found on $PATH'
    return 1
  fi
  if ! command -v claude &>/dev/null; then
    zle -M 'claude-assist-fzf: claude not found on $PATH'
    return 1
  fi

  local saved_buffer="$BUFFER" saved_cursor="$CURSOR"
  local _fzf_color="${CLAUDE_ASSIST_FZF_COLOR:-border:248,label:252,header:248,footer:248,prompt:#ffffff,query:regular:-1,bg+:-1,fg+:-1,pointer:248,info:248,spinner:248}"

  # Create temp dir early so both phases can use it.
  local tmpdir
  tmpdir=$(mktemp -d) || {
    zle -M 'claude-assist-fzf: mktemp failed'
    zle reset-prompt
    return 1
  }
  local query_file="$tmpdir/query"

  # ── Phase 1: Collect user query via fzf ────────────────────────────
  #
  #   Enter  → submit the single-line query
  #   Ctrl+E → open $EDITOR for multi-line input
  #
  #   Both paths write the query to $query_file.  The Ctrl+E path uses
  #   execute-silent to seed the file with whatever was already typed,
  #   then `become` to hand the terminal to the editor.
  local -a input_args=(
    --prompt '❯ '
    --border rounded
    --border-label ' Claude Assist '
    --no-info --disabled
    --no-separator --no-scrollbar
    --height '~5'
    --layout reverse
    --color "$_fzf_color"
    --footer-border none
    --bind 'ctrl-z:ignore'
    --bind "enter:transform:[[ -n {q} ]] && echo \"execute-silent(printf '%s' {q} > ${(q)query_file})+accept\" || echo abort"
    --bind "ctrl-e:execute-silent(printf '%s' {q} > ${(q)query_file})+become(${EDITOR:-vi} ${(q)query_file} </dev/tty >/dev/tty 2>/dev/tty)"
  )
  if [[ -n "$saved_buffer" ]]; then
    input_args+=(--header "buffer → ${saved_buffer}" --header-first)
  fi

  FZF_DEFAULT_OPTS='' FZF_DEFAULT_OPTS_FILE='' \
  fzf "${input_args[@]}" ${=CLAUDE_ASSIST_FZF_OPTS} < /dev/null
  local rc=$?

  local query=""
  [[ -s "$query_file" ]] && query=$(<"$query_file")

  # Bail on Esc (file never written) or empty query
  if [[ -z "$query" ]]; then
    rm -rf "$tmpdir"
    zle reset-prompt
    return 0
  fi

  # ── Build Claude context ───────────────────────────────────────────
  local history_context
  history_context=$(fc -ln -"${CLAUDE_ASSIST_HISTORY:-20}" 2>/dev/null \
    | sed 's/^[[:space:]]*//' \
    | while IFS= read -r _line; do print -r -- "${_line[1,200]}"; done)

  local system_prompt
  system_prompt='You are a concise ZSH shell assistant embedded in the user'\''s terminal.

Rules:
- If the user asks for a command: respond with ONLY the command. No prose, no markdown fences, no backticks, no explanation.
- If the user asks a question: respond in 1-2 short lines max.
- Use the provided shell history and current command buffer for context.
- Prefer one-liners. Chain with && or | when appropriate.
- If the current buffer looks like a broken or partial command, respond with the corrected command only.'

  local user_msg="Recent shell history (newest last):
${history_context}

Current command buffer: ${saved_buffer:-<empty>}

Request: ${query}"

  # Write context to temp files to avoid quoting hazards.
  print -rN -- "$user_msg"      > "$tmpdir/msg"
  print -rN -- "$system_prompt" > "$tmpdir/sys"

  # Build the Claude invocation script.
  {
    print -r -- '#!/bin/zsh'
    print -r -- "msg=\$(cat ${(q)tmpdir}/msg)"
    print -r -- "sys=\$(cat ${(q)tmpdir}/sys)"
    printf 'claude -p "$msg" --append-system-prompt "$sys" --tools "" --effort %q --no-session-persistence' \
      "${CLAUDE_ASSIST_EFFORT:-low}"
    [[ -n "${CLAUDE_ASSIST_MODEL:-}" ]] && printf ' --model %q' "$CLAUDE_ASSIST_MODEL"
    printf ' 2>/dev/null\n'
  } > "$tmpdir/run.sh"

  # Truncate long/multi-line queries for the header display.
  local _bold=$'\033[1m' _rst=$'\033[0m'
  local query_display="${query%%$'\n'*}"
  (( ${#query} > ${#query_display} )) && query_display+=" …"

  # ── Phase 2 + 3: Thinking → accept / reject ───────────────────────
  #
  #   A single fzf instance covers both phases.  Fixed --height makes fzf
  #   render the box immediately (~ auto-sizing waits for pipe EOF).
  #
  #   --read0 treats the entire Claude response (up to EOF) as one item,
  #   so multi-line output is preserved.  --wrap displays it nicely.
  #
  #   On `focus` (first item arrives), the footer swaps from
  #   "Thinking…" to the accept/dismiss keybinds.
  #
  #   Esc / Ctrl-C during thinking kills fzf → SIGPIPE tears down the
  #   pipe chain (sed → zsh → claude).
  local result
  result=$(
    zsh "$tmpdir/run.sh" | sed '/^[[:space:]]*$/d' | \
    if command -v bat &>/dev/null; then bat --style=plain --language=zsh --color=always --paging=never --theme="${BAT_THEME:-ansi}"; else cat; fi | \
    FZF_DEFAULT_OPTS='' FZF_DEFAULT_OPTS_FILE='' \
    fzf \
      --read0 --disabled --no-input --ansi --wrap \
      --border rounded \
      --border-label ' Claude Assist ' \
      --header "${_bold}❯${_rst} ${query_display}" \
      --header-first \
      --header-border bottom \
      --footer ' Thinking... ' \
      --footer-border none \
      --no-info --no-separator --no-scrollbar \
      --height 7 \
      --layout reverse \
      --color "$_fzf_color" \
      --bind 'focus:change-footer( Enter → accept  ·  Esc → dismiss )' \
      --bind 'ctrl-z:ignore' \
      ${=CLAUDE_ASSIST_FZF_OPTS}
  )
  rc=$?

  rm -rf "$tmpdir"

  if (( rc != 0 )) || [[ -z "$result" ]]; then
    BUFFER="$saved_buffer"
    CURSOR="$saved_cursor"
    zle reset-prompt
    return 0
  fi

  # Clean any markdown artefacts Claude may have included
  result="$(_claude_assist_fzf__clean "$result")"

  BUFFER="$result"
  CURSOR=${#BUFFER}
  zle reset-prompt
}

# ── Register widget + bind across keymaps ────────────────────────────

zle -N _claude_assist_fzf_widget

bindkey -M emacs "${CLAUDE_ASSIST_KEYBIND:-^p}" _claude_assist_fzf_widget
bindkey -M viins "${CLAUDE_ASSIST_KEYBIND:-^p}" _claude_assist_fzf_widget
bindkey -M vicmd "${CLAUDE_ASSIST_KEYBIND:-^p}" _claude_assist_fzf_widget
