#!/bin/bash
set -euo pipefail

readonly DOTFILES="$HOME/dotfiles"
readonly ORIGIN_HTTPS="https://github.com/mlhynfield/dotfiles.git"
readonly ORIGIN_SSH="git@github.com:mlhynfield/dotfiles.git"

readonly BASHRC_MARKER="managed by dotfiles/setup.sh: launch zsh from interactive bash"

readonly PACKAGE_LIST="arch/packages"
readonly BREWFILE="macos/Brewfile"

readonly MODULES=(ghostty git github k9s nvim scripts shell task tmux vim yazi)
readonly MODULES_NO_FOLD=(1password claude)
readonly MODULES_LINUX=(arch foot)
readonly MODULES_MACOS=(macos leaderkey hammerspoon)
readonly MODULES_OMARCHY_NO_FOLD=(omarchy)

packages=()
optional_packages=()

die() {
  echo "Error: $*" >&2
  exit 1
}

resolve_packages() {
  local overlay="${PACKAGE_LIST}.$(uname -m)"
  local -A replacement=()
  local name value

  if [[ -f $overlay ]]; then
    while read -r name value _; do
      [[ -z $name || $name == '#'* ]] && continue
      replacement[$name]=$value
    done <"$overlay"
  fi

  packages=()
  while read -r name _; do
    [[ -z $name || $name == '#'* ]] && continue
    value=${replacement[$name]-$name}
    [[ $value == '-' ]] && continue
    packages+=("$value")
  done <"$PACKAGE_LIST"

  optional_packages=()
  if [[ -f ${overlay}.optional ]]; then
    while read -r name _; do
      [[ -z $name || $name == '#'* ]] && continue
      optional_packages+=("$name")
    done <"${overlay}.optional"
  fi
}

install_arch_packages() {
  local aur
  if command -v yay &>/dev/null; then
    aur=yay
  elif command -v paru &>/dev/null; then
    aur=paru
  else
    die "no AUR helper found (yay or paru).

Some packages, 1password-cli among them, exist only in the AUR, so pacman
alone cannot finish this setup. Install yay first:

  sudo pacman -S --needed git base-devel
  git clone https://aur.archlinux.org/yay-bin.git /tmp/yay-bin
  (cd /tmp/yay-bin && makepkg -si)"
  fi

  resolve_packages

  "$aur" -S --noconfirm --needed "${packages[@]}"

  if ((${#optional_packages[@]} > 0)); then
    "$aur" -S --noconfirm --needed "${optional_packages[@]}" ||
      echo "Warning: optional packages unavailable here, skipping: ${optional_packages[*]}" >&2
  fi
}

install_linux_packages() {
  local ID ID_LIKE
  source /etc/os-release

  case "${ID_LIKE:-${ID:-}}" in
  *arch*) install_arch_packages ;;
  *) die "${ID:-unknown} is not a supported distribution" ;;
  esac
}

install_macos_packages() {
  if ! command -v brew &>/dev/null; then
    NONINTERACTIVE=1 /bin/bash -c \
      "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

  brew bundle check --file="$BREWFILE" || brew bundle install --file="$BREWFILE"
}

adopt_baseline=""

record_adopt_baseline() {
  adopt_baseline=$(git diff --name-only | sort)
}

report_adopted() {
  local -a adopted
  mapfile -t adopted < <(comm -13 \
    <(printf '%s\n' "$adopt_baseline") \
    <(git diff --name-only | sort))

  ((${#adopted[@]} > 0)) || return 0

  echo
  echo "stow --adopt replaced these tracked files with copies already on disk:"
  printf '  %s\n' "${adopted[@]}"
  echo
  echo "Review a change:  git -C $DOTFILES diff -- <file>"
  echo "Discard a change: git -C $DOTFILES checkout -- <file>"
}

set_login_shell() {
  local zsh
  zsh=$(command -v zsh) || {
    echo "Warning: zsh not installed, leaving login shell as ${SHELL:-unknown}" >&2
    return 0
  }

  local current
  current=$(getent passwd "$USER" 2>/dev/null | cut -d: -f7) ||
    current=$(dscl . -read "/Users/$USER" UserShell 2>/dev/null | cut -d' ' -f2)

  [[ $current == "$zsh" ]] && return 0

  if ! grep -qxF "$zsh" /etc/shells; then
    echo "Warning: $zsh is missing from /etc/shells, skipping login shell change" >&2
    return 0
  fi

  echo "Changing login shell to $zsh"
  chsh -s "$zsh" || echo "Warning: chsh failed, login shell unchanged" >&2
}

exec_zsh_from_bash() {
  local bashrc="$HOME/.bashrc"

  command -v zsh &>/dev/null || return 0
  [[ -f $bashrc ]] || return 0
  grep -qF "$BASHRC_MARKER" "$bashrc" && return 0

  cat >>"$bashrc" <<EOF

# >>> $BASHRC_MARKER >>>
EOF

  cat >>"$bashrc" <<'EOF'
if [[ $- == *i* && -z ${BASH_EXECUTION_STRING:-} && ${SHLVL:-1} == 1 ]] &&
  command -v zsh &>/dev/null &&
  [[ $(ps -o comm= -p "$PPID" 2>/dev/null) != zsh ]]; then
  if shopt -q login_shell; then
    exec zsh --login
  else
    exec zsh
  fi
fi
EOF

  cat >>"$bashrc" <<EOF
# <<< $BASHRC_MARKER <<<
EOF

  echo "Added zsh auto-launch to $bashrc"
}

stow_folded() {
  if (($# > 0)); then
    stow --adopt "$@"
  fi
}

stow_unfolded() {
  if (($# > 0)); then
    stow --no-folding --adopt "$@"
  fi
}

if [[ ! -d $DOTFILES ]]; then
  git clone "$ORIGIN_HTTPS" "$DOTFILES"
fi

cd "$DOTFILES"

git submodule update --init --recursive

record_adopt_baseline

case "$(uname -s)" in
Linux)
  install_linux_packages
  stow_folded "${MODULES_LINUX[@]}"
  if command -v omarchy &>/dev/null; then
    stow_unfolded "${MODULES_OMARCHY_NO_FOLD[@]}"
  fi
  ;;
Darwin)
  install_macos_packages
  rm -f ~/.zshrc
  stow_folded "${MODULES_MACOS[@]}"
  ;;
*)
  die "$(uname -s) is not a supported operating system"
  ;;
esac

stow_unfolded "${MODULES_NO_FOLD[@]}"
stow_folded "${MODULES[@]}"

chmod 700 ~/.config/op

ya pkg install

git remote set-url origin "$ORIGIN_SSH"

set_login_shell
exec_zsh_from_bash

report_adopted
