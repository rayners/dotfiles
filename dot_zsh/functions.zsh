# Useful zsh functions
# This file is managed by chezmoi

# Make a directory and cd into it
function mkcd() {
  mkdir -p "$1" && cd "$1"
}

# Extract archives
function extract() {
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2)   tar xjf $1     ;;
      *.tar.gz)    tar xzf $1     ;;
      *.bz2)       bunzip2 $1     ;;
      *.rar)       unrar e $1     ;;
      *.gz)        gunzip $1      ;;
      *.tar)       tar xf $1      ;;
      *.tbz2)      tar xjf $1     ;;
      *.tgz)       tar xzf $1     ;;
      *.zip)       unzip $1       ;;
      *.Z)         uncompress $1  ;;
      *.7z)        7z x $1        ;;
      *)           echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# Find a file with a pattern in name
function ff() { find . -type f -name "*$1*" -ls ; }

# Find a directory with a pattern in name
function fd() { find . -type d -name "*$1*" -ls ; }

# Find processes by name
function psg() { ps aux | grep "[${1[1]}]${1[2,-1]}" ; }

# Show disk usage of current directory, sorted
function dus() { du -h --max-depth=1 "$@" | sort -h ; }

# Count lines of code in a directory
function loc() {
  local dir="${1:-.}"
  # Count lines in common source files
  find "$dir" -type f \( -name "*.py" -o -name "*.js" -o -name "*.jsx" -o -name "*.ts" -o -name "*.tsx" -o -name "*.c" -o -name "*.cpp" -o -name "*.h" -o -name "*.rb" -o -name "*.java" -o -name "*.go" -o -name "*.php" -o -name "*.html" -o -name "*.css" -o -name "*.scss" -o -name "*.rs" \) | xargs wc -l
}

# Copy file contents to clipboard
function copy() {
  if [[ -f "$1" ]]; then
    if has_command pbcopy; then  # macOS
      cat "$1" | pbcopy
    elif has_command xclip; then  # Linux with X11
      cat "$1" | xclip -selection clipboard
    elif has_command wl-copy; then  # Linux with Wayland
      cat "$1" | wl-copy
    else
      echo "No clipboard tool found"
      return 1
    fi
    echo "Copied contents of $1 to clipboard"
  else
    echo "$1 is not a file"
    return 1
  fi
}

# Generate a random password
function genpass() {
  local length=${1:-16}
  if has_command openssl; then
    openssl rand -base64 48 | cut -c1-$length
  else
    LC_ALL=C tr -dc 'A-Za-z0-9_!@#$%^&*()-+=' < /dev/urandom | head -c $length; echo
  fi
}

# Check if a website is down
function isdown() {
  curl -s --head --request GET "$1" | grep "200 OK" > /dev/null && echo "$1 is up" || echo "$1 seems to be down"
}

# Simple HTTP server in current directory
function serve() {
  local port=${1:-8000}
  if has_command python3; then
    python3 -m http.server $port
  elif has_command python; then
    python -m SimpleHTTPServer $port
  else
    echo "Python is not installed"
    return 1
  fi
}

# Search for text within files recursively
function ftext() {
  if has_command rg; then
    rg -i "$@"
  elif has_command ag; then
    ag -i "$@"
  else
    grep -r "$@" .
  fi
}

# Get JSON data from a web API
function getjson() {
  if has_command jq; then
    curl -s "$1" | jq .
  else
    curl -s "$1"
  fi
}

# Show git repository status in a compact form
function gits() {
  git status -sb "$@"
}

# Git add, commit, and push in one command
function gacp() {
  git add . && git commit -m "$1" && git push
}

# Find largest files in current directory
function find-big-files() {
  local size=${1:-"+10M"}
  find . -type f -size $size -exec ls -lh {} \; | sort -k5,5 -h
}

# Backup a file with a timestamp
function backup() {
  local filename=$(basename "$1")
  local dir=$(dirname "$1")
  local timestamp=$(date +%Y%m%d%H%M%S)
  cp -a "$1" "${dir}/${filename}.${timestamp}.bak"
  echo "Backed up $1 to ${dir}/${filename}.${timestamp}.bak"
}

# Convert YouTube video to MP3
function youtube-to-mp3() {
  if has_command youtube-dl; then
    youtube-dl --extract-audio --audio-format mp3 "$1"
  else
    echo "youtube-dl is not installed"
  fi
}

# Docker functions
if has_command docker; then
  # Stop all containers
  function docker-stop-all() {
    docker stop $(docker ps -a -q)
  }
  
  # Remove all containers
  function docker-rm-all() {
    docker rm $(docker ps -a -q)
  }
  
  # Remove all images
  function docker-rmi-all() {
    docker rmi $(docker images -q)
  }
  
  # Docker cleanup
  function docker-cleanup() {
    docker system prune -a -f --volumes
  }
fi

# Show weather
function weather() {
  local location=${1:-""}
  curl -s "wttr.in/$location"
}

# Convert string to lowercase
function lowercase() {
  echo "$1" | tr '[:upper:]' '[:lower:]'
}

# Convert string to uppercase
function uppercase() {
  echo "$1" | tr '[:lower:]' '[:upper:]'
}

# Calculate directory sizes in a human-readable format
function dirsize() {
  du -h --max-depth=1 "${1:-.}" | sort -h
}

# Create a simple note
function note() {
  local notes_dir="$HOME/notes"
  mkdir -p "$notes_dir"
  local date=$(date +%Y-%m-%d)
  local note_file="$notes_dir/$date.md"
  if [[ "$1" == "-l" ]]; then
    # List notes
    ls -la "$notes_dir"
  elif [[ "$1" == "-s" ]]; then
    # Search notes
    grep -r "$2" "$notes_dir"
  else
    # Add note
    echo "# Note from $(date)" >> "$note_file"
    echo "$@" >> "$note_file"
    echo "Note added to $note_file"
  fi
}

# Get local IP address
function localip() {
  if [[ "$CURRENT_OS" == "macos" ]]; then
    ipconfig getifaddr en0 || ipconfig getifaddr en1
  else
    hostname -I | awk '{print $1}'
  fi
}