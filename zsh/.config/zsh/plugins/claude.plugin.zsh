#!/usr/bin/env zsh
# claude.plugin.zsh
# Inline Claude Code assistance for ZSH

# ── Configuration ─────────────────────────────────────────────────────────────
CLAUDE_ASSIST_KEYBIND="${CLAUDE_ASSIST_KEYBIND:-^p}"
CLAUDE_ASSIST_HISTORY="${CLAUDE_ASSIST_HISTORY:-20}"
CLAUDE_ASSIST_EFFORT="${CLAUDE_ASSIST_EFFORT:-low}"
CLAUDE_ASSIST_MODEL="${CLAUDE_ASSIST_MODEL:-}"

# ── Colors (override with CLAUDE_ASSIST_COLOR_*) ─────────────────────────────
: ${CLAUDE_ASSIST_COLOR_RULE:=$'\e[38;5;248m'}
: ${CLAUDE_ASSIST_COLOR_OK:=$'\e[1;32m'}
: ${CLAUDE_ASSIST_COLOR_ERR:=$'\e[1;31m'}

typeset -A _ca_c=(
  [rule]=$CLAUDE_ASSIST_COLOR_RULE
  [ok]=$CLAUDE_ASSIST_COLOR_OK
  [err]=$CLAUDE_ASSIST_COLOR_ERR
  [dim]=$'\e[2m'  [bold]=$'\e[1m'  [rst]=$'\e[0m'
)

# ── Helpers ───────────────────────────────────────────────────────────────────

