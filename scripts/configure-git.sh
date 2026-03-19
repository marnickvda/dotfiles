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

CREDENTIALS_FILE="$HOME/.config/git/credentials"
git config --file "$CREDENTIALS_FILE" user.email "$GIT_AUTHOR_EMAIL"
git config --file "$CREDENTIALS_FILE" user.signingkey "$GIT_SIGNING_KEY"

echo "Git configuration updated. Credentials written to $CREDENTIALS_FILE"
