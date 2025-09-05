# Programming Environment Manager (mise with fallbacks)
# This file is managed by chezmoi

# Function to initialize mise
function init-mise() {
  # Check if mise is available
  if has_command mise; then
    eval "$(mise activate zsh)"
    eval "$(mise activate --shims)"
    return 0
  fi
  
  # Check for package manager installations
  if [[ "$CURRENT_OS" == "macos" ]]; then
    if [[ "$HAS_HOMEBREW" -eq 1 ]] && has_command brew; then
      if brew list mise &>/dev/null; then
        eval "$(mise activate zsh)"
        eval "$(mise activate --shims)"
        return 0
      fi
    elif [[ "$HAS_MACPORTS" -eq 1 ]] && has_command port; then
      if port installed mise &>/dev/null; then
        eval "$(mise activate zsh)"
        eval "$(mise activate --shims)"
        return 0
      fi
    fi
  elif [[ "$CURRENT_OS" == "linux" ]]; then
    # Try standard Linux paths for mise
    for mise_path in "/usr/bin/mise" "/usr/local/bin/mise" "$HOME/.local/bin/mise"; do
      if [[ -x "$mise_path" ]]; then
        eval "$($mise_path activate zsh)"
        eval "$(mise activate --shims)"
        return 0
      fi
    done
  fi
  
  return 1
}

# Function to initialize rbenv as fallback
function init-rbenv-fallback() {
  # Check common installation paths
  local rbenv_paths=(
    "$HOME/.rbenv/bin"      # User install (most common)
    "/usr/local/rbenv/bin"  # System-wide install
    "/opt/rbenv/bin"        # Alternative location
  )
  
  # Add rbenv to PATH if it exists and isn't already in PATH
  for rbenv_path in "${rbenv_paths[@]}"; do
    if [[ -d "$rbenv_path" && ! "$PATH" =~ "$rbenv_path" ]]; then
      export PATH="$rbenv_path:$PATH"
      break
    fi
  done
  
  # Initialize rbenv if the command exists
  if has_command rbenv; then
    eval "$(rbenv init -)"
    return 0
  else
    # Check for package manager installations
    if [[ "$CURRENT_OS" == "macos" ]]; then
      if [[ "$HAS_HOMEBREW" -eq 1 ]] && has_command brew; then
        if brew list rbenv &>/dev/null; then
          eval "$(rbenv init -)"
          return 0
        fi
      elif [[ "$HAS_MACPORTS" -eq 1 ]] && has_command port; then
        if port installed rbenv &>/dev/null; then
          eval "$(rbenv init -)"
          return 0
        fi
      fi
    elif [[ "$CURRENT_OS" == "linux" ]]; then
      # Try standard locations
      for rbenv_init in "/usr/lib/rbenv/libexec/rbenv-init" "/usr/local/lib/rbenv/libexec/rbenv-init"; do
        if [[ -x "$rbenv_init" ]]; then
          eval "$($rbenv_init -)"
          return 0
        fi
      done
    fi
  fi
  
  return 1
}

# Function to load nvm as fallback
function load-nvm-fallback() {
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

# Function to handle .tool-versions or .nvmrc files for fallback managers
function load-version-files() {
  # If mise is not available, check for version files
  if ! has_command mise; then
    # Check for .tool-versions file (used by mise/asdf)
    if [[ -f .tool-versions && -r .tool-versions ]]; then
      # Parse .tool-versions for specific tools
      while IFS= read -r line; do
        if [[ "$line" =~ ^ruby[[:space:]]+(.+)$ ]]; then
          local ruby_version="${match[1]}"
          if has_command rbenv; then
            rbenv shell "$ruby_version" 2>/dev/null || true
          fi
        elif [[ "$line" =~ ^nodejs[[:space:]]+(.+)$ ]] || [[ "$line" =~ ^node[[:space:]]+(.+)$ ]]; then
          local node_version="${match[1]}"
          if has_command nvm; then
            nvm use "$node_version" 2>/dev/null || true
          fi
        fi
      done < .tool-versions
    fi
    
    # Check for .nvmrc file for Node.js
    if [[ -f .nvmrc && -r .nvmrc ]] && has_command nvm; then
      nvm use 2>/dev/null || true
    fi
    
    # Check for .ruby-version file for Ruby
    if [[ -f .ruby-version && -r .ruby-version ]] && has_command rbenv; then
      local ruby_version=$(cat .ruby-version)
      rbenv shell "$ruby_version" 2>/dev/null || true
    fi
  fi
}

# Initialize programming environment managers
if init-mise; then
  # mise is available and initialized
  export USING_MISE=1
else
  # Fall back to individual managers
  export USING_MISE=0
  init-rbenv-fallback
  load-nvm-fallback
  
  # Set up directory change hook for version files only if not using mise
  autoload -U add-zsh-hook
  add-zsh-hook chpwd load-version-files
  
  # Check for version files in the current directory
  load-version-files
fi

# Initialize pyenv if available (regardless of mise availability)
if has_command pyenv; then 
  eval "$(pyenv init -)"; 
fi

if has_command direnv; then
  eval "$(direnv hook zsh)";
fi

