#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://github.com/dunglas/prompt-mac.git"

# This setup targets Apple Silicon macOS only
if [[ "$(uname)" != "Darwin" || "$(uname -m)" != "arm64" ]]; then
  echo "🛑 This script only supports macOS on Apple Silicon." >&2
  exit 1
fi

# Homebrew — also installs the Command Line Tools, which provide git for the bootstrap step below.
if ! command -v brew >/dev/null 2>&1; then
  echo "🍺 Installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/opt/homebrew/bin/brew shellenv)"

# Locate the repo. Run normally, the Brewfile sits next to this script. Run as a one-liner
# (`curl … | bash`) it doesn't, so clone the repo to a permanent home (configs are symlinked from
# it, so it must persist) and re-exec from there.
SOURCE="${BASH_SOURCE[0]:-}"
DIR=""
[[ -n "$SOURCE" ]] && DIR="$(cd -- "$(dirname -- "$SOURCE")" >/dev/null 2>&1 && pwd || true)"
if [[ -z "$DIR" || ! -f "$DIR/Brewfile" ]]; then
  DIR="${PROMPT_MAC_DIR:-$HOME/Developer/prompt-mac}"
  command -v git >/dev/null 2>&1 || brew install git
  if [[ -d "$DIR/.git" ]]; then
    echo "📥 Updating prompt-mac in $DIR"
    git -C "$DIR" pull --ff-only || echo "⚠️  Couldn't fast-forward $DIR; using the existing checkout"
  else
    echo "📥 Cloning prompt-mac into $DIR"
    git clone "$REPO_URL" "$DIR"
  fi
  exec bash "$DIR/install.sh"
fi

