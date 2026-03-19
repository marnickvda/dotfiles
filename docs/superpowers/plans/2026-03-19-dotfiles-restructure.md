# Dotfiles Restructure Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Restructure the dotfiles repo for XDG consistency, cleaner stow boundaries, and add a personal zsh profile.

**Architecture:** Move legacy top-level dotfiles (`.tmux.conf`, `.gitconfig`) into `.config/` using XDG paths. Tmux 3.6a supports `~/.config/tmux/tmux.conf` natively. Git supports `~/.config/git/config`. The `.ideavimrc` and `.prettierrc.yaml` must stay top-level (no XDG support). Clean up `.zshrc` hardcoded paths. Add `personal.zsh` profile to the profiles submodule.

**Tech Stack:** GNU Stow, Zsh, Tmux, Git, Neovim (Lazy.nvim)

---

## File Map

### Files to move
- `.tmux.conf` -> `.config/tmux/tmux.conf` (tmux 3.6a supports XDG natively)
- `.gitconfig` -> `.config/git/config` (git supports XDG natively)

### Files to modify
- `.zshrc` — remove hardcoded machine-specific paths (bun, python, gcloud, postgresql), move into `personal.zsh` profile
- `.stow-local-ignore` — remove `\.gitconfig` exclusion (it moves into `.config/`)
- `.config/tmux/tmux.conf` — update self-referencing path (`bind r source-file`)
- `.config/git/config` — update `alias-ls` alias that hardcodes `$HOME/.gitconfig` path
- `scripts/configure-git.sh` — update for XDG path, remove old `cp` approach
- `install.sh` — update to handle profile-aware Brewfile installs
- `README.md` — update stale `.gitconfig` documentation

### Files to create
- `.config/zsh/profiles/personal.zsh` — new personal machine profile

### Files to delete
- `.tmux.conf` (moved to `.config/tmux/tmux.conf`)
- `.gitconfig` (moved to `.config/git/config`)

---

### Task 1: Move `.gitconfig` to XDG path

**Files:**
- Move: `.gitconfig` -> `.config/git/config`
- Modify: `.stow-local-ignore`
- Modify: `.config/git/config` (update `alias-ls` hardcoded path)

- [ ] **Step 1: Create `.config/git/` directory and move config**

```bash
cd /Users/marnickvanderarend/dotfiles
mkdir -p .config/git
git mv .gitconfig .config/git/config
```

- [ ] **Step 2: Update `.stow-local-ignore`**

Remove the `\.gitconfig` line since the file now lives inside `.config/` and should be stowed.

- [ ] **Step 3: Update `alias-ls` in `.config/git/config`**

The `alias-ls` alias on line 69 hardcodes `config_file=\"$HOME/.gitconfig\"`. Change to:
```
config_file=\"$HOME/.config/git/config\"
```

- [ ] **Step 4: Update `scripts/configure-git.sh`**

The script currently copies `.gitconfig` to `~/.gitconfig` which conflicts with XDG. Replace with:

```bash
echo "Configuring git credentials"

touch $HOME/.zshenv
source $HOME/.zshenv

if [ -z "$GIT_AUTHOR_EMAIL" ]; then
    echo "Enter Git email:"
    read GIT_AUTHOR_EMAIL
fi

if [ -z "$GIT_SIGNING_KEY" ]; then
    echo "Enter GIT signing key (starts with ssh-ed25519):"
    read GIT_SIGNING_KEY
fi

if ! grep -q "export GIT_AUTHOR_EMAIL=" ~/.zshenv; then
    echo "export GIT_AUTHOR_EMAIL=\"$GIT_AUTHOR_EMAIL\"" >> $HOME/.zshenv
fi

if ! grep -q "export GIT_SIGNING_KEY=" ~/.zshenv; then
    echo "export GIT_SIGNING_KEY=\"$GIT_SIGNING_KEY\"" >> $HOME/.zshenv
fi

git config --global user.email "$GIT_AUTHOR_EMAIL"
git config --global user.signingkey "$GIT_SIGNING_KEY"

echo "Git configuration updated."
```

