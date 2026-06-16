#!/bin/bash

set -e

echo "Installing Homebrew..."
if ! command -v brew &>/dev/null; then
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Stow must come first so configs (Brewfiles, git config, etc.) are symlinked
# into $HOME before anything else tries to read them.
echo "Stowing dotfiles..."
brew install stow
# Pre-create dirs that mix our stowed files with externally-managed content
# (e.g. the agent skill manager). This forces stow to descend and symlink
# individual entries instead of folding the whole tree into one symlink.
mkdir -p "$HOME/.agents/skills"
stow .

echo "Installing base packages..."
brew update
brew upgrade
brew bundle --file="$HOME/.config/homebrew/Brewfile"

# Install profile-specific packages if ZSH_PROFILE is set
if [[ -n "$ZSH_PROFILE" ]]; then
	PROFILE_BREWFILE="$HOME/.config/homebrew/Brewfile.${ZSH_PROFILE}"
	if [[ -f "$PROFILE_BREWFILE" ]]; then
		echo "Installing $ZSH_PROFILE profile packages..."
		brew bundle --file="$PROFILE_BREWFILE"
	fi
fi

# Run git configuration
sh ./scripts/configure-git.sh
