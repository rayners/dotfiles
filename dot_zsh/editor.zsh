# Editor configuration
# This file is managed by chezmoi

# Set up editor preferences with Emacs as primary, vim as fallback
# Try to use graphical Emacs when available

# First check for Emacs and set up appropriate EDITOR variables
if has_command emacsclient; then
  # Emacs client is available - check for server
  if pgrep -q "emacs.*daemon" || pgrep -q "emacs"; then
    # Running Emacs detected - use client
    
    # For GUI environments, use graphical client if available
    if [[ -n "$DISPLAY" ]] || [[ "$CURRENT_OS" == "macos" ]] || [[ -n "$WAYLAND_DISPLAY" ]]; then
      export VISUAL="emacsclient -c"
      export EDITOR="emacsclient -c"
      export GIT_EDITOR="emacsclient -c"
    else
      # Terminal-only environment
      export VISUAL="emacsclient -t"
      export EDITOR="emacsclient -t"
      export GIT_EDITOR="emacsclient -t" 
    fi
    
    # Set up alias for quick editing
    alias e="$EDITOR"
    alias ec="emacsclient -c"
    alias et="emacsclient -t"
  else
    # Emacs is installed but no server - use normal Emacs
    export VISUAL="emacs"
    export EDITOR="emacs"
    export GIT_EDITOR="emacs"
    
    # Set up alias for quick editing
    alias e="emacs"
    
    # Add helper for starting Emacs daemon
    alias esd="emacs --daemon"
  fi
elif has_command emacs; then
  # Regular Emacs is available (without client)
  export VISUAL="emacs"
  export EDITOR="emacs"
  export GIT_EDITOR="emacs"
  
  # Set up alias for quick editing
  alias e="emacs"
elif has_command vim; then
  # Fallback to vim if Emacs is not available
  export VISUAL="vim"
  export EDITOR="vim"
  export GIT_EDITOR="vim"
  
  # Set up alias for quick editing
  alias e="vim"
else
  # Last resort - use vi, which should be available on most Unix systems
  export VISUAL="vi"
  export EDITOR="vi"
  export GIT_EDITOR="vi"
  
  # Set up alias for quick editing
  alias e="vi"
fi

# Function to edit in current directory
function edit() {
  if [[ $# -eq 0 ]]; then
    $EDITOR .
  else
    $EDITOR "$@"
  fi
}

# Make sure git uses the right editor for commit messages
export ALTERNATE_EDITOR=""

# Add custom function to start or connect to Emacs daemon
function em() {
  if ! pgrep -q "emacs.*daemon" && ! pgrep -q "emacs"; then
    # No Emacs running, start daemon first
    echo "Starting Emacs daemon..."
    emacs --daemon
  fi
  
  # Connect to daemon
  if [[ -n "$DISPLAY" ]] || [[ "$CURRENT_OS" == "macos" ]] || [[ -n "$WAYLAND_DISPLAY" ]]; then
    emacsclient -c "$@"
  else
    emacsclient -t "$@"
  fi
}