Key changes: removed the `cp .gitconfig ~/.gitconfig` line (stow handles this now via XDG), and the `git config --global` commands write to `~/.config/git/config` when `~/.gitconfig` doesn't exist.

- [ ] **Step 5: Remove old `~/.gitconfig` file**

The old `~/.gitconfig` was a regular file (not a stow symlink) placed by `configure-git.sh`. Git reads `~/.gitconfig` with *higher priority* than `~/.config/git/config`, so the old file would shadow the XDG config. Back it up and remove:

```bash
cp ~/.gitconfig ~/.gitconfig.backup
rm ~/.gitconfig
```

- [ ] **Step 6: Re-stow and verify git reads from XDG path**

```bash
cd /Users/marnickvanderarend/dotfiles
stow -R .
ls -la ~/.config/git/config
# Expected: symlink -> dotfiles/.config/git/config

# Verify existing ~/.config/git/ignore is undisturbed
ls -la ~/.config/git/ignore

git config --get user.name
# Expected: "Marnick van der Arend"
git config --get core.editor
# Expected: "nvim"
```

- [ ] **Step 7: Commit**

```bash
git add .config/git/config .stow-local-ignore scripts/configure-git.sh
git commit -m "refactor: move .gitconfig to XDG path .config/git/config"
```

---

### Task 2: Move `.tmux.conf` to XDG path

**Files:**
- Move: `.tmux.conf` -> `.config/tmux/tmux.conf`
- Modify: `.config/tmux/tmux.conf` (update source-file path)

- [ ] **Step 1: Move tmux config**

```bash
cd /Users/marnickvanderarend/dotfiles
git mv .tmux.conf .config/tmux/tmux.conf
```

- [ ] **Step 2: Update the reload keybinding path**

In `.config/tmux/tmux.conf`, change:
```
bind r source-file ~/.tmux.conf
```
to:
```
bind r source-file ~/.config/tmux/tmux.conf
```

- [ ] **Step 3: Re-stow and verify**

The old `~/.tmux.conf` stow symlink will be cleaned up by `stow -R`:

```bash
stow -R .
ls -la ~/.config/tmux/tmux.conf
# Expected: symlink -> dotfiles/.config/tmux/tmux.conf

# Verify old symlink is gone
ls -la ~/.tmux.conf 2>&1
# Expected: "No such file or directory"
```

- [ ] **Step 4: Commit**

```bash
git add .config/tmux/tmux.conf
git commit -m "refactor: move .tmux.conf to XDG path .config/tmux/tmux.conf"
```

---

### Task 3: Clean up `.zshrc` — move machine-specific paths to profile

**Files:**
- Modify: `.zshrc`
- Create: `.config/zsh/profiles/personal.zsh` (in profiles submodule)

The `.zshrc` currently has machine-specific paths at lines 75-91:
- Bun completions with hardcoded username path
- Bun PATH
- Python framework paths
- PostgreSQL path
- SSL cert via certifi
- Google Cloud SDK paths

These should move into the `personal.zsh` profile, keeping `.zshrc` portable.

- [ ] **Step 1: Create `personal.zsh` profile**

Create `.config/zsh/profiles/personal.zsh`:

```zsh
# Bun
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Python (system framework installs)
export PATH="/Library/Frameworks/Python.framework/Versions/3.12/bin:$PATH"
export PATH="/Library/Frameworks/Python.framework/Versions/3.13/bin:$PATH"

# PostgreSQL
export PATH="/opt/homebrew/opt/postgresql@16/bin:$PATH"

# SSL certs via certifi
if command -v python3 &>/dev/null; then
    export SSL_CERT_FILE=$(python3 -c "import certifi; print(certifi.where())" 2>/dev/null)
fi

# Google Cloud SDK
if [ -f "$HOME/Downloads/google-cloud-sdk/path.zsh.inc" ]; then
    source "$HOME/Downloads/google-cloud-sdk/path.zsh.inc"
fi
if [ -f "$HOME/Downloads/google-cloud-sdk/completion.zsh.inc" ]; then
    source "$HOME/Downloads/google-cloud-sdk/completion.zsh.inc"
fi
```

