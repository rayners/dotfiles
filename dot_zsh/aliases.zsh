# This file is managed by chezmoi
# Cross-platform aliases for common commands

# Git aliases - work on all platforms
alias gp="git pull"
alias gpu="git push"
alias gpuu="git push -u origin \`git current-branch\`"
alias gpf="git push --force-with-lease"
alias goops="git oops"
alias master="git checkout master"

# Text search - prefer silversearcher-ag if available
if has_command ag; then
  alias otbcheck="ag '{{\\s*(?!::)[^:\\n]*\\|\\s*translate\\s*}}'"
else
  # Fallback to grep if ag isn't available
  alias otbcheck="grep -E '{{\\s*(?!::)[^:\\n]*\\|\\s*translate\\s*}}'"
fi

# Platform-specific aliases
if [[ "$CURRENT_OS" == "macos" ]]; then
  # macOS specific aliases
  alias o="open"
  
  # Homebrew aliases (macOS)
  if [[ "$HAS_HOMEBREW" -eq 1 ]]; then
    alias bup="brew update && brew outdated"
    alias bug="brew upgrade"
  fi
elif [[ "$CURRENT_OS" == "linux" ]]; then
  # Linux specific aliases
  alias o="xdg-open"
  
  # Package manager aliases based on which one is installed
  if [[ "$HAS_APT" -eq 1 ]]; then
    alias bup="sudo apt update && apt list --upgradable"
    alias bug="sudo apt upgrade -y"
  elif [[ "$HAS_DNF" -eq 1 ]]; then
    alias bup="sudo dnf check-update"
    alias bug="sudo dnf upgrade -y"
  elif [[ "$HAS_PACMAN" -eq 1 ]]; then
    alias bup="sudo pacman -Sy && pacman -Qu"
    alias bug="sudo pacman -Syu"
  elif [[ "$HAS_ZYPPER" -eq 1 ]]; then
    alias bup="sudo zypper refresh && zypper list-updates"
    alias bug="sudo zypper update -y"
  fi
  
  # Linux homebrew aliases
  if [[ "$HAS_HOMEBREW" -eq 1 ]]; then
    alias brewup="brew update && brew outdated"
    alias brewug="brew upgrade"
  fi
fi

# Emacs aliases - work on all platforms
alias mu4e="emacsclient -c --no-wait --eval '(mu4e)'"

# Use hub instead of git if available
# if has_command hub; then
#   alias git="hub"
# fi

# Common directory aliases
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."

# Claude CLI
alias claude="$HOME/.claude/local/claude"