# App Store: mas installs apps but can't sign in (and `mas account` is unreliable on recent
# macOS), so when running interactively, make sure the user is signed in before we continue.
brew list mas >/dev/null 2>&1 || brew install mas
if [ -t 0 ]; then
  echo "🛍️  Make sure you're signed in to the App Store (mas can't sign in for you)."
  open -a "App Store"
  read -r -p "   Press Enter once you're signed in... "

  # First run: mas install fails for apps you've never gotten, so open a deep link for each missing one
  while IFS= read -r line; do
    id="${line##*id: }"
    name="$(sed -E 's/^mas "([^"]+)".*/\1/' <<<"$line")"
    if ! mas list | grep -q "^$id "; then
      echo "🛍️  Get \"$name\" from the App Store"
      open "macappstore://apps.apple.com/app/id$id"
      read -r -p "   Once installed, press Enter to continue... "
    fi
  done < <(grep '^mas ' "$DIR/Brewfile")
fi

# Packages (brews, casks, mas apps, VS Code extensions)
echo "📦 Installing packages from Brewfile"
if [[ -n "${CI:-}" ]]; then
  # CI can't sign in to the App Store, so mas installs fail. Drop the mas lines there.
  brew bundle install --file=<(grep -v '^mas ' "$DIR/Brewfile")
else
  brew bundle install --file="$DIR/Brewfile"
fi

# Config files (symlinked so the repo stays the source of truth)
echo "🔗 Linking config files"
ln -sfn "$DIR/.zshrc" "$HOME/.zshrc"

mkdir -p "$HOME/.config/ghostty"
ln -sfn "$DIR/config.ghostty" "$HOME/.config/ghostty/config"

mkdir -p "$HOME/.config/nvim"
ln -sfn "$DIR/init.lua" "$HOME/.config/nvim/init.lua"

VSCODE_USER="$HOME/Library/Application Support/Code/User"
mkdir -p "$VSCODE_USER"
ln -sfn "$DIR/settings.json" "$VSCODE_USER/settings.json"

# Git commit signing over SSH. Generate a signing key if absent, register it as a local allowed
# signer (so `git log --show-signature` verifies), and upload it to GitHub for the "Verified" badge.
echo "🔐 Configuring Git commit signing"
# Offer GitHub sign-in up front so identity and signing key are set in one pass. Skippable for users
# without an account. Only when attached to a terminal; piped installs (curl | bash) fall through.
if [[ -t 0 ]] && ! gh auth status >/dev/null 2>&1; then
  read -rp "Sign in to GitHub now to enable signed, verified commits? [Y/n] " reply
  [[ "$reply" =~ ^[Nn] ]] || gh auth login
fi
# Capture any identity from the real ~/.gitconfig before moving it aside, so a user whose
# name/email lived only there isn't left without one after the symlink shadows it.
EXISTING_NAME="$(git config --global user.name 2>/dev/null || true)"
EXISTING_EMAIL="$(git config --global user.email 2>/dev/null || true)"

# ~/.gitconfig commonly pre-exists; back up a real file so the symlink doesn't eat it, without
# clobbering a backup from an earlier run.
if [[ -e "$HOME/.gitconfig" && ! -L "$HOME/.gitconfig" ]]; then
  backup="$HOME/.gitconfig.pre-prompt-mac"
  [[ -e "$backup" ]] && backup="$backup.$(date +%s)"
  mv "$HOME/.gitconfig" "$backup"
fi
ln -sfn "$DIR/.gitconfig" "$HOME/.gitconfig"

# Identity is personal, so keep it out of the committed .gitconfig and in git's XDG config.
# Reuse whatever git can already see (incl. a prior run's XDG config), then the rescued identity,
# then derive one from the authenticated GitHub account.
mkdir -p "$HOME/.config/git"
if ! git config --get user.email >/dev/null 2>&1; then
  if [[ -n "$EXISTING_EMAIL" ]]; then
    git config --file "$HOME/.config/git/config" user.email "$EXISTING_EMAIL"
    [[ -n "$EXISTING_NAME" ]] && git config --file "$HOME/.config/git/config" user.name "$EXISTING_NAME"
  elif gh auth status >/dev/null 2>&1; then
    gh_login="$(gh api user --jq .login)"
    gh_id="$(gh api user --jq .id)"
    gh_name="$(gh api user --jq '.name // empty')"
    gh_email="$(gh api user --jq '.email // empty')"
    [[ -z "$gh_name" ]] && gh_name="$gh_login"
    [[ -z "$gh_email" ]] && gh_email="${gh_id}+${gh_login}@users.noreply.github.com"
    git config --file "$HOME/.config/git/config" user.name "$gh_name"
    git config --file "$HOME/.config/git/config" user.email "$gh_email"
  fi
fi

GIT_EMAIL="$(git config --get user.email 2>/dev/null || true)"
if [[ -z "$GIT_EMAIL" ]]; then
  echo "⚠️  No Git identity found. Run 'gh auth login' or set user.email, then re-run this script to finish signing setup."
else
  SIGNING_KEY="$HOME/.ssh/id_ed25519"
  if [[ ! -f "$SIGNING_KEY" ]]; then
    echo "🔑 Generating an SSH signing key ($SIGNING_KEY)"
    mkdir -p "$HOME/.ssh"
    ssh-keygen -t ed25519 -C "$GIT_EMAIL" -f "$SIGNING_KEY" -N ""
  fi
  # Rebuild the public key from the private one if it's missing, so later reads don't abort under `set -e`.
  [[ -f "$SIGNING_KEY.pub" ]] || ssh-keygen -y -f "$SIGNING_KEY" >"$SIGNING_KEY.pub"

  signer_line="$GIT_EMAIL namespaces=\"git\" $(cat "$SIGNING_KEY.pub")"
  touch "$HOME/.config/git/allowed_signers"
  grep -qxF "$signer_line" "$HOME/.config/git/allowed_signers" || echo "$signer_line" >>"$HOME/.config/git/allowed_signers"

  # Upload the public key to GitHub as a signing key (needs `gh auth login`; skipped otherwise).
  if gh auth status >/dev/null 2>&1; then
    key_body="$(awk '{print $2}' "$SIGNING_KEY.pub")"
    if ! gh ssh-key list 2>/dev/null | grep -Fq -- "$key_body"; then
      gh ssh-key add "$SIGNING_KEY.pub" --type signing --title "$(scutil --get ComputerName 2>/dev/null || hostname -s) (prompt-mac)"
    fi
  fi
fi

# Docker Compose and Buildx are Homebrew formulae, but the `docker` CLI only searches a few system
# dirs for plugins — none of which is Homebrew's on Apple Silicon. Symlink them into the user plugin
# dir so the plugin forms (`docker compose`, `docker buildx`) work, not just the standalone binaries.
echo "🔌 Linking Docker CLI plugins (compose, buildx)"
mkdir -p "$HOME/.docker/cli-plugins"
for plugin in docker-compose docker-buildx; do
  ln -sfn "$(brew --prefix "$plugin")/bin/$plugin" "$HOME/.docker/cli-plugins/$plugin"
done

# Services (colima needs virtualization the CI runner doesn't grant)
if [[ -z "${CI:-}" ]]; then
  echo "🐳 Starting colima service"
  brew services start colima
fi

# Automatic daily Homebrew update + upgrade + cleanup (via the DomT4/homebrew-autoupdate tap).
# Homebrew requires third-party tap commands to be explicitly trusted before they can run.
# Skipped in CI: --sudo needs a cached password and installs a LaunchAgent.
if [[ -z "${CI:-}" ]]; then
  echo "🔄 Enabling automatic Homebrew updates"
  brew trust --command domt4/autoupdate/autoupdate
  if ! ls "$HOME/Library/LaunchAgents/"*homebrew-autoupdate* >/dev/null 2>&1; then
    brew autoupdate start 86400 --upgrade --cleanup --immediate --sudo
  fi
fi

tldr --update || true

# chsh needs a password, so skip it in CI.
if [[ -z "${CI:-}" && "${SHELL:-}" != *zsh ]]; then
  chsh -s "$(command -v zsh)"
fi

echo "✅ Done. Restart your terminal — znap will bootstrap plugins on first launch."
echo "    Reminder: run 'gh auth login', then re-run this script to upload the signing key to GitHub."
