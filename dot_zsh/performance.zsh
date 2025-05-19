# Shell startup performance measurement
# This file is managed by chezmoi

# Enable measurement by setting ZSH_PROFILE_STARTUP=true
# For example: ZSH_PROFILE_STARTUP=true zsh

if [[ "$ZSH_PROFILE_STARTUP" == true ]]; then
  # Profile startup
  zmodload zsh/datetime
  setopt PROMPT_SUBST
  PS4='+$EPOCHREALTIME %N:%i> '
  
  # Save original options
  local original_options=$(set +o)
  
  # Set options for profiling
  setopt XTRACE
  
  # Create temporary log file
  local logfile=$(mktemp zsh_profile.XXXXXX)
  exec 3>&2 2>$logfile
  
  # Function to stop profiling and display results
  function _stop_profiling() {
    # Restore original options
    eval "$original_options"
    unsetopt XTRACE
    
    # Close log file and restore stderr
    exec 2>&3 3>&-
    
    # Output timing results
    echo "Zsh startup profile results:"
    echo "============================="
    
    # Process log file and display timing data
    cat $logfile | awk '{ 
      gsub(/\+/, "", $1)
      current_time = $1
      if (prev_time == 0) prev_time = current_time
      timing = current_time - prev_time
      sum_timing += timing
      # Extract the function or command
      cmd = $0
      gsub(/^[^>]*>\s*/, "", cmd)
      # Skip internal zsh stuff
      if (cmd !~ /^\\s*$/ && cmd !~ /^_/ && cmd !~ /^__/ && $2 !~ /^_/) {
        printf("%.6f %s\n", timing, cmd)
      }
      prev_time = current_time
    }' | sort -n | tail -20
    
    echo "============================="
    echo "Total startup time: $(cat $logfile | wc -l) lines, $(du -h $logfile | cut -f1) disk space"
    
    # Clean up
    rm $logfile
  }
  
  # Register cleanup function
  autoload -Uz add-zsh-hook
  add-zsh-hook precmd _stop_profiling
fi

# Function to measure the time it takes to run a command
function timeit() {
  local start_time=$(date +%s.%N)
  "$@"
  local end_time=$(date +%s.%N)
  local elapsed=$(echo "$end_time - $start_time" | bc)
  echo "Execution time: $elapsed seconds"
}

# Function to check shell startup time
function zsh-startup-time() {
  for i in $(seq 1 10); do
    /usr/bin/time zsh -i -c exit
  done
}