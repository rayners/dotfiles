# Font Standardization System

This repository includes a centralized font configuration system that applies consistent font settings across multiple applications and automatically installs required fonts on macOS.

## How It Works

1. Font settings are defined in a single location: `chezmoi.toml`
2. Templates use these settings to configure each application
3. When you run `chezmoi apply`:
   - All font settings are updated across applications
   - Required fonts are automatically installed on macOS (if not already present)

## Configured Applications

- **Alacritty**: Terminal emulator
- **Kitty**: Terminal emulator
- **Ghostty**: Terminal emulator
- **Emacs**: Text editor (with fontaine for font presets)

## Changing Fonts

To update fonts across all applications:

1. Edit the font settings in `~/.config/chezmoi/chezmoi.toml`:

```toml
[data.fonts]
    # Primary monospace font for terminals and code
    monospace = "JetBrainsMono Nerd Font"  # Change this to your preferred font
    monospace_size = 14                    # Change the size
    monospace_ligatures = true             # Enable/disable ligatures
    
    # UI font for applications
    ui = "SF Pro"                          # Change UI font
    ui_size = 12                           # Change UI font size
    
    # Fallback monospace fonts
    fallback_monospace = ["Fira Code", "Menlo", "Monaco", "DejaVu Sans Mono"]

[data.fonts.emacs]
    # Emacs-specific font settings
    default_height = 140  # Size 14 * 10
    variable_pitch = "SF Pro"
    fixed_pitch = "JetBrainsMono Nerd Font"
```

2. Apply the changes:

```bash
chezmoi apply
```

## Font Installation on macOS

The system automatically installs required fonts on macOS using Homebrew. The mappings between font names and their Homebrew cask names are defined in `chezmoi.toml`:

```toml
[data.fonts.homebrew_mapping]
    "JetBrainsMono Nerd Font" = "font-jetbrains-mono-nerd-font"
    "Fira Code" = "font-fira-code"
    "Cascadia Code" = "font-cascadia-code"
    # Add more mappings as needed
```

### Adding a New Font

To add a new font:

1. Find the Homebrew cask name for your font:
   ```bash
   brew search font-yourfontname
   ```

2. Add the mapping to your `chezmoi.toml`:
   ```toml
   [data.fonts.homebrew_mapping]
       "Your Font Name" = "font-yourfontname"
   ```

3. Update your font settings to use the new font:
   ```toml
   [data.fonts]
       monospace = "Your Font Name"
   ```

4. Apply the changes:
   ```bash
   chezmoi apply
   ```

## Emacs Font Configuration

The Emacs configuration uses the `fontaine` package to manage fonts. It defines three presets:

1. **default**: Standard coding preset
2. **presentation**: Larger font for presentations/demos
3. **reading**: Optimized for reading text

Switch between presets with:
- `C-c f d`: Default preset
- `C-c f p`: Presentation preset
- `C-c f r`: Reading preset

## Adding Custom Presets to Emacs

Create a file `~/.config/emacs/fontaine-custom.el` with additional presets:

```elisp
;; Add your custom fontaine presets here
(fontaine-set-preset-overrides
 '((custom
    :default-family "Your Custom Font"
    :default-height 120
    :variable-pitch-family "Your Variable Font"
    :fixed-pitch-family "Your Fixed Font")))

;; Add a key binding for your custom preset
(global-set-key (kbd "C-c f c") (lambda () (interactive) (fontaine-set-preset 'custom)))
```

## Adding Support for New Applications

1. Create a template in `~/.config/chezmoi/dot_config/app_name/config.tmpl`
2. Use the font variables in the template
3. Apply the changes with `chezmoi apply`