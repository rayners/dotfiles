#!/bin/bash
# Install Tmux Plugin Manager (TPM) and plugins

set -eu

echo "=== Installing Tmux Plugin Manager ==="

# Create tmux plugins directory if it doesn't exist
mkdir -p ~/.tmux/plugins

# Install TPM if not already installed
if [[ ! -d ~/.tmux/plugins/tpm ]]; then
  echo "Installing TPM..."
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
else
  echo "TPM already installed"
fi

# Install plugins if tmux is running
if command -v tmux >/dev/null 2>&1; then
  echo "Installing tmux plugins..."
  ~/.tmux/plugins/tpm/scripts/install_plugins.sh
else
  echo "Tmux not found - plugins will be installed when you first start tmux"
fi

echo "TPM installation complete!"
echo "To install plugins in tmux, press Ctrl+A + I"