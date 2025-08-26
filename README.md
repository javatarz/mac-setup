# mac-setup: Your Automated macOS Setup Framework

Welcome to `mac-setup`! This project provides a robust and easily customizable framework to automate the setup of your macOS machine. Our goal is to make setting up a new Mac, or maintaining an existing one, consistent, efficient, and hassle-free.

## ✨ Features

*   **Automated Installation:** Installs essential tools, Homebrew packages, and configures your shell.
*   **Customizable:** Easily tailor installations and settings to your preferences.
*   **Secure File Transfer:** A simple, local network mechanism to transfer sensitive files between machines.
*   **Verification:** A script to confirm your setup is correctly applied.

## 🚀 Getting Started

Follow these steps to set up your macOS machine using `mac-setup`.

### Prerequisites

Before you begin, ensure you have:

*   A macOS machine running (at least) OSX Catalina.
*   An active internet connection.
*   Administrator privileges on your machine.
*   Basic familiarity with using the macOS Terminal.

### Installation Steps

1.  **Initial Bootstrap:**
    This command downloads and prepares the `mac-setup` repository on your machine.

    ```bash
    bash <(curl -s https://raw.githubusercontent.com/javatarz/mac-setup/apple-silicon/bootstrap.sh)
    ```



3.  **Run the Main Installation:**
    This command clones the `mac-setup` repository to a permanent location and runs the main installation script.

    2.  Run the Main Installation:
    This command clones the `mac-setup` repository to a permanent location and runs the main installation script.

    ```bash
    mkdir -p ~/projects/personal && \
    cd ~/projects/personal && \
    git clone https://github.com/javatarz/mac-setup.git && \
    cd mac-setup && \
    git checkout main && \
    ./install.sh
    ```

4.  **Finalize Setup:**
    *   Log out and back in to apply all macOS and shell changes.
    *   Log in to the App Store in the background (if you haven't already).

## ⚙️ Customizing Your Setup

`mac-setup` is designed to be easily customizable. Here's how you can tailor it to your needs:

*   **Homebrew Packages (`brew/Brewfile`):**
    Edit `brew/Brewfile` to add or remove Homebrew formulae (`brew`), Casks (`cask`), or Mac App Store apps (`mas`).
    Example: `brew "my-new-cli-tool"` or `cask "my-new-app"`.
*   **Shell Configurations (`shell/`):**
    Modify the `.fish` files in the `shell/` directory to add custom aliases, functions, or environment variables for your Fish shell.
*   **macOS Settings (`osx/`):**
    The scripts in `osx/` apply various macOS system preferences. You can edit these `.sh` files to enable/disable specific settings or add new ones.
    *   **Tip:** To discover new `defaults write` commands, you can use the `bef` and `aft` aliases (defined in `shell/git.fish` after setup) to compare `defaults read` output before and after making a change via the macOS UI.
*   **Application Configurations (Alfred, iTerm2, iStat Menus):**
    For applications like Alfred, iTerm2, and iStat Menus, their configurations are stored directly within their respective directories (`alfred/`, `iterm2/`, `istatmenus/`). Make changes via the application's UI, and then commit the updated files to this repository.

## 🔄 Updating Your Setup

To keep your machine's setup up-to-date with changes in this repository:

1.  **Pull Latest Changes:**
    ```bash
    cd ~/projects/personal/mac-setup
    git pull origin main
    ```
2.  **Re-run Installation:**
    ```bash
    ./install.sh
    ```
    This will apply any new or updated configurations.

## ✅ Verify Your Setup

After running the installation, you can verify that everything is set up correctly by running the `verify.sh` script:

```bash
./verify.sh
```

This script will check for installed tools, shell configurations, and the presence of your transferred files. It will report any discrepancies.

## 🤝 Contributing

We welcome contributions! Please see our `CONTRIBUTING.md` file for guidelines on how to contribute to this project.

## ❓ Troubleshooting

*   **`command not found` errors:** Ensure your shell is restarted after installation.
*   **Homebrew issues:** Run `brew doctor` for diagnostics.
*   **Script failures:** Check the output for specific error messages. The `verify.sh` script can help pinpoint issues.