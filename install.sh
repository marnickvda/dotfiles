#!/bin/bash

set -e

echo "Installing Homebrew..."
if ! command -v brew &>/dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

brew update
brew upgrade

echo "Installing base packages..."
brew bundle --file="$HOME/.config/homebrew/Brewfile"

# Install profile-specific packages if ZSH_PROFILE is set
if [[ -n "$ZSH_PROFILE" ]]; then
    PROFILE_BREWFILE="$HOME/.config/homebrew/Brewfile.${ZSH_PROFILE}"
    if [[ -f "$PROFILE_BREWFILE" ]]; then
        echo "Installing $ZSH_PROFILE profile packages..."
        brew bundle --file="$PROFILE_BREWFILE"
    fi
fi

echo "Stowing dotfiles..."
stow .

# Run git configuration
sh ./scripts/configure-git.sh
