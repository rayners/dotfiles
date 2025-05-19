# This file is managed by chezmoi
# It detects package managers across macOS and Linux and sets up appropriate paths

# Function to check if a command exists
function has_command() {
  command -v "$1" &>/dev/null
}

# Function to determine OS
function detect_os() {
  case "$(uname -s)" in
    Darwin)
      export CURRENT_OS="macos"
      ;;
    Linux)
      export CURRENT_OS="linux"
      # Detect specific Linux distribution
      if [[ -f /etc/debian_version ]]; then
        export LINUX_DISTRO="debian"
      elif [[ -f /etc/fedora-release ]]; then
        export LINUX_DISTRO="fedora"
      elif [[ -f /etc/arch-release ]]; then
        export LINUX_DISTRO="arch"
      elif [[ -f /etc/alpine-release ]]; then
        export LINUX_DISTRO="alpine"
      elif [[ -f /etc/redhat-release ]]; then
        export LINUX_DISTRO="redhat"
      elif [[ -f /etc/SuSE-release ]]; then
        export LINUX_DISTRO="suse"
      else
        export LINUX_DISTRO="unknown"
      fi
      ;;
    *)
      export CURRENT_OS="unknown"
      ;;
  esac
}

# Global flags to track which package managers are installed
export HAS_HOMEBREW=0
export HAS_MACPORTS=0
export HAS_APT=0
export HAS_DNF=0
export HAS_YUM=0
export HAS_PACMAN=0
export HAS_ZYPPER=0
export HAS_APKS=0

# Detect OS first
detect_os

# Check for macOS package managers
if [[ "$CURRENT_OS" == "macos" ]]; then
  # Check for Homebrew (macOS or Linux)
  if has_command brew; then
    export HAS_HOMEBREW=1
    eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv 2>/dev/null || /home/linuxbrew/.linuxbrew/bin/brew shellenv 2>/dev/null)"
    BREW_PREFIX=$(brew --prefix 2>/dev/null)
    
    # Add Homebrew completions if they exist
    if [[ -d "$BREW_PREFIX/share/zsh/site-functions" ]]; then
      fpath=("$BREW_PREFIX/share/zsh/site-functions" $fpath)
    fi
    
    # Add coreutils to PATH if installed
    if [[ -d "$BREW_PREFIX/opt/coreutils/libexec/gnubin" ]]; then
      path=("$BREW_PREFIX/opt/coreutils/libexec/gnubin" $path)
      [[ -d "$BREW_PREFIX/opt/coreutils/libexec/gnuman" ]] && manpath=("$BREW_PREFIX/opt/coreutils/libexec/gnuman" $manpath)
    fi
  fi

  # Check for MacPorts
  if has_command port; then
    export HAS_MACPORTS=1
    
    # Add MacPorts paths if not already in PATH
    if [[ -d "/opt/local/bin" ]]; then
      path=("/opt/local/bin" "/opt/local/sbin" $path)
      manpath=("/opt/local/share/man" $manpath)
    fi
    
    # Add MacPorts completions if they exist
    if [[ -d "/opt/local/share/zsh/site-functions" ]]; then
      fpath=("/opt/local/share/zsh/site-functions" $fpath)
    fi
  fi
# Check for Linux package managers
elif [[ "$CURRENT_OS" == "linux" ]]; then
  # Check for Homebrew on Linux (Linuxbrew)
  if has_command brew; then
    export HAS_HOMEBREW=1
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv 2>/dev/null || brew shellenv 2>/dev/null)"
    BREW_PREFIX=$(brew --prefix 2>/dev/null)
    
    # Add Homebrew completions if they exist
    if [[ -d "$BREW_PREFIX/share/zsh/site-functions" ]]; then
      fpath=("$BREW_PREFIX/share/zsh/site-functions" $fpath)
    fi
  fi

  # Debian/Ubuntu - apt
  if has_command apt || has_command apt-get; then
    export HAS_APT=1
  fi

  # Fedora - dnf
  if has_command dnf; then
    export HAS_DNF=1
  fi

  # CentOS/RHEL - yum
  if has_command yum; then
    export HAS_YUM=1
  fi

  # Arch Linux - pacman
  if has_command pacman; then
    export HAS_PACMAN=1
  fi

  # openSUSE - zypper
  if has_command zypper; then
    export HAS_ZYPPER=1
  fi

  # Alpine - apk
  if has_command apk; then
    export HAS_APKS=1
  fi

  # Add standard Linux paths if not already in PATH
  if [[ -d "/usr/local/bin" ]]; then
    path=("/usr/local/bin" "/usr/local/sbin" $path)
  fi
