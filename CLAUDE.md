# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a macOS dotfiles/setup automation repository that configures a new Mac with applications, tools, and settings. The framework prioritizes consistency and idempotency - scripts should be safely re-runnable.

## Common Commands

```bash
# Full installation (runs all setup scripts)
./install.sh

# Verify setup is correctly applied
./verify.sh

# Bootstrap on a fresh machine (downloads and runs install)
bash <(curl -s https://raw.githubusercontent.com/javatarz/mac-setup/apple-silicon/bootstrap.sh)
```

## Architecture

### Installation Flow

`install.sh` orchestrates setup in this order:
1. `xcode/install.sh` - Xcode Command Line Tools
2. `brew/install.sh` - Homebrew and packages from `brew/Brewfile`
3. `shell/install.sh` - Fish shell, Oh My Fish, and shell configs
4. `shell/fetch_secrets.sh` - Private secrets from external source
5. `iterm2/install.sh` - iTerm2 preferences
6. `spectacle/install.sh` - Window management
7. `alfred/install.sh` - Alfred preferences and workflows
8. `osx/install.sh` - macOS system preferences via `defaults write`
9. `verify.sh` - Validates installation

### Key Directories

- **`brew/`** - `Brewfile` lists all Homebrew formulae, casks, and Mac App Store apps
- **`shell/`** - Fish shell configs (`.fish` files symlinked to `~/.config/fish/conf.d/`)
- **`osx/`** - macOS settings scripts using `defaults write` commands
- **`common/functions.sh`** - Shared utilities: `detect_homebrew_prefix`, `command_exists`, `delete_if_available`
- **`claude/`** - Claude Code configuration (statusline, commands)

### Application Configs

Alfred, iTerm2, and iStat Menus configs are stored directly in their directories. Modify via the application UI, then commit the updated files.

## Shell Script Conventions

- Use `#!/bin/bash` or `#!/bin/sh`
- Include `set -e` to exit on errors
- Scripts must be idempotent (safe to re-run)
- Use `common/functions.sh` for shared utilities like architecture detection

## Customization Points

- **Add/remove packages:** Edit `brew/Brewfile`
- **Shell aliases/functions:** Add/modify `.fish` files in `shell/`
- **macOS settings:** Edit scripts in `osx/` (use `defaults write`)

## Discovery Tip

Use `bef` and `aft` aliases (after setup) to capture `defaults read` output before/after changing macOS settings via UI to discover new `defaults write` commands.

## Important Context

**Secrets:** `shell/fetch_secrets.sh` pulls a file of `export` statements (not version controlled). Consider 1Password CLI as a future improvement (see GitHub issue #21).

**App config directories (`alfred/`, `iterm2/`, `istatmenus/`):** These sync application settings across machines. Managed via each app's UI, not by code. Do not modify directly.

**Claude Code (`claude/`):** Symlinked to `~/.claude/` during install. All custom skills, commands, and configs go here to ensure consistent Claude Code experience across machines.

**Machine-specific variations:** Not currently handled. All machines get identical setup.

**Testing:** No automated testing strategy yet. `verify.sh` catches some issues. OSX `defaults` can be flaky across macOS versions.

**Issue tracking:** GitHub Issues is the source of truth for backlog items.
