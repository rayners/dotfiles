# Enhanced zsh completions
# This file is managed by chezmoi

# Setup compinit with cross-platform support
autoload -Uz compinit

# Set up the cache directory for faster completions
mkdir -p "$ZSH_DIR/cache"

# Set location for .zcompdump files
ZSH_COMPDUMP="$ZSH_DIR/cache/.zcompdump-$HOST-$ZSH_VERSION"

# Initialize completions system once daily or with cache
if [[ -f "$ZSH_COMPDUMP" && ($(date +%j) != $(date -r "$ZSH_COMPDUMP" +%j 2>/dev/null || echo 0)) ]]; then
  # If .zcompdump is older than a day, regenerate it
  compinit -i -d "$ZSH_COMPDUMP"
  # Update the timestamp
  touch "$ZSH_COMPDUMP"
else
  # Otherwise, use the cached version
  compinit -i -C -d "$ZSH_COMPDUMP"
fi

# Configure completion styles
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$ZSH_DIR/cache"

# Case-insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

# Group matches and describe
zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*:matches' group 'yes'
zstyle ':completion:*:options' description 'yes'
zstyle ':completion:*:options' auto-description '%d'
zstyle ':completion:*:corrections' format ' %F{green}-- %d (errors: %e) --%f'
zstyle ':completion:*:descriptions' format ' %F{blue}-- %d --%f'
zstyle ':completion:*:messages' format ' %F{purple} -- %d --%f'
zstyle ':completion:*:warnings' format ' %F{red}-- no matches found --%f'
zstyle ':completion:*:default' list-prompt '%S%M matches%s'
zstyle ':completion:*' format ' %F{yellow}-- %d --%f'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' verbose yes

# Fuzzy match mistyped completions
zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*:match:*' original only
zstyle ':completion:*:approximate:*' max-errors 1 numeric

# Increase the number of errors allowed based on the length of the typed word
zstyle -e ':completion:*:approximate:*' max-errors 'reply=($((($#PREFIX+$#SUFFIX)/3))numeric)'

# Don't complete unavailable commands
zstyle ':completion:*:functions' ignored-patterns '(_*|pre(cmd|exec))'

# Array completion element sorting
zstyle ':completion:*:*:-subscript-:*' tag-order indexes parameters

# Directories
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*:*:cd:*' tag-order local-directories directory-stack path-directories
zstyle ':completion:*:*:cd:*:directory-stack' menu yes select
zstyle ':completion:*:-tilde-:*' group-order 'named-directories' 'path-directories' 'expand'
zstyle ':completion:*' squeeze-slashes true

# History
zstyle ':completion:*:history-words' stop yes
zstyle ':completion:*:history-words' remove-all-dups yes
zstyle ':completion:*:history-words' list false
zstyle ':completion:*:history-words' menu yes

# Environment variables
zstyle ':completion::*:(-command-|export):*' fake-parameters ${${${_comps[(I)-value-*]#*,}%%,*}:#-*-}

# Git
# Find git-completion.bash in various possible locations
GIT_COMPLETION_PATHS=(
  ~/.zsh/functions/git-completion.bash                 # User directory
  /usr/local/share/zsh/site-functions/git-completion.bash  # Homebrew (Intel Mac)
  /opt/homebrew/share/zsh/site-functions/git-completion.bash  # Homebrew (Apple Silicon)
  /usr/share/zsh/site-functions/git-completion.bash     # Linux
  /etc/zsh_completion.d/git-completion.bash            # Some Linux distros
)

for git_completion in "${GIT_COMPLETION_PATHS[@]}"; do
  if [[ -f "$git_completion" ]]; then
    zstyle ':completion:*:*:git:*' script "$git_completion"
    
    # Define the function that bridges bash completion to zsh
    __git_zsh_bash_func () {
      emulate -L ksh
      local command=$1
      shift
      command git $command "$@"
    }
    
    break
  fi
done

# Separate git commands by groups
zstyle ':completion:*:*:git:*' group-order \
  'main commands' \
  'branch commands' \
  'remote commands' \
  'third-party commands' \
  'common commands' \
  'all commands'

# Populate hostname completion
zstyle -e ':completion:*:hosts' hosts 'reply=(
  ${=${=${=${${(f)"$(cat {/etc/ssh/ssh_,~/.ssh/}known_hosts(|2)(N) 2>/dev/null)"}%%[#| ]*}//\]:[0-9]*/ }//,/ }//\[/ }
  ${=${(f)"$(cat /etc/hosts(|)(N) <<(ypcat hosts 2>/dev/null))"}%%\#*}
  ${=${${${${(@M)${(f)"$(cat ~/.ssh/config 2>/dev/null)"}:#Host *}#Host }:#*\**}:#*\?*}}
)'

# Kubectl
if has_command kubectl; then
  source <(kubectl completion zsh 2>/dev/null)
fi

# npm
if has_command npm; then
  source <(npm completion 2>/dev/null)
fi

# pip
if has_command pip; then
  eval "$(pip completion --zsh 2>/dev/null)"
fi

# Docker
if has_command docker; then
  source <(docker completion zsh 2>/dev/null)
fi

# Chezmoi
if has_command chezmoi; then
  source <(chezmoi completion zsh 2>/dev/null)
fi