# znap Plugin Manager Setup
ZNAP_DIR="$HOME/.znap"
[[ -r "$ZNAP_DIR/znap.zsh" ]] ||
  git clone --depth 1 https://github.com/marlonrichert/zsh-snap.git "$ZNAP_DIR"
source "$ZNAP_DIR/znap.zsh"

# Keep plugin clones out of $HOME (znap defaults repos-dir to $HOME)
zstyle ':znap:*' repos-dir "$ZNAP_DIR/repos"

# History Configuration
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_VERIFY
setopt SHARE_HISTORY

# Default editor (git, less, crontab, etc. inherit this)
export EDITOR="nvim"
export VISUAL="nvim"

# Completions
znap source zsh-users/zsh-completions

# Vi mode — make the whole command line modal (jeffreytse/zsh-vi-mode: mode-aware cursor,
# text objects, surround). `sourcing` init applies its keybindings synchronously, and loading
# it *before* the OMZ plugins, fzf-tab, history search and the fzf keybindings lets those bind
# on top so vi mode doesn't clobber them.
ZVM_INIT_MODE=sourcing
znap source jeffreytse/zsh-vi-mode

# Oh My Zsh plugins (behavior only — completions come from `znap eval` below, so we avoid the
# completion-only plugins that need OMZ's core lib to set $ZSH_CACHE_DIR)
znap source ohmyzsh/ohmyzsh \
  plugins/colored-man-pages plugins/git plugins/sudo

# Completion UI & history search
znap source Aloxaf/fzf-tab
znap source zsh-users/zsh-history-substring-search

# Autosuggestions & syntax highlighting (load last)
znap source zsh-users/zsh-autosuggestions
znap source zdharma-continuum/fast-syntax-highlighting

# Tool initializations & completions (cached via znap eval)
znap eval starship 'starship init zsh'
znap eval zoxide 'zoxide init zsh'
znap eval fzf 'fzf --zsh'
znap eval gh 'gh completion -s zsh'
znap eval docker 'docker completion zsh'
znap eval npm 'npm completion'
znap eval kubectl 'kubectl completion zsh'
znap eval helm 'helm completion zsh'

# Modern CLI Replacements & Aliases
alias ls="eza --icons --git --group-directories-first"
alias ll="eza -lh --icons --git --group-directories-first"
alias la="eza -lah --icons --git --group-directories-first"
alias cat="bat"
alias find="fd"
alias grep="rg"
alias vi="nvim"
alias vim="nvim"
