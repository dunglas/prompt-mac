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
brew bundle install --file="$DIR/Brewfile"

# Config files (symlinked so the repo stays the source of truth)
echo "🔗 Linking config files"
ln -sfn "$DIR/.zshrc" "$HOME/.zshrc"

mkdir -p "$HOME/.config/ghostty"
ln -sfn "$DIR/config.ghostty" "$HOME/.config/ghostty/config"

mkdir -p "$HOME/.config/mise"
ln -sfn "$DIR/mise.toml" "$HOME/.config/mise/config.toml"

mkdir -p "$HOME/.config/nvim"
ln -sfn "$DIR/init.lua" "$HOME/.config/nvim/init.lua"

VSCODE_USER="$HOME/Library/Application Support/Code/User"
mkdir -p "$VSCODE_USER"
ln -sfn "$DIR/settings.json" "$VSCODE_USER/settings.json"

# Language runtimes (Node, Python/uv, PHP, Go) from the global mise config.
# PHP uses the naviapps/asdf-homebrew-php plugin (Homebrew bottles, no source build),
# which isn't in mise's default registry, so register it first.
echo "🧰 Installing language runtimes"
mise plugins install --force homebrew-php https://github.com/naviapps/asdf-homebrew-php.git
mise install

# Docker Compose and Buildx are Homebrew formulae, but the `docker` CLI only searches a few system
# dirs for plugins — none of which is Homebrew's on Apple Silicon. Symlink them into the user plugin
# dir so the plugin forms (`docker compose`, `docker buildx`) work, not just the standalone binaries.
echo "🔌 Linking Docker CLI plugins (compose, buildx)"
mkdir -p "$HOME/.docker/cli-plugins"
for plugin in docker-compose docker-buildx; do
  ln -sfn "$(brew --prefix "$plugin")/bin/$plugin" "$HOME/.docker/cli-plugins/$plugin"
done

# Services
echo "🐳 Starting colima service"
brew services start colima

# Automatic daily Homebrew update + upgrade + cleanup (via the DomT4/homebrew-autoupdate tap).
# Homebrew requires third-party tap commands to be explicitly trusted before they can run.
echo "🔄 Enabling automatic Homebrew updates"
brew trust --command domt4/autoupdate/autoupdate
if ! ls "$HOME/Library/LaunchAgents/"*homebrew-autoupdate* >/dev/null 2>&1; then
  brew autoupdate start 86400 --upgrade --cleanup --immediate --sudo
fi

tldr --update || true

if [[ "${SHELL:-}" != *zsh ]]; then
  chsh -s "$(command -v zsh)"
fi

echo "✅ Done. Restart your terminal — znap will bootstrap plugins on first launch."
echo "    Reminder: run 'gh auth login' for GitHub."
