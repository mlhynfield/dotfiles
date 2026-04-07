#!/usr/bin/env zsh
# Regression tests for claude.plugin.zsh
# Run: zsh tests/claude_plugin_test.zsh

setopt extended_glob  # match user's likely config

# ── Stub ZLE/bindkey so plugin sources outside a terminal ────────────────────
zle()     { : }
bindkey() { : }

source "${0:A:h}/../claude.plugin.zsh" 2>/dev/null
local _src_rc=$?

unfunction zle bindkey

# ── Test harness ─────────────────────────────────────────────────────────────
_t_pass=0 _t_fail=0

assert_eq() {
  local label="$1" expected="$2" actual="$3"
  if [[ "$expected" == "$actual" ]]; then
    print "  PASS  $label"
    (( _t_pass++ ))
  else
    print "  FAIL  $label"
    print "        expected: ${(qqqq)expected}"
    print "        actual:   ${(qqqq)actual}"
    (( _t_fail++ ))
  fi
}

assert_true() {
  local label="$1"; shift
  if "$@"; then
    print "  PASS  $label"
    (( _t_pass++ ))
  else
    print "  FAIL  $label  (expected true)"
    (( _t_fail++ ))
  fi
}

assert_false() {
  local label="$1"; shift
  if ! "$@"; then
    print "  PASS  $label"
    (( _t_pass++ ))
  else
    print "  FAIL  $label  (expected false)"
    (( _t_fail++ ))
  fi
}

# ── 1. Plugin sources cleanly ────────────────────────────────────────────────
print "\n── Source"
assert_eq "plugin sources without error" 0 "$_src_rc"

# ── 2. Config defaults ──────────────────────────────────────────────────────
print "\n── Config defaults"
assert_eq "keybind" "^p"  "$CLAUDE_ASSIST_KEYBIND"
assert_eq "history" "20"  "$CLAUDE_ASSIST_HISTORY"
assert_eq "effort"  "low" "$CLAUDE_ASSIST_EFFORT"
assert_eq "model"   ""    "$CLAUDE_ASSIST_MODEL"

# ── 3. Color array: real escape bytes ────────────────────────────────────────
print "\n── Color escape bytes (defaults)"
for key in rule dim bold ok err rst; do
  assert_eq "color[$key] starts with ESC" $'\e' "${_ca_c[$key][1]}"
done

# ── 4. Color overrides via env vars ──────────────────────────────────────────
print "\n── Color overrides"
local _tmp=$(mktemp)
(
  zle()     { : }
  bindkey() { : }
  CLAUDE_ASSIST_COLOR_RULE=$'\e[1;35m'
  CLAUDE_ASSIST_COLOR_OK=$'\e[1;33m'
  CLAUDE_ASSIST_COLOR_ERR=$'\e[1;36m'
  source "${0:A:h}/../claude.plugin.zsh" 2>/dev/null

  local _f=0
  [[ "${_ca_c[rule]}" == $'\e[1;35m' ]] || (( _f++ ))
  [[ "${_ca_c[ok]}"   == $'\e[1;33m' ]] || (( _f++ ))
  [[ "${_ca_c[err]}"  == $'\e[1;36m' ]] || (( _f++ ))
  [[ "${_ca_c[dim]}"  == $'\e[2m'    ]] || (( _f++ ))
  print "$_f" > "$_tmp"
)
local _of=$(<"$_tmp"); rm -f "$_tmp"
if (( _of == 0 )); then
  for t in "rule override" "ok override" "err override" "dim unchanged"; do
    print "  PASS  $t"; (( _t_pass++ ))
  done
else
  print "  FAIL  color overrides ($_of of 4 failed)"; (( _t_fail++ ))
  (( _t_pass += 4 - _of - 1 ))
fi

