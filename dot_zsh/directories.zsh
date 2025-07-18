# Directories configuration
# This file is managed by chezmoi

# Directory navigation options
setopt auto_cd
setopt auto_pushd

# Set up cdpath for quick navigation
# Add your common project directories here
cdpath=(
  $HOME/Code 
  $HOME/Code/fswd 
  $HOME/Code/ember
)

# Load autojump if available
if [[ "$CURRENT_OS" == "macos" ]]; then
  # macOS paths with Homebrew
  if [[ "$HAS_HOMEBREW" -eq 1 ]] && has_command brew; then
    [[ -s "$(brew --prefix)/etc/autojump.sh" ]] && . "$(brew --prefix)/etc/autojump.sh"
    [[ -s "$(brew --prefix)/etc/profile.d/z.sh" ]] && . "$(brew --prefix)/etc/profile.d/z.sh"
  fi
elif [[ "$CURRENT_OS" == "linux" ]]; then
  # Common Linux paths for autojump and z
  for aj_path in \
    "/usr/share/autojump/autojump.sh" \
    "/etc/profile.d/autojump.sh" \
    "/usr/local/share/autojump/autojump.sh"; do
    if [[ -s "$aj_path" ]]; then
      . "$aj_path"
      break
    fi
  done
  
  # Common Linux paths for z
  for z_path in \
    "/usr/share/z/z.sh" \
    "/etc/profile.d/z.sh" \
    "/usr/local/share/z/z.sh"; do
    if [[ -s "$z_path" ]]; then
      . "$z_path"
      break
    fi
  done
fi

# Local installation fallback
[[ -s "$HOME/.local/share/autojump/autojump.sh" ]] && . "$HOME/.local/share/autojump/autojump.sh"
[[ -s "$HOME/.local/share/z/z.sh" ]] && . "$HOME/.local/share/z/z.sh"

eval "$(zoxide init zsh)"
