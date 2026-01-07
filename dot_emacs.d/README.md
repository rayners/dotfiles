# Emacs Configuration (minimal-emacs.d)

This directory contains customizations for [minimal-emacs.d](https://github.com/jamescherti/minimal-emacs.d).

## Structure

**Chezmoi-managed files** (tracked and synced):
- `post-init.el` - All user customizations built on minimal-emacs.d
- `custom.el` - Emacs customize system settings
- `projects` - Project list for project.el
- `.chezmoiignore` - Files/directories to ignore

**Git-managed files** (NOT tracked by chezmoi):
- `init.el` - Core minimal-emacs.d init (managed upstream)
- `early-init.el` - Core minimal-emacs.d early-init (managed upstream)
- `.git/` - minimal-emacs.d git repository

**Generated/ignored directories**:
- `elpa/` - Package installation directory
- `tree-sitter/` - Tree-sitter grammar libraries
- `autosave/` - Auto-save files
- `forge-database.sqlite` - Forge cache

## Updating minimal-emacs.d Core

To update the minimal-emacs.d foundation:

```bash
cd ~/.emacs.d
git pull origin main
```

## Making Customizations

Edit `~/.emacs.d/post-init.el` directly, then:

```bash
# Copy changes to chezmoi
cp ~/.emacs.d/post-init.el ~/.local/share/chezmoi/dot_emacs.d/post-init.el

# Or use chezmoi to manage the file
chezmoi add ~/.emacs.d/post-init.el
```

## Migration Notes

Migrated from literate org-mode config (init.org) to pure elisp on 2026-01-07.

Key changes:
- Switched from Elpaca to package.el
- Removed Fontaine (using direct font setting)
- Removed Flycheck (using Flymake with Eglot)
- Added ruby-lsp globally via mise (no Gemfile changes needed)
- Simplified configuration following minimal-emacs.d philosophy