fi

# Deduplicate PATH (in case entries were added multiple times)
typeset -U path
typeset -U manpath
typeset -U fpath

# Export the modified PATH
export PATH
export MANPATH
export FPATH

# Helper functions for cross-platform package management
function pm_install() {
  local package="$1"
  
  if [[ "$HAS_HOMEBREW" -eq 1 ]]; then
    brew install "$package"
  elif [[ "$HAS_MACPORTS" -eq 1 ]]; then
    sudo port install "$package"
  elif [[ "$HAS_APT" -eq 1 ]]; then
    sudo apt install -y "$package"
  elif [[ "$HAS_DNF" -eq 1 ]]; then
    sudo dnf install -y "$package"
  elif [[ "$HAS_YUM" -eq 1 ]]; then
    sudo yum install -y "$package"
  elif [[ "$HAS_PACMAN" -eq 1 ]]; then
    sudo pacman -S --noconfirm "$package"
  elif [[ "$HAS_ZYPPER" -eq 1 ]]; then
    sudo zypper install -y "$package"
  elif [[ "$HAS_APKS" -eq 1 ]]; then
    sudo apk add "$package"
  else
    echo "No supported package manager found."
    return 1
  fi
}

function pm_update() {
  if [[ "$HAS_HOMEBREW" -eq 1 ]]; then
    brew update && brew upgrade
  elif [[ "$HAS_MACPORTS" -eq 1 ]]; then
    sudo port selfupdate && sudo port upgrade outdated
  elif [[ "$HAS_APT" -eq 1 ]]; then
    sudo apt update && sudo apt upgrade -y
  elif [[ "$HAS_DNF" -eq 1 ]]; then
    sudo dnf upgrade -y
  elif [[ "$HAS_YUM" -eq 1 ]]; then
    sudo yum update -y
  elif [[ "$HAS_PACMAN" -eq 1 ]]; then
    sudo pacman -Syu --noconfirm
  elif [[ "$HAS_ZYPPER" -eq 1 ]]; then
    sudo zypper update -y
  elif [[ "$HAS_APKS" -eq 1 ]]; then
    sudo apk update && sudo apk upgrade
  else
    echo "No supported package manager found."
    return 1
  fi
}

function pm_search() {
  local package="$1"
  
  if [[ "$HAS_HOMEBREW" -eq 1 ]]; then
    brew search "$package"
  elif [[ "$HAS_MACPORTS" -eq 1 ]]; then
    port search "$package"
  elif [[ "$HAS_APT" -eq 1 ]]; then
    apt search "$package"
  elif [[ "$HAS_DNF" -eq 1 ]]; then
    dnf search "$package"
  elif [[ "$HAS_YUM" -eq 1 ]]; then
    yum search "$package"
  elif [[ "$HAS_PACMAN" -eq 1 ]]; then
    pacman -Ss "$package"
  elif [[ "$HAS_ZYPPER" -eq 1 ]]; then
    zypper search "$package"
  elif [[ "$HAS_APKS" -eq 1 ]]; then
    apk search "$package"
  else
    echo "No supported package manager found."
    return 1
  fi
}

function pm_list_installed() {
  if [[ "$HAS_HOMEBREW" -eq 1 ]]; then
    brew list
  elif [[ "$HAS_MACPORTS" -eq 1 ]]; then
    port installed
  elif [[ "$HAS_APT" -eq 1 ]]; then
    dpkg --get-selections | grep -v deinstall
  elif [[ "$HAS_DNF" -eq 1 ]]; then
    dnf list installed
  elif [[ "$HAS_YUM" -eq 1 ]]; then
    yum list installed
  elif [[ "$HAS_PACMAN" -eq 1 ]]; then
    pacman -Q
  elif [[ "$HAS_ZYPPER" -eq 1 ]]; then
    zypper search -i
  elif [[ "$HAS_APKS" -eq 1 ]]; then
    apk info
  else
    echo "No supported package manager found."
    return 1
  fi
}