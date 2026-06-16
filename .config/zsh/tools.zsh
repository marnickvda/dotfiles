# Pyenv setup
if command -v pyenv &>/dev/null; then
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    export PATH="$PYENV_ROOT/shims:$PATH"

    eval "$(pyenv init - zsh)"

    if command -v pyenv-virtualenv-init &>/dev/null; then
        eval "$(pyenv virtualenv-init -)"
    fi
fi

if ! command -v pyenv &>/dev/null; then
    export PATH="/Library/Frameworks/Python.framework/Versions/3.12/bin:$PATH"
fi

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

[[ -f "$HOME/.deno/env" ]] && . "$HOME/.deno/env"

export PATH="$HOME/.local/bin:$HOME/bin:/usr/local/bin:/usr/local/sbin:$PATH"
export PATH="$PATH:$(go env GOPATH)/bin"

if [[ -d "/opt/homebrew/opt/postgresql@17/bin" ]]; then
    export PATH="/opt/homebrew/opt/postgresql@17/bin:$PATH"
fi

if [[ -d "/opt/homebrew/opt/openjdk@21/bin" ]]; then
    export PATH="/opt/homebrew/opt/openjdk@21/bin:$PATH"
fi

command -v direnv &>/dev/null && eval "$(direnv hook zsh)"
