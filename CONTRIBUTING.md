# Contributing to mac-setup

Welcome to the `mac-setup` project! We appreciate your interest in contributing. This document outlines the vision for the project, its code structure, and guidelines for contributing.

## Project Vision

The `mac-setup` project aims to be a robust and easily customizable framework for automating macOS machine setup. Our goal is to provide a consistent, efficient, and user-friendly way to configure macOS environments, separating core framework logic from individual user customizations.

We envision a plugin-based architecture where users can easily add or modify setup routines for applications, macOS settings, and shell configurations. The framework will be consumable as a dependency, allowing users to manage their personal dotfiles in a separate repository while leveraging the core `mac-setup` functionality.

## Codebase Structure

The repository is organized into several key directories:

*   **`.git/`**: Git version control data.
*   **`.taskmaster/`**: Local task management data for `task-master.dev`.
*   **`alfred/`**: Contains Alfred preferences and workflows.
*   **`brew/`**: Homebrew-related scripts and `Brewfile`.
    *   `Brewfile`: Lists Homebrew formulae and casks to be installed.
    *   `install.sh`: Script to install Homebrew and bundle packages.
    *   `jdk.sh`: Script for setting up JDK paths.
*   **`common/`**: Shared shell functions used across various scripts.
    *   `functions.sh`: Contains utility functions like `detect_homebrew_prefix`.
*   **`istatmenus/`**: iStat Menus configuration files.
*   **`iterm2/`**: iTerm2 preferences and arrangements.
*   **`osx/`**: Scripts for configuring macOS system settings.
    *   `install.sh`: Orchestrates the execution of other OSX configuration scripts.
    *   `finder.sh`, `menu-and-dock.sh`, `privacy.sh`, `screencapture.sh`, `touchbar.sh`, `track-and-keyboard.sh`, `ui.sh`: Individual scripts for specific macOS settings.
*   **`shell/`**: Shell-related configurations and scripts (primarily Fish shell).
    *   `install.sh`: Script to install Fish shell and Oh My Fish.
    *   `omf/`: Oh My Fish installation and dependency scripts.
    *   `git/`: Git-related shell configurations.
    *   `*.fish`: Fish shell configuration files.
*   **`spectacle/`**: Spectacle application settings.
*   **`xcode/`**: Xcode-related installation scripts.
*   **`bootstrap.sh`**: Initial script to download and prepare the repository.
*   **`install.sh`**: Main installation orchestrator script.
*   **`README.md`**: User-facing documentation.
*   **`verify.sh`**: Script to verify the setup.

## Coding Guidelines

To maintain consistency and quality, please adhere to the following guidelines:

*   **Shell Scripts:**
    *   Use `#!/bin/bash` for Bash scripts.
    *   Strive for idempotency: Scripts should be safely re-runnable without causing unintended side effects.
    *   Add comments to explain complex logic or non-obvious commands.
    *   Use `set -e` to exit immediately if a command exits with a non-zero status.
    *   Use `set -u` to treat unset variables as an error.
*   **Python Scripts:**
    *   Follow PEP 8 style guidelines.
    *   Add docstrings to functions and modules.
*   **Error Handling:** Implement robust error handling in scripts.
*   **Testing:**
    *   Before submitting changes, run `verify.sh` to ensure your changes haven't broken existing checks.
    *   If adding new features, consider how they can be verified by `verify.sh`.

## How to Contribute

1.  **Fork the repository** and clone it to your local machine.
2.  **Create a new branch** for your feature or bug fix.
3.  **Implement your changes**, adhering to the coding guidelines.
4.  **Test your changes** thoroughly using `verify.sh`.
5.  **Commit your changes** with a clear and concise commit message.
6.  **Push your branch** to your fork.
7.  **Create a Pull Request** to the `main` branch of the upstream repository.

Thank you for helping us build a better `mac-setup` framework!
