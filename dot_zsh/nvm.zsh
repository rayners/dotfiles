# Node Version Manager (nvm) setup
# This file is managed by chezmoi

autoload -U add-zsh-hook

# Function to load nvm with platform-specific paths
function load-nvm() {
  # Export NVM directory (should already be set in .zshenv)
  export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
  
  # Check if we're on macOS
  if [[ "$CURRENT_OS" == "macos" ]]; then
    # Try Homebrew installation first
    if [[ "$HAS_HOMEBREW" -eq 1 ]] && has_command brew; then
      local brew_nvm_prefix="$(brew --prefix nvm 2>/dev/null)"
      if [[ -s "$brew_nvm_prefix/nvm.sh" ]]; then
        source "$brew_nvm_prefix/nvm.sh"
        # Load bash completion if available
        [[ -s "$brew_nvm_prefix/etc/bash_completion.d/nvm" ]] && source "$brew_nvm_prefix/etc/bash_completion.d/nvm"
        return 0
      fi
    fi
  fi

  # For Linux or macOS without Homebrew nvm
  # Standard installation paths
  if [[ -s "$NVM_DIR/nvm.sh" ]]; then
    source "$NVM_DIR/nvm.sh"
    # Load bash completion if available
    [[ -s "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"
    return 0
  fi
  
  # Alternative installation paths
  for nvm_path in \
    "/usr/local/opt/nvm/nvm.sh" \
    "/usr/share/nvm/nvm.sh" \
    "/usr/local/share/nvm/nvm.sh"; do
    if [[ -s "$nvm_path" ]]; then
      source "$nvm_path"
      return 0
    fi
  done
  
  return 1
}

# Load nvm when entering a directory with .nvmrc
load-nvmrc() {
  # If we're in a directory with an .nvmrc file
  if [[ -f .nvmrc && -r .nvmrc ]]; then
    # Load nvm if it's not already loaded
    if ! has_command nvm; then
      load-nvm
    fi
    
    # Use the node version specified in .nvmrc
    nvm use
  elif [[ -n "$NVM_VERSION" && $(nvm current 2>/dev/null) != "$NVM_VERSION" ]]; then
    # If we have a default version set and it's not the current one
    if has_command nvm; then
      echo "Switching to default Node version: $NVM_VERSION"
      nvm use "$NVM_VERSION"
    fi
  fi
}

# Try to load NVM immediately if available (for faster shell startup)
if [[ -z "$NVM_LAZY_LOAD" || "$NVM_LAZY_LOAD" != "true" ]]; then
  load-nvm >/dev/null 2>&1
fi

# Hook the directory change event to look for .nvmrc files
add-zsh-hook chpwd load-nvmrc

# Check for .nvmrc in the current directory right now
load-nvmrc