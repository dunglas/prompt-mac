#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://github.com/dunglas/prompt-mac.git"

# This setup targets Apple Silicon macOS only
if [[ "$(uname)" != "Darwin" || "$(uname -m)" != "arm64" ]]; then
  echo "🛑 This script only supports macOS on Apple Silicon." >&2
  exit 1
fi

# Homebrew as a base layer: a familiar escape hatch, required by the homebrew-php plugin,
# and the source of the Command Line Tools (git) used to clone this repo. mise installs
# packages into the same prefix and interoperates with it.
if ! command -v brew >/dev/null 2>&1; then
  echo "🍺 Installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/opt/homebrew/bin/brew shellenv)"

# mise is the orchestrator: dev tools from its registry, and Homebrew bottles / casks /
# App Store apps declared in mise.toml and installed by `mise bootstrap`.
if ! command -v mise >/dev/null 2>&1; then
  echo "🧰 Installing mise"
  curl -fsSL https://mise.run | sh
fi
export PATH="$HOME/.local/bin:$PATH"

# Locate the repo. Run normally, mise.toml sits next to this script. Run as a one-liner
# (`curl … | bash`) it doesn't, so clone the repo to a permanent home (dotfiles are
# symlinked from it, so it must persist).
SOURCE="${BASH_SOURCE[0]:-}"
DIR=""
[[ -n "$SOURCE" ]] && DIR="$(cd -- "$(dirname -- "$SOURCE")" >/dev/null 2>&1 && pwd || true)"
if [[ -z "$DIR" || ! -f "$DIR/mise.toml" ]]; then
  DIR="${PROMPT_MAC_DIR:-$HOME/prompt-mac}"
  if [[ -d "$DIR/.git" ]]; then
    echo "📥 Updating prompt-mac in $DIR"
    git -C "$DIR" pull --ff-only || echo "⚠️  Couldn't fast-forward $DIR; using the existing checkout"
  else
    echo "📥 Cloning prompt-mac into $DIR"
    git clone "$REPO_URL" "$DIR"
  fi
fi

# One declarative command provisions the whole machine from mise.toml: system packages
# (brew bottles + casks + App Store apps), dotfiles, login shell, the daily-upgrade
# launchd agent, dev tools, and the `bootstrap` task (Docker plugins, colima, VS Code
# extensions).
cd "$DIR"

# The Homebrew-PHP plugin isn't in mise's registry, so register it before bootstrap
# installs the [tools] (it provides `php` + `composer` from prebuilt bottles).
mise plugins install --force homebrew-php https://github.com/naviapps/asdf-homebrew-php.git

echo "🚀 Bootstrapping the machine with mise"
mise trust "$DIR/mise.toml"
mise bootstrap --yes

echo "✅ Done. Restart your terminal, then:"
echo "    • run 'gh auth login' to authenticate with GitHub"
echo "    • run 'rtk init --global' to activate agent token compression"
