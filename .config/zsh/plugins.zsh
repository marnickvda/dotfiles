# antidote updates the plugins, so disable the oh-my-zsh self-update
zstyle ':omz:update' mode disabled

source /opt/homebrew/opt/antidote/share/antidote/antidote.zsh
antidote load "$HOME/.config/zsh/plugins.txt" "$HOME/.cache/zsh/plugins.zsh"