_ca_rule() {
  local label="$1" width=${COLUMNS:-80}
  local _e=""
  if [[ -n "$label" ]]; then
    local pre="── $label "
    local fill=$(( width - ${#pre} ))
    (( fill < 2 )) && fill=2
    printf "${_ca_c[rule]}%s%s${_ca_c[rst]}\n" "$pre" "${(l:$fill::─:)_e}"
  else
    printf "${_ca_c[rule]}%s${_ca_c[rst]}\n" "${(l:$width::─:)_e}"
  fi
}

_ca_clean() {
  local text="$1"
  if [[ "$text" == \`\`\`* ]]; then
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

# ── Main widget ───────────────────────────────────────────────────────────────
_claude_assist_widget() {
  local saved_buffer="$BUFFER"
  local saved_cursor="$CURSOR"
  local _ca_dismiss='\0338\033[J'

  # Save cursor position — all exit paths restore with \0338\033[J
  printf '\0337'

  # ── Phase 1: prompt box ─────────────────────────────────────────────────
  printf "\n"
  _ca_rule "Claude Assist"
  [[ -n "$saved_buffer" ]] && printf "  ${_ca_c[dim]}buffer → %s${_ca_c[rst]}\n\n" "$saved_buffer"
  printf "  ${_ca_c[bold]}❯ ${_ca_c[rst]}\n"
  _ca_rule
  printf "\033[2A\r  ${_ca_c[bold]}❯ ${_ca_c[rst]}"

  if ! command -v claude &>/dev/null; then
    printf "\n  ${_ca_c[err]}claude not found on \$PATH${_ca_c[rst]}\n"
    printf "$_ca_dismiss"
    BUFFER="$saved_buffer"; CURSOR="$saved_cursor"
    zle reset-prompt; return 1
  fi

  local _ca_stty; _ca_stty=$(stty -g </dev/tty 2>/dev/null)
  stty -icanon -echo -echoctl min 1 time 0 </dev/tty 2>/dev/null

  local query="" _ca_ch="" _ca_int=0
  trap '_ca_int=1; stty "$_ca_stty" </dev/tty 2>/dev/null; printf "$_ca_dismiss"; return' INT

  while true; do
    IFS= read -rk1 _ca_ch </dev/tty
    local _rr=$?
    (( _ca_int )) && break
    (( _rr != 0 )) && { _ca_int=1; break }

    if [[ "$_ca_ch" == $'\033' ]]; then
      while IFS= read -rk1 -t0 _ca_ch </dev/tty 2>/dev/null; do :; done
      _ca_int=1; break
    fi
    [[ "$_ca_ch" == $'\n' || "$_ca_ch" == $'\r' ]] && break
    if [[ "$_ca_ch" == $'\x7f' || "$_ca_ch" == $'\b' ]]; then
      [[ -n "$query" ]] && { query="${query%?}"; printf '\b \b'; }
      continue
    fi
    # Ctrl+U — clear entire input
    if [[ "$_ca_ch" == $'\x15' ]]; then
      if [[ -n "$query" ]]; then
        printf "\r\033[K  ${_ca_c[bold]}❯ ${_ca_c[rst]}"
        query=""
      fi
      continue
    fi
    # Ignore non-printable control characters (Tab, etc.)
    [[ "$_ca_ch" < $'\x20' ]] && continue
    query+="$_ca_ch"
    printf '%s' "$_ca_ch"
  done

  trap - INT
  stty "$_ca_stty" </dev/tty 2>/dev/null

  if (( _ca_int )) || [[ -z "$query" ]]; then
    printf "$_ca_dismiss"
    BUFFER="$saved_buffer"; CURSOR="$saved_cursor"
    zle reset-prompt; return
  fi

  # ── Phase 2: thinking box (full redraw) ─────────────────────────────────
  printf "$_ca_dismiss"
  printf "\n"
  _ca_rule "Claude Assist"
  [[ -n "$saved_buffer" ]] && printf "  ${_ca_c[dim]}buffer → %s${_ca_c[rst]}\n\n" "$saved_buffer"
  printf "  ${_ca_c[bold]}❯${_ca_c[rst]} %s\n" "$query"
  printf "\n  ${_ca_c[dim]}Thinking...${_ca_c[rst]}\n"
  _ca_rule

  local history_context
  history_context=$(fc -ln -"$CLAUDE_ASSIST_HISTORY" 2>/dev/null \
    | sed 's/^[[:space:]]*//' \
    | while IFS= read -r _line; do print -r -- "${_line[1,200]}"; done)

  local system_prompt
  read -r -d '' system_prompt <<'EOF'
You are a concise ZSH shell assistant embedded in the user's terminal.

Rules:
- If the user asks for a command: respond with ONLY the command. No prose,
  no markdown fences, no backticks, no explanation.
- If the user asks a question: respond in 1-2 short lines max.
- Use the provided shell history and current command buffer to understand
  what the user is working on. Reference specifics when relevant.
- Prefer one-liners. Chain with && or | when appropriate.
- If the current buffer looks like a broken or partial command and the user
  asks you to fix it, respond with the corrected command only.
EOF

  local user_msg="Recent shell history (newest last):
${history_context}

Current command buffer: ${saved_buffer:-<empty>}

Request: ${query}"

  local -a cmd=(claude -p "$user_msg" --max-turns 1 --effort "$CLAUDE_ASSIST_EFFORT")
  [[ -n "$CLAUDE_ASSIST_MODEL" ]] && cmd+=(--model "$CLAUDE_ASSIST_MODEL")
  cmd+=(--append-system-prompt "$system_prompt")

  local result _ca_int2=0
  trap '_ca_int2=1; printf "$_ca_dismiss"; return' INT
  result=$("${cmd[@]}" < /dev/null 2>/dev/null)
  local rc=$?
  trap - INT

  if (( _ca_int2 )); then
    printf "$_ca_dismiss"
    BUFFER="$saved_buffer"; CURSOR="$saved_cursor"
    zle reset-prompt; return
  fi

  if (( rc != 0 )) || [[ -z "$result" ]]; then
    printf "$_ca_dismiss"
    printf "\n"
    _ca_rule "Claude Assist"
    printf "  ${_ca_c[err]}No response from Claude (exit $rc)${_ca_c[rst]}\n"
    _ca_rule
    read -sk1 < /dev/tty
    printf "$_ca_dismiss"
    BUFFER="$saved_buffer"; CURSOR="$saved_cursor"
    zle reset-prompt; return 1
  fi

  result="$(_ca_clean "$result")"

  # ── Phase 3: result box (full redraw) ───────────────────────────────────
  printf "$_ca_dismiss"
  printf "\n"
  _ca_rule "Claude Assist"
  [[ -n "$saved_buffer" ]] && printf "  ${_ca_c[dim]}buffer → %s${_ca_c[rst]}\n\n" "$saved_buffer"
  printf "  ${_ca_c[bold]}❯${_ca_c[rst]} %s\n\n" "$query"
  while IFS= read -r line; do
    printf "  ${_ca_c[ok]}%s${_ca_c[rst]}\n" "$line"
  done <<< "$result"
  printf "\n  ${_ca_c[dim]}enter → accept  ·  any other key → cancel${_ca_c[rst]}\n"
  _ca_rule

  local key
  trap 'printf "$_ca_dismiss"; return' INT
  read -sk1 key < /dev/tty
  trap - INT

  printf "$_ca_dismiss"

  if [[ "$key" == $'\n' || "$key" == $'\r' ]]; then
    BUFFER="$result"
    CURSOR=${#BUFFER}
  else
    BUFFER="$saved_buffer"
    CURSOR="$saved_cursor"
  fi

  zle reset-prompt
}

zle -N _claude_assist_widget
bindkey "${CLAUDE_ASSIST_KEYBIND}" _claude_assist_widget
bindkey -M viins "${CLAUDE_ASSIST_KEYBIND}" _claude_assist_widget
bindkey -M vicmd "${CLAUDE_ASSIST_KEYBIND}" _claude_assist_widget
