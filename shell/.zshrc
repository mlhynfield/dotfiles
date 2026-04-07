source ~/.config/shell/all
source ~/.config/shell/zoptions
source ~/.config/shell/completions

# Custom plugins
for plugin in ~/.config/shell/plugins/*.plugin.zsh; do
  [ -f "$plugin" ] && source "$plugin"
done

source ~/.config/shell/plugins/zsh-enhancements
