# prompt-mac

**Turn a fresh Mac into a modern, agent-first development powerhouse with a single command.**

```console
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/dunglas/prompt-mac/main/install.sh)"
```

Hey, I'm **Kévin Dunglas** (creator of [FrankenPHP](https://frankenphp.dev), [Mercure](https://mercure.rocks), [API Platform](https://api-platform.com), and core maintainer of [Caddy](https://caddyserver.com), [Symfony](https://symfony.com), and [PHP](https://php.net)).
Over the years, I've dedicated my career to building open-source tools that make developer workflows faster, deployments smoother, and runtimes more resilient.

Today, the engineering landscape has fundamentally shifted. We aren't just typing out lines of code anymore, we are pairing with heavy-duty AI coding agents. Yet every time I unbox a fresh Mac, I find myself wasting precious time fighting macOS defaults, manually symlinking dotfiles, and wrestling with environment setups.

That's why I built `prompt-mac`. It's my personal, highly opinionated, one-shot setup script for **Apple Silicon macOS**. It configures an ultra-lean, hyper-focused ecosystem of CLI tools, apps, and editor configs tuned explicitly for **coding-agent workflows**.

It is **prompt to install, prompt to use, and completely AI-powered.**

> 🚀 **Proudly Sponsored by [Les-Tilleuls.coop](https://les-tilleuls.coop)**
> Built in collaboration with the team at Les-Tilleuls.coop, your premier open-source, development, and AI engineering experts. We help teams build, scale, and optimize next-generation digital architectures.

---

## ⚡ Usage (The Quickstart)

Ready to ship? Open your stock terminal, paste this one-liner, and let it run.

The script is entirely **idempotent**—you can re-run it (or the one-liner) anytime to pick up upstream changes to the `Brewfile` or configurations. Already-installed packages are safely skipped.

```console
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/dunglas/prompt-mac/main/install.sh)"
```

### Manual Installation & Customization

Prefer to read the code first or want to tweak it? Clone and run it by hand. The installer works identically either way (set `PROMPT_MAC_DIR` if you want to clone somewhere other than `~/prompt-mac`):

```bash
git clone https://github.com/dunglas/prompt-mac.git ~/prompt-mac
cd ~/prompt-mac
./install.sh
```

*Note: Because configuration files are symlinked directly into this directory, **do not delete the cloned repo** after installation, or your configurations will break!*

---

## 🎯 The Philosophy

* 🧭 **macOS-native, not macOS-against.** We don't fight the system's sensible defaults. Safari stays your default browser; Finder, Spotlight, and friends are left completely alone. We *add* elite tooling rather than ripping out what already works natively.
* 🪶 **Pragmatically minimalist.** I can't stand bloated, 5,000-line shell setups. Every configuration file in this repo is just a handful of lines. The value is in *which* tools get installed, leaning heavily on modern defaults and tweaking only what earns its keep.
* 🤖 **AI-first context management.** Running coding agents blindly kills your token budget. A dedicated agent stack (Claude, Claude Code, cmux, `rtk`) is wired in from the start, featuring tools that aggressively cut token usage so you can keep costs low and context windows clear.
* 🧰 **One toolbelt, everywhere.** No split brains. The exact same modern CLI tools feel completely at home whether you live in **Ghostty**/**cmux** or inside **VS Code**'s integrated terminal.

---

## 🚀 A Polished Shell Environment

Out of the box, you get a beautiful, blazing-fast terminal setup. Because it's all driven by clean `zsh` config, it behaves identically in a standalone window or inside your IDE:

* **[Ghostty](https://ghostty.org)** — The primary terminal: GPU-accelerated, utilizing Apple's native system color palette (perfectly tracking macOS light/dark shifts), JetBrains Mono, subtle blur, and an instant drop-down **quake terminal** layout you can summon from anywhere with `Ctrl`+`@`.
* **[cmux](https://www.cmux.dev/)** — A powerful, Ghostty-based terminal manager with vertical tabs and desktop notifications, custom-built for running and monitoring multiple AI coding agents in parallel.
* **[starship](https://starship.rs)** — A minimal, informative, and blindingly fast cross-shell prompt.
* **`zsh`, supercharged** — Powered by [znap](https://github.com/marlonrichert/zsh-snap) to load plugins in parallel. It caches tool initializations and completions, bringing you instant shell startup times while providing autosuggestions, fast syntax highlighting, history-substring search, and beautiful `fzf-tab` completion menus.

### Transparent Muscle-Memory Upgrades

Your muscle memory just works, but the classic commands are transparently aliased to faster, friendlier, modern tools:

| You type | You get | Why it's better |
| --- | --- | --- |
| `ls` / `ll` / `la` | [`eza`](https://eza.rocks) | Beautiful layouts, icons, directories-first sorting, and live Git status. |
| `cat` | [`bat`](https://github.com/sharkdp/bat) | Rich syntax highlighting, native git modifications sidebar, and automatic paging. |
| `find` | [`fd`](https://github.com/sharkdp/fd) | Simple syntax, ignores hidden files/`.gitignore` by default, and incredibly fast. |
| `grep` | [`ripgrep`](https://github.com/BurntSushi/ripgrep) | The absolute fastest recursive command-line regex engine in existence. |
| `cd` | [`zoxide`](https://github.com/ajeetdsouza/zoxide) | A smart directory jumper that learns your habits and lets you skip paths. |
| `vi` / `vim` | [`neovim`](https://neovim.io) | Sets `nvim` as your default `$EDITOR`, inheriting terminal color configurations seamlessly. |

*Rounded out by `fzf` (fuzzy finder), `jq`, `gh`, and `tldr` for instant documentation.*

### Vim Everywhere

If you think in Vim motions, this setup speaks your language. Modal editing is hardcoded by default across your entire workflow:

| Where | How | Details |
| --- | --- | --- |
| **Shell** | `zsh` via [zsh-vi-mode](https://github.com/jeffreytse/zsh-vi-mode) | Brings modal command-line editing, text objects, surround support, and a mode-aware cursor right to your prompt. |
| **Editor** | [`neovim`](https://neovim.io) | Automatically mapped as your global `$EDITOR` so system utilities, `git commit`, and `crontab` open it instantly. |
| **VS Code** | [Vim extension](https://marketplace.visualstudio.com/items?itemName=vscodevim.vim) | The official `vscodevim` extension comes pre-installed, unifying your keystrokes across the GUI. |

*Want to extend Vim motions to the rest of your operating system? These aren't pre-installed, but are highly recommended additions:*

* **Safari** — [Vimari](https://apps.apple.com/app/vimari/id1480933944) for lightweight keyboard navigation.
* **Chrome / Firefox** — [Vimium](https://vimium.github.io/) for flawless, mouse-free web browsing.
* **Xcode** — Turn it on natively via: **Editor ▸ Vim Mode**.

---

## 🤖 AI-First Toolchain

`prompt-mac` treats AI agents as first-class citizens. The environment is engineered from the ground up to support massive agent workloads without blowing past your API limits.

```
┌─────────────────┐      Output      ┌──────────────────────┐
│  Shell Command  │ ────────────────> │ rtk (Token Killer)   │
└─────────────────┘                  └──────────────────────┘
                                                │
                                                │ Compresses 60-90%
                                                ▼
                                     ┌──────────────────────┐
                                     │  Claude Code Agent   │
                                     └──────────────────────┘
```

The following tools ship directly in the core `Brewfile`:

| Tool | Installed as | Purpose |
| --- | --- | --- |
| [Claude](https://claude.ai) | cask | Anthropic's official desktop application workspace. |
| [Claude Code](https://claude.com/claude-code) | cask + extension | Anthropic's agentic CLI tool, working natively in the terminal and VS Code. |
| [cmux](https://www.cmux.dev/) | cask | A multiplexed environment tailored for running AI agents side-by-side. |
| [rtk](https://www.rtk-ai.app/) | brew | "Rust Token Killer" — intercepts and compresses bloated terminal command outputs before they hit the agent's context, dropping token usage by 60–90%. |

### Setting Up rtk

`rtk` is installed out of the box but remains dormant until registered. Running `rtk init` hooks a global wrapper into your environment configuration. Every shell command your agent executes is automatically optimized (e.g., `git status` dynamically processes through `rtk git status`):

```sh
rtk init --global

```

*Note: Make sure to restart any active coding agents after running this command! You can check your total infrastructure savings at any time by typing `rtk gain`.*

### Recommended Upgrade: caveman

While it isn't bundled into the system package manager directly, I highly recommend installing **[caveman](https://github.com/JuliusBrussee/caveman)**. This is a specialized skill for Claude Code that slashes ~65% of *output* tokens by prompting the model to respond concisely while preserving code integrity and error messages exactly.

Because it works entirely locally without external network overhead, you can add it to your agent with:

```bash
claude plugin marketplace add JuliusBrussee/caveman
claude plugin install caveman@caveman
```

*`rtk` and `caveman` form a perfect loop: `rtk` compresses what goes **into** the AI context, while `caveman` optimizes what comes **out** of it.*

---

## 🛠️ Complete Package Inventory

Everything installed by the script is explicitly managed via the [`Brewfile`](./Brewfile). Below is the complete roadmap of what gets added to your system:

### 📦 Language Runtimes (`mise`)

We consciously bypass standard Homebrew for developer runtimes. Instead, we use [`mise`](https://github.com/jdx/mise) managed via a global [`mise.toml`](./mise.toml). This allows you to retain a solid global default while effortlessly pinning project-specific engine versions via local project manifests.

| Runtime | Version | Notes |
| --- | --- | --- |
| **Node.js** | `lts` | Stable Long-Term Support build. |
| **Go** | `latest` | Ready for cloud-native building. |
| **PHP** | `latest` | High-performance native Homebrew bottles via the `naviapps/asdf-homebrew-php` tap (no slow source compilations). **Composer** is installed automatically alongside it. |
| **Python** | `latest` | A clean global system interpreter for general scripting. |
| **uv** | `latest` | The modern, hyper-fast standard for Python virtual environments and dependency management. |

### 🖥️ Applications (`cask`)

*Safari remains your primary system browser. Additional applications are installed cleanly without interfering with operating system boundaries:*

* **Ghostty** & **cmux** — Your primary terminal emulator and multi-agent workflow workspace.
* **Visual Studio Code** — The premier GUI code editor.
* **Claude** & **Claude Code** — Anthropic's desktop layout and agent CLI engine.
* **JetBrains Mono Nerd Font** — Beautiful developer typography packed with comprehensive glyph/icon support.
* **Firefox** & **Google Chrome** — Pre-installed explicitly for cross-browser testing suites.
* **AdGuard** — Lightweight, system-wide protection against ad networks and telemetry tracking.
* **ProtonVPN** & **Tailscale** — Premium security and overlay mesh-networking capabilities.
* **Slack**, **Discord**, & **Signal** — Your communication toolbelt.

### 🍏 Mac App Store Apps (`mas`)

* **LanguageTool** — Localized, high-fidelity grammar, style, and spell checking providing system-wide integrations and Safari extension support.
* **Refined GitHub** — An essential browser extension that significantly cleans up and streamlines the GitHub user interface.

### 🧩 VS Code Extensions (`vscode`)

* **Claude Code** — Instant agent access right inside your project windows.
* **GitLens** & **GitHub Pull Requests** — Seamless visual blame, historical timelines, and deep pull request management.
* **EditorConfig**, **markdownlint**, & **YAML** — Syntax linting and strict code formatting compliance.
* **Vim** — Bringing universal modal keyboard navigation into the GUI editor.
* **Docker** & **Kubernetes** — Visual tools for microservices, manifests, and local container runtimes.
* **Language Engines** — Pre-configured support for **ESLint**, **Prettier**, **Intelephense (PHP)**, **Python (with Pylance & Ruff)**, and official **Go** extensions.

---

## 🐳 Container Infrastructure & Cloud-Native Tooling

* **No Docker Desktop.** We keep macOS fast and lean. All containerization runs cleanly using a lightweight, open-source background VM managed by **colima** paired with standard open-source `docker` binaries. The Compose and Buildx plugins are automatically symlinked directly into `~/.docker/cli-plugins`, so commands like `docker compose` and `docker buildx` work flawlessly out of the box.
* **Local Kubernetes.** Full infrastructure support using `kubectl`, `helm`, and the terminal UI dashboard **`k9s`**. Need a local sandbox cluster? Simply spin up the built-in k3s cluster layer by running:

```bash
colima start --kubernetes
```

This houses Kubernetes elegantly inside the exact same underlying VM running your Docker daemon, meaning no heavy third-party Minikube or alternative configurations are necessary.

---

## ⚙️ Configuration File Mapping

When the installer runs, it automatically symlinks your local repository configuration files out into your system profile. Modifying a file within your local repo immediately updates your live runtime environment:

| Repository Source | System Destination | Purpose |
| --- | --- | --- |
| [`.zshrc`](./.zshrc) | `~/.zshrc` | Sets up the `znap` plugin manager, Oh My Zsh modules (git, sudo, colored man pages), `fzf-tab` menus, aliases, and `$EDITOR` pathways. |
| [`config.ghostty`](./config.ghostty) | `~/.config/ghostty/config` | Configures Ghostty options: dark/light theme syncing, drop-down "quake" layout keys, blur, and opacity settings. |
| [`mise.toml`](./mise.toml) | `~/.config/mise/config.toml` | Declares and maintains your global development language versions. |
| [`init.lua`](./init.lua) | `~/.config/nvim/init.lua` | A lightweight, zero-plugin, ultra-fast Neovim setup utilizing system clipboards, smart-case searching, persistent undo, and terminal color inheritance. |
| [`settings.json`](./settings.json) | `~/Library/Application Support/Code/User/settings.json` | Configures production-ready layout adjustments, font sizes, and typography ligatures for VS Code. |

---

## 🔄 Automated System Maintenance

Your computer shouldn't degrade over time. To solve this, the script provisions an automated background `launchd` service driven by the [`DomT4/homebrew-autoupdate`](https://github.com/DomT4/homebrew-autoupdate) tap. **Once a day** (and automatically upon user login), the system securely executes:

* `brew update` — Syncs the latest available software package recipes.
* `brew upgrade --sudo` — Securely upgrades installed formulae and apps (including background casks like VPNs or system drivers, meaning you may occasionally see a quick system password request).
* `brew cleanup` — Scrubs out legacy cache versions and dangling temporary files.

### Managing Maintenance Routines

```bash
brew autoupdate status   # View daemon health, activity status, and logs
brew autoupdate stop     # Temporarily pause the automated schedule
brew autoupdate delete   # Permanently remove the background automated job
```

---

## 📋 Requirements & Deep Dive

Before pulling the trigger on the installer, ensure your environment meets these baselines:

* You are operating on **Apple Silicon** architecture (M1/M2/M3/M4 series). Intel hardware is not supported, and the installer assumes Homebrew paths live strictly at `/opt/homebrew`.
* You are explicitly signed in to iCloud with an active Apple ID configured for the Mac App Store.
* **First-run App Store installations:** For any App Store software your account has never downloaded before, the installer will launch deep-links straight to the app page so you can click "Get" once. The script then securely resumes.
* **Important Precaution:** The configuration symlinking phase **replaces** pre-existing files found at `~/.zshrc`, Ghostty configurations, mise setups, and VS Code `settings.json`. If you have legacy dotfiles you want to save, back them up before running the installer!

---

## 🎛️ Customization

* **Add or remove tools:** Modify the [`Brewfile`](./Brewfile) and re-run `./install.sh` (or manually trigger `brew bundle install --file=./Brewfile`).
* **Prune software:** Want to make your machine mirror the repo perfectly? Running `brew bundle cleanup --file=./Brewfile` identifies extraneous packages; appending `--force` uninstalls them completely.
* **Shift runtime language versions:** Edit [`mise.toml`](./mise.toml) and execute `mise install`.

---

## 📜 License

[MIT](./LICENSE) — Maintained by **Kévin Dunglas** and the team at **[Les-Tilleuls.coop](https://les-tilleuls.coop)**. Feel free to fork it, adapt it, optimize it for your team, and ship amazing applications!