Note: Bun completions path uses `$HOME` instead of the hardcoded `/Users/marnick.van.der.arend/` (which was likely from an old username). Added guard on `SSL_CERT_FILE` so it doesn't error if certifi isn't installed.

- [ ] **Step 2: Remove machine-specific lines from `.zshrc`**

Remove lines 75-91 from `.zshrc` — everything from `# bun completions` through the gcloud completion source. This includes:
- The `# bun completions` comment (line 75)
- The bun source/PATH lines (76-81)
- The Python PATH lines (81-82)
- The PostgreSQL PATH (83)
- The SSL_CERT_FILE export (84)
- The Google Cloud SDK lines (86-91)

After removal, `.zshrc` ends with the closing `}` of the `brew()` function.

- [ ] **Step 3: Set `ZSH_PROFILE=personal` in `~/.zshenv`**

Add to the user's (untracked) `~/.zshenv`:
```zsh
export ZSH_PROFILE="personal"
```

- [ ] **Step 4: Verify shell loads correctly**

```bash
zsh -i -c 'echo "Profile: $ZSH_PROFILE"; which bun; echo $BUN_INSTALL'
# Expected: Profile: personal, bun found, BUN_INSTALL set
```

- [ ] **Step 5: Commit dotfiles changes**

```bash
git add .zshrc
git commit -m "refactor: move machine-specific paths from .zshrc to personal profile"
```

- [ ] **Step 6: Commit profiles submodule changes**

```bash
cd .config/zsh/profiles
git add personal.zsh
git commit -m "feat: add personal machine profile"
git push
cd /Users/marnickvanderarend/dotfiles
git add .config/zsh/profiles
git commit -m "chore: update profiles submodule ref"
```

---

### Task 4: Update `install.sh` and `README.md`

**Files:**
- Modify: `install.sh`
- Modify: `README.md`

- [ ] **Step 1: Update install.sh**

```bash
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
```

- [ ] **Step 2: Update README.md**

Replace the "Updating .gitconfig" section with:

```markdown
### Updating git config

Git config lives at `.config/git/config` (XDG standard). Stow symlinks it to `~/.config/git/config`.
Edit it directly — changes take effect immediately since it's symlinked.

To update credentials, run `./scripts/configure-git.sh`.
```

- [ ] **Step 3: Verify install.sh syntax**

```bash
bash -n /Users/marnickvanderarend/dotfiles/install.sh
# Expected: no output (syntax OK)
```

- [ ] **Step 4: Commit**

```bash
git add install.sh README.md
git commit -m "docs: update install.sh and README for XDG structure"
```

---

### Task 5: Final verification

- [ ] **Step 1: Re-stow everything cleanly**

```bash
cd /Users/marnickvanderarend/dotfiles
stow -R .
```

- [ ] **Step 2: Verify symlinks**

```bash
ls -la ~/.config/git/config      # -> dotfiles/.config/git/config
ls -la ~/.config/git/ignore      # should still exist (not disrupted)
ls -la ~/.config/tmux/tmux.conf  # -> dotfiles/.config/tmux/tmux.conf
ls -la ~/.config/nvim             # -> dotfiles/.config/nvim
ls -la ~/.zshrc                   # -> dotfiles/.zshrc

# Verify old files are gone
ls -la ~/.tmux.conf 2>&1          # should not exist
ls -la ~/.gitconfig 2>&1          # should not exist (backed up earlier)
```

- [ ] **Step 3: Verify git works**

```bash
git config --get user.name       # "Marnick van der Arend"
git config --get core.editor     # "nvim"
git config --get core.pager      # "delta"
git alias-ls | head -5           # should show alias descriptions (not "not found in config")
```

- [ ] **Step 4: Verify tmux works**

```bash
tmux new-session -d -s test 'echo ok' && tmux kill-session -t test
# Expected: no errors
```

- [ ] **Step 5: Verify zsh profile loading**

```bash
zsh -i -c 'echo "ZSH_PROFILE=$ZSH_PROFILE"'
# Expected: ZSH_PROFILE=personal
```

- [ ] **Step 6: Verify nvim works**

```bash
nvim --headless "+checkhealth" +qa 2>&1 | head -5
# Expected: no critical errors
```
