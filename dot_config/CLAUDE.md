# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal macOS configuration directory (`~/.config`) containing configuration files for various development and productivity tools. It's managed using chezmoi for dotfile management.

Internal `chezmoi` files are stored in `~/.local/share/chezmoi`.

## Key Tools and Configuration

### Terminal and Shell
- **Kitty Terminal**: Main terminal emulator with JetBrainsMono Nerd Font, transparency, and custom key bindings
- **Ghostty Terminal**: Alternative terminal with Maple Mono NF font
- **Tmux**: Terminal multiplexer with Catppuccin theme, Git integration in status bar, and custom keybindings (prefix: Ctrl-A)

### Window Management
- **AeroSpace**: Tiling window manager with extensive keyboard shortcuts using Alt key combinations
  - Focus: Alt+hjkl
  - Move windows: Alt+Shift+hjkl  
  - Workspaces: Alt+1-9, Alt+a-z
  - Service mode: Alt+Shift+semicolon

### System Bar
- **SketchyBar**: Custom status bar with clock, volume, battery, and front app indicators

### Development Environment
- **Mise**: Runtime version manager (Node.js 22 configured)
- **Chezmoi**: Dotfile management with work machine configuration
- **Font preferences**: Maple Mono NF (primary), JetBrainsMono Nerd Font (fallback)

## Configuration Management

### Chezmoi Setup
- Email: david.raynes@example.com
- Work machine: Yes
- Uses: Emacs, nvm, rbenv, pyenv
- Package manager: Homebrew
- Diff tool: delta
- **Configuration data**: Stored in `~/.config/chezmoi/chezmoi.toml` with font settings, paths, and template variables
- **Template data access**: Use `chezmoi data` to view current template variables
- **Font configuration**: Centralized in `[data.fonts]` section with primary/fallback fonts and homebrew mappings

### Package Management
- **Package definitions**: `~/.local/share/chezmoi/.chezmoidata/packages.yaml`
- **Install scripts**: 
  - `~/.local/share/chezmoi/run_onchange_darwin-install-packages.sh.tmpl` (macOS packages)
  - `~/.local/share/chezmoi/run_onchange_install-packages.sh.tmpl` (cross-platform)
  - `~/.local/share/chezmoi/run_onchange_install-fonts.sh.tmpl` (fonts)
- **Key packages**: reattach-to-user-namespace, tmux, fzf, ripgrep, bat, eza, git-delta

### Common Operations
- **Reload AeroSpace config**: Alt+Shift+semicolon, then Esc
- **Reload Kitty config**: F5
- **Tmux prefix**: Ctrl-A (not default Ctrl-B)
- **Split panes**: | (vertical), - (horizontal)

## Font Configuration
- **Primary monospace**: Maple Mono NF (14pt)
- **UI font**: SF Pro (12pt)
- **Emacs fonts**: Fixed pitch Maple Mono NF, variable pitch SF Pro
- **Fallback fonts**: JetBrainsMono Nerd Font, Fira Code, Menlo, Monaco, DejaVu Sans Mono
- **Terminal transparency**: Enabled in Kitty (0.75 opacity)
- **Template variables**: `{{ .fonts.monospace }}`, `{{ .fonts.monospace_size }}`, `{{ .fonts.ui }}`

## System Integration
- **1Password, Zoom**: Configured to float in AeroSpace
- **Git integration**: Status bar shows current branch in tmux
- **OTP Integration**: F10 key binding for OTP output in Kitty
- **Mouse support**: Enabled in tmux

## File Structure
All configurations are in standard XDG config format under `~/.config/` with tool-specific subdirectories.
