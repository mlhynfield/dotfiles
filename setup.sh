#!/bin/bash
set -euo pipefail

function linux_install_packages() {
  local distro_id
  source /etc/os-release
  distro_id="$ID"

  local packages
  mapfile -t packages <arch/packages

  case "$distro_id" in
  arch | omarchy | cachyos)
    export linux_stow_module="arch"
    if command -v yay &>/dev/null; then
      yay -S --noconfirm --needed "${packages[@]}"
    elif command -v paru &>/dev/null; then
      paru -S --noconfirm --needed "${packages[@]}"
    else
      sudo pacman -S --noconfirm --needed "${packages[@]}"
    fi
    ;;
  *)
    echo "Error: ${distro_id} distribution not currently supported" >&2
    exit 1
    ;;
  esac
}

SYS_UNAME=$(uname -s)
readonly SYS_UNAME

if [[ "$SYS_UNAME" == "Linux" ]]; then
  linux_install_packages
elif [[ "$SYS_UNAME" == "Darwin" ]] && ! command -v brew &>/dev/null; then
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if [[ ! -d ~/dotfiles ]]; then
  git clone https://github.com/mlhynfield/dotfiles.git ~/dotfiles
fi

pushd ~/dotfiles || exit 1

trap "popd || true" EXIT

git submodule update --init --recursive

if [[ "$SYS_UNAME" == "Darwin" ]]; then
  brew bundle check --file=macos/Brewfile || brew bundle install --file=macos/Brewfile

  rm -f ~/.zshrc

  stow --adopt macos leaderkey
fi

if [[ -n "${linux_stow_module:-}" ]]; then
  stow --adopt "$linux_stow_module"
fi

readonly NO_FOLD_STOW_MODULES=(
  1password
  tmux
)

stow --adopt "${NO_FOLD_STOW_MODULES[@]}"

chmod 700 ~/.config/op

readonly STOW_MODULES=(
  ghostty
  git
  github
  k9s
  nvim
  scripts
  task
  tmux
  vim
  yazi
  zsh
)

stow --adopt "${STOW_MODULES[@]}"

ya pkg install

git remote set-url origin git@github.com:mlhynfield/dotfiles.git