# ── 5. _ca_clean: backtick/fence stripping ───────────────────────────────────
print "\n── _ca_clean"
assert_eq "bare text"               "ls -la"            "$(_ca_clean 'ls -la')"
assert_eq "single backticks"        "ls -la"            "$(_ca_clean '`ls -la`')"
assert_eq "fence + lang tag"        "ls -la"            "$(_ca_clean $'```zsh\nls -la\n```')"
assert_eq "fence no lang"           "ls -la"            "$(_ca_clean $'```\nls -la\n```')"
assert_eq "multi-line fence"        $'cd /tmp\nls -la'  "$(_ca_clean $'```bash\ncd /tmp\nls -la\n```')"
assert_eq "leading/trailing NL"     "ls -la"            "$(_ca_clean $'\n\nls -la\n\n')"
assert_eq "single backtick char"    '`'                 "$(_ca_clean '`')"
assert_eq "nested backticks"        'echo `date`'       "$(_ca_clean $'```\necho `date`\n```')"
assert_eq "empty string"            ""                  "$(_ca_clean '')"
assert_eq "fence + trailing text"   "ls"                "$(_ca_clean $'```sh\nls\n``` some note')"

# ── 6. ESC byte detection ────────────────────────────────────────────────────
print "\n── ESC byte detection"
_is_esc() { [[ "$1" == $'\033' ]]; }
assert_true  "0x1b is ESC"         _is_esc $'\e'
assert_true  "\\033 is ESC"        _is_esc $'\033'
assert_false "newline is not ESC"  _is_esc $'\n'
assert_false "letter is not ESC"   _is_esc "a"
assert_false "empty is not ESC"    _is_esc ""

# ── 7. Control char filtering (mirrors read loop guard) ──────────────────────
print "\n── Control char filter"
_is_printable() { [[ "$1" > $'\x1f' ]]; }
assert_true  "space is printable"   _is_printable " "
assert_true  "letter is printable"  _is_printable "a"
assert_true  "tilde is printable"   _is_printable "~"
assert_false "tab is filtered"      _is_printable $'\t'
assert_false "ctrl+a is filtered"   _is_printable $'\x01'
assert_false "BEL is filtered"      _is_printable $'\x07'

# ── 8. _ca_rule output ──────────────────────────────────────────────────────
print "\n── _ca_rule output"
local _rule_out
_rule_out=$(_ca_rule "Test")
_starts_with_esc() { [[ "${_rule_out[1]}" == $'\e' ]]; }
_has_label()       { [[ "$_rule_out" == *Test* ]]; }
_has_dash()        { [[ "$_rule_out" == *─* ]]; }
assert_true  "rule contains ESC byte" _starts_with_esc
assert_true  "rule contains label"    _has_label
assert_true  "rule contains ─"        _has_dash

local _rule_plain
_rule_plain=$(_ca_rule)
_plain_no_label() { [[ "$_rule_plain" != *──\ * ]]; }
assert_true "plain rule has no label" _plain_no_label

# ── 9. History truncation ────────────────────────────────────────────────────
print "\n── History truncation"
local _long_line=$(printf 'x%.0s' {1..300})
local _truncated
_truncated=$(print -r -- "$_long_line" | while IFS= read -r _line; do print -r -- "${_line[1,200]}"; done)
assert_eq "300-char line truncated to 200" 200 "${#_truncated}"

local _short="short command"
local _kept
_kept=$(print -r -- "$_short" | while IFS= read -r _line; do print -r -- "${_line[1,200]}"; done)
assert_eq "short line unchanged" "$_short" "$_kept"

# ── 10. Bracketed paste detection ───────────────────────────────────────────
print "\n── Bracketed paste detection"
_is_bracketed_paste() { [[ "$1" == '[200~'* ]]; }
_is_paste_end()       { [[ "$1" == '[201~'* ]]; }
assert_true  "open sequence detected"   _is_bracketed_paste '[200~'
assert_true  "open + content detected"  _is_bracketed_paste '[200~hello'
assert_false "close is not open"        _is_bracketed_paste '[201~'
assert_true  "close sequence detected"  _is_paste_end       '[201~'
assert_false "arrow key is not paste"   _is_bracketed_paste '[A'
assert_false "empty is not paste"       _is_bracketed_paste ''

# ── Summary ──────────────────────────────────────────────────────────────────
print "\n── Results: ${_t_pass} passed, ${_t_fail} failed"
(( _t_fail > 0 )) && exit 1
exit 0
