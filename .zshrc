# Add Homebrew to PATH
export BREW_PREFIX="$(brew --prefix)"
if [ -f "${BREW_PREFIX}/bin/brew" ]
then
  eval "$(${BREW_PREFIX}/bin/brew shellenv)"
fi

if [ -n "${GHOSTTY_RESOURCES_DIR}" ]; then
  builtin source "${GHOSTTY_RESOURCES_DIR}/shell-integration/zsh/ghostty-integration"
fi

# custom plugins
source $HOME/.zsh-plugins/kubectl.plugin.zsh
source $HOME/.zsh-plugins/op.plugin.zsh

# enable vi mode
bindkey -v
export KEYTIMEOUT=25
bindkey -M viins jk vi-cmd-mode
bindkey "^?" backward-delete-char
bindkey "^U" backward-kill-line

# history navigation
for direction (up down) {
  autoload $direction-line-or-beginning-search
  zle -N $direction-line-or-beginning-search
}
# bind up and down arrow keys to history search
bindkey '^[[A' up-line-or-beginning-search
bindkey '^[[B' down-line-or-beginning-search
# bind j and k to history search in vi mode
bindkey -M vicmd j down-line-or-beginning-search
bindkey -M vicmd k up-line-or-beginning-search

# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "${BREW_PREFIX}/opt/nvm/nvm.sh" ] && \. "${BREW_PREFIX}/opt/nvm/nvm.sh"
[ -s "${BREW_PREFIX}/opt/nvm/etc/bash_completion.d/nvm" ] && \. "${BREW_PREFIX}/opt/nvm/etc/bash_completion.d/nvm"

# GPG variable(s)
export GPG_TTY=$(tty)

# GNU sed
export PATH="${BREW_PREFIX}/opt/gnu-sed/libexec/gnubin:$PATH"

# Source 1Password CLI plugins.
source ~/.config/op/plugins.sh

# Use Neovim as editor.
export EDITOR="nvim"
alias vi="nvim"

# yazi function
function y() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    builtin cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}

# autocompletion
eval "$(kubectl completion zsh)"; compdef _kubectl kubectl
eval "$(op completion zsh)"; compdef _op op
complete -C `which aws_completer` aws
PROG=tea _CLI_ZSH_AUTOCOMPLETE_HACK=1 source "${HOME}/Library/Application Support/tea/autocomplete.zsh"

autoload -U +X bashcompinit && bashcompinit
if type brew &>/dev/null; then
  FPATH=${BREW_PREFIX}/share/zsh-completions:$FPATH
  curl -sLo ${BREW_PREFIX}/share/zsh-completions/_task https://raw.githubusercontent.com/go-task/task/main/completion/zsh/_task

fi

# zimfw
ZIM_CONFIG_FILE=~/.config/zsh/zimrc
ZIM_HOME=~/.config/zsh/zim
# Install missing modules and update ${ZIM_HOME}/init.zsh if missing or outdated.
if [[ ! ${ZIM_HOME}/init.zsh -nt ${ZIM_CONFIG_FILE:-${ZDOTDIR:-${HOME}}/.zimrc} ]]; then
  source "${BREW_PREFIX}/opt/zimfw/share/zimfw.zsh" init
fi
# Initialize modules.
source ${ZIM_HOME}/init.zsh

autoload -Uz compinit
compinit
