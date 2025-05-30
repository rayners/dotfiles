# Personal Dotfiles

This repository contains my personal configuration files managed with [chezmoi](https://chezmoi.io/).

## Overview

Cross-platform dotfiles supporting macOS and Linux with the following tools:

### Terminal & Shell
- **Kitty Terminal**: Primary terminal with Maple Mono NF font, transparency, custom keybindings
- **Ghostty Terminal**: Alternative terminal configuration
- **Tmux**: Terminal multiplexer with Catppuccin theme, git integration, custom prefix (Ctrl-A)
- **Zsh**: Shell with syntax highlighting, completions, and custom aliases

### Window Management (macOS)
- **AeroSpace**: Tiling window manager with Alt-based keyboard shortcuts
- **SketchyBar**: Custom status bar with system information

### Development Tools
- **Neovim**: Default editor with vim/vi aliases
- **Mise**: Runtime version manager for Node.js, Python, Ruby
- **Git**: Configuration with delta diff tool
- **Font setup**: Maple Mono NF (primary), JetBrainsMono Nerd Font (fallback)

## Quick Start

### New Machine Setup

1. **Install chezmoi**:
   ```bash
   # macOS
   brew install chezmoi
   
   # Linux
   curl -sfL https://get.chezmoi.io | sh
   ```

2. **Initialize from this repository**:
   ```bash
   chezmoi init --apply rayners/dotfiles
   ```

3. **Install packages**:
   ```bash
   # macOS
   ~/.config/scripts/install-packages.sh
   
   # Linux  
   ~/.config/scripts/install-packages.sh
   ```

### Daily Usage

```bash
# Pull and apply latest changes
chezmoi update

# Edit a config file
chezmoi edit ~/.config/kitty/kitty.conf

# See what would change
chezmoi diff

# Apply pending changes
chezmoi apply

# Add a new file to chezmoi
chezmoi add ~/.config/new-tool/config

# Commit changes to git
chezmoi git add .
chezmoi git commit -m "Update configuration"
chezmoi git push
```

## Configuration Structure

### Font System
Fonts are centrally managed in `.chezmoi.toml.tmpl`:
- Primary: `{{ .fonts.monospace }}` (Maple Mono NF)
- Size: `{{ .fonts.monospace_size }}` (14pt)
- UI: `{{ .fonts.ui }}` (SF Pro)
- Fallbacks: JetBrainsMono Nerd Font, Fira Code, Menlo, Monaco

### Package Management
Packages are defined in `.chezmoidata/packages.yaml`:
- **Common**: Cross-platform packages (neovim, tmux, git, etc.)
- **Platform-specific**: macOS (brew/macports) and Linux (apt/dnf/pacman/zypper)
- **Automatic mapping**: Different package names across distributions

### Template Variables
Access configuration data in templates:
```toml
{{ .fonts.monospace }}           # Font name
{{ .fonts.monospace_size }}      # Font size
{{ .is_work_machine }}           # Boolean flag
{{ .package_manager }}           # homebrew/apt/dnf/etc
{{ .paths.homebrew_prefix }}     # Platform paths
```

## Key Features

### Cross-Platform Support
- Automatic OS detection and package manager selection
- Platform-specific configurations with shared common base
- Conditional template logic for Linux distributions

### Font Management
- Centralized font configuration with template variables
- Automatic font installation mapping for package managers
- Consistent typography across all applications

### Git Integration
- Custom `git-current-info` script for tmux status line
- Branch/ticket extraction for development workflows
- Delta diff tool integration

### Tmux Enhancements
- Custom prefix key (Ctrl-A)
- Git branch display in status bar
- Mouse support and sensible defaults
- Plugin management with TPM

### Zsh Configuration
- Platform-aware aliases
- Package manager detection
- Editor preferences (neovim as default)
- Conditional tool availability checks

## Customization

### Adding New Configurations
1. Add config file: `chezmoi add ~/.config/tool/config`
2. Convert to template if needed: `chezmoi chattr +template ~/.config/tool/config`
3. Use variables: Replace hardcoded values with `{{ .variable }}`

### Updating Fonts
Edit `.chezmoi.toml.tmpl`:
```toml
[data.fonts]
    monospace = "Your Font Name"
    monospace_size = 16
```

### Platform-Specific Configs
Use conditional blocks in templates:
```bash
{{- if eq .chezmoi.os "darwin" }}
# macOS-specific configuration
{{- else if eq .chezmoi.os "linux" }}
# Linux-specific configuration
{{- end }}
```

## Troubleshooting

### Config Template Changes
If you see "config file template has changed":
```bash
chezmoi init  # Regenerate config from template
```

### Package Installation Issues
Check package manager detection:
```bash
chezmoi data | grep package_manager
```

### Font Problems
Verify font installation:
```bash
# macOS
brew list | grep font

# Linux
fc-list | grep "Font Name"
```

## Repository Structure

```
.
├── .chezmoi.toml.tmpl           # Configuration template
├── .chezmoidata/
│   └── packages.yaml            # Package definitions
├── dot_config/
│   ├── aerospace/               # Window manager
│   ├── kitty/                   # Terminal config
│   ├── tmux/                    # Terminal multiplexer
│   ├── sketchybar/              # Status bar
│   └── bin/                     # Custom scripts
├── dot_zsh/                     # Shell configuration
└── run_onchange_*.sh.tmpl       # Installation scripts
```

## Links

- [Chezmoi Documentation](https://chezmoi.io/user-guide/)
- [Repository](https://github.com/rayners/dotfiles)
- [Issues](https://github.com/rayners/dotfiles/issues)