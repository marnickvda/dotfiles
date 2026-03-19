# homebrew setup
eval "$(/opt/homebrew/bin/brew shellenv)"
export HOMEBREW_NO_ENV_HINTS=true

# starship config
export STARSHIP_CONFIG="$HOME/.config/zsh/starship.toml"
command -v starship &>/dev/null && eval "$(starship init zsh)"

# load zplug plugins
source "$HOME/.config/zsh/plugins.zsh"

setopt AUTO_CD              # cd by just typing dir name
setopt NO_CASE_GLOB         # case-insensitive globbing
setopt HIST_FIND_NO_DUPS    # avoid showing duplicates in history search
setopt EXTENDED_GLOB        # extended globbing support
setopt AUTO_PUSHD           # pushd replaces cd, adds to directory stack
setopt PUSHD_IGNORE_DUPS    # don’t pushd duplicate directories
setopt CORRECT              # spell correction
setopt INTERACTIVE_COMMENTS # allow comments in interactive shell

# Add custom completions directory to the function search path
fpath=($HOME/completions $fpath)

# Load Zsh's native completion system
autoload -Uz compinit && compinit

# Enable support for Bash-style completion scripts
autoload bashcompinit && bashcompinit

export ZSH_COMPDUMP="$HOME/.cache/zsh/.zcompdump-$HOST"
mkdir -p "$(dirname $ZSH_COMPDUMP)"

# Use vim, always.
if [[ -n $SSH_CONNECTION ]]; then
    export EDITOR='vim'
else
    export EDITOR='nvim'
fi
export VISUAL="$EDITOR"

# also for the man pages :)
export MANPAGER='nvim +Man!'
export MANWIDTH=128

# Load development tools (pyenv, nvm, deno, etc.)
source "$HOME/.config/zsh/tools.zsh"

# Load aliases
[[ -f "$HOME/.config/zsh/aliases.zsh" ]] && source "$HOME/.config/zsh/aliases.zsh"

# Load machine-specific configuration based on $PROFILE_DIR
PROFILE_DIR="$HOME/.config/zsh/profiles"
if [[ -n "$ZSH_PROFILE" ]]; then
    PROFILE_FILE="$PROFILE_DIR/${ZSH_PROFILE}.zsh"
    [[ -f "$PROFILE_FILE" ]] && source "$PROFILE_FILE" || echo "No profile found for type: $ZSH_PROFILE"
fi

# Update Brewfile whenever something changes in it.
brew() {
    local dump_commands=('install' 'uninstall')
    local main_command="$1"

    command brew "$@"

    if [[ " ${dump_commands[*]} " == *" $main_command "* ]]; then
        local suffix="${ZSH_PROFILE:+.${ZSH_PROFILE}}"
        local brewfile="${HOME}/.config/homebrew/Brewfile${suffix}"
        (
            command brew bundle dump --file="$brewfile" --force >/dev/null 2>&1
        ) &
        disown
    fi
}
