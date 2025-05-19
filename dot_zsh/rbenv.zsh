# Ruby Version Manager (rbenv) setup
# This file is managed by chezmoi

# Function to initialize rbenv
function init-rbenv() {
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
    # Initialize rbenv and set up shims
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

# Initialize rbenv
init-rbenv

# Define a function for delayed loading if needed
# This can be useful if you want to call rbenv manually the first time
rbenv() {
  unfunction rbenv
  init-rbenv
  rbenv "$@"
}