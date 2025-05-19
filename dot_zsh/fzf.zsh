# fzf setup - compatible with both Homebrew and MacPorts
# This file is managed by chezmoi

# Source fzf.zsh from either Homebrew or MacPorts installation, or fall back to ~/.fzf.zsh
if [[ "$HAS_HOMEBREW" -eq 1 ]]; then
  # For Homebrew installation
  BREW_PREFIX=$(brew --prefix 2>/dev/null)
  if [[ -f "$BREW_PREFIX/opt/fzf/shell/completion.zsh" ]]; then
    source "$BREW_PREFIX/opt/fzf/shell/completion.zsh"
  fi
  if [[ -f "$BREW_PREFIX/opt/fzf/shell/key-bindings.zsh" ]]; then
    source "$BREW_PREFIX/opt/fzf/shell/key-bindings.zsh"
  fi
elif [[ "$HAS_MACPORTS" -eq 1 ]]; then
  # For MacPorts installation
  if [[ -f "/opt/local/share/fzf/shell/completion.zsh" ]]; then
    source "/opt/local/share/fzf/shell/completion.zsh"
  fi
  if [[ -f "/opt/local/share/fzf/shell/key-bindings.zsh" ]]; then
    source "/opt/local/share/fzf/shell/key-bindings.zsh"
  fi
fi

# Fallback to standard fzf.zsh if installed via git
[[ -f ~/.fzf.zsh ]] && source ~/.fzf.zsh

# Try to find the best search tool available
if has_command fd; then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
elif has_command rg; then
  export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git/*"'
elif has_command ag; then
  export FZF_DEFAULT_COMMAND='ag -g ""'
elif has_command find; then
  export FZF_DEFAULT_COMMAND='find . -type f -not -path "*/\.git/*" -not -path "*/node_modules/*"'
fi

export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_R_OPTS="--preview 'echo {}' --preview-window down:3:hidden --bind '?:toggle-preview'"
export FZF_ALT_C_OPTS="--preview 'tree -C {} | head -200'"

# fzf git branch selection
fbr() {
  local branches branch
  branches=$(git branch | grep -v HEAD | fgrep -v '*' | awk '{print $1}')
  branch=$(echo "$branches" | fzf --preview="git log -1 {}")
  echo $branch
}

# fzf git checkout completion
_fzf_complete_git() {
  ARGS="$@"
  if [[ $ARGS == 'git checkout'* ]]; then
    local FZF_COMPLETION_OPTS="+s -n 2 --with-nth=1..2 -d '\t' --ansi --preview='git log -1 --color=always {3}'"
    _fzf_complete "" "$@" < <(
      {
        (git branch -a |
          fgrep -v HEAD |
          fgrep -v '*' |
          sed "s/.* //" |
          sed -e 's#^remotes/[^/]*/\(.*\)#\1\t&#' |
          sort -u |
          awk '{if (!$2) print "\x1b[34;1mlocal branch\x1b[m\t" $1, "\t", $1; else print "\x1b[34;1mremote branch\x1b[m\t" $1, "\t", $2}') &
        (git tag | awk '{print "\x1b[31;1mtag\x1b[m\t" $1}')
      }
    )
  else
    eval "zle ${fzf_default_completion:-expand-or-complete}"
  fi
}

_fzf_complete_git_post() {
  cut -f2
}