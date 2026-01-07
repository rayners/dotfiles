;;; post-init.el --- User customizations after minimal-emacs.d -*- lexical-binding: t; -*-

;; Author: David Raynes
;; Created: 2026-01-07
;; Keywords: config

;;; Commentary:
;; This file contains all user customizations built on top of minimal-emacs.d.
;; Organization prioritizes simplicity and clarity over performance optimization.

;;; Code:

;;; ============================================================================
;;; macOS Modifier Keys
;;; ============================================================================

;; Use Command as Meta on macOS
(when (eq system-type 'darwin)
  (setq mac-command-modifier 'meta)
  (setq mac-option-modifier 'super))

;;; ============================================================================
;;; Package Management Bootstrap
;;; ============================================================================

;; Add MELPA repository for packages
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)

;; Initialize package system
(unless (bound-and-true-p package--initialized)
  (package-initialize))

;; Ensure use-package is available (minimal-emacs.d installs it)
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)  ; Auto-install packages

;;; ============================================================================
;;; Completion Stack (ESSENTIAL)
;;; ============================================================================

;; Vertico - Vertical completion UI
(use-package vertico
  :init
  (vertico-mode))

;; Marginalia - Rich annotations in the minibuffer
(use-package marginalia
  :init
  (marginalia-mode))

;; Orderless - Flexible completion style
(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-defaults nil)
  (completion-category-overrides '((file (styles partial-completion)))))

;; Consult - Enhanced minibuffer commands
(use-package consult
  :bind (;; C-c bindings (mode-specific-map)
         ("C-c h" . consult-history)
         ("C-c m" . consult-mode-command)
         ("C-c k" . consult-kmacro)
         ;; C-x bindings (ctl-x-map)
         ("C-x M-:" . consult-complex-command)
         ("C-x b" . consult-buffer)
         ("C-x 4 b" . consult-buffer-other-window)
         ("C-x 5 b" . consult-buffer-other-frame)
         ("C-x r b" . consult-bookmark)
         ("C-x p b" . consult-project-buffer)
         ;; M-s bindings (search-map)
         ("M-s d" . consult-find)
         ("M-s D" . consult-locate)
         ("M-s g" . consult-grep)
         ("M-s G" . consult-git-grep)
         ("M-s r" . consult-ripgrep)
         ("M-s l" . consult-line)
         ("M-s L" . consult-line-multi)
         ("M-s m" . consult-multi-occur)
         ("M-s k" . consult-keep-lines)
         ("M-s u" . consult-focus-lines)
         ;; M-g bindings (goto-map)
         ("M-g e" . consult-compile-error)
         ("M-g f" . consult-flymake)
         ("M-g g" . consult-goto-line)
         ("M-g M-g" . consult-goto-line)
         ("M-g o" . consult-outline)
         ("M-g m" . consult-mark)
         ("M-g k" . consult-global-mark)
         ("M-g i" . consult-imenu)
         ("M-g I" . consult-imenu-multi)))

;; Corfu - In-buffer completion popup
(use-package corfu
  :init
  (global-corfu-mode)
  :custom
  (corfu-auto t)                 ; Enable auto completion
  (corfu-auto-prefix 2)          ; Start after 2 characters
  (corfu-auto-delay 0.2))        ; Small delay before popup

;;; ============================================================================
;;; Development Environment (ESSENTIAL)
;;; ============================================================================

;; exec-path-from-shell - Inherit PATH from shell (critical for GUI launch + mise)
(use-package exec-path-from-shell
  :init
  (setq exec-path-from-shell-arguments nil)  ; Faster, use login shell
  :config
  (when (memq window-system '(mac ns x))
    (exec-path-from-shell-initialize)
    ;; Also copy mise-specific env vars if needed
    (exec-path-from-shell-copy-envs '("MISE_DATA_DIR" "MISE_CONFIG_DIR"))))

;; Eglot - Built-in LSP client
(use-package eglot
  :ensure nil  ; Built-in to Emacs 29+
  :hook ((ruby-mode . eglot-ensure)
         (ruby-ts-mode . eglot-ensure)
         (js-mode . eglot-ensure)
         (js-ts-mode . eglot-ensure)
         (typescript-mode . eglot-ensure)
         (typescript-ts-mode . eglot-ensure)
         (tsx-ts-mode . eglot-ensure))
  :config
  ;; Use mise + ruby-lsp for Ruby LSP (globally installed, no Gemfile needed)
  (add-to-list 'eglot-server-programs
               '((ruby-mode ruby-ts-mode) . ("/opt/homebrew/bin/mise" "exec" "--" "ruby-lsp"))))

;; Note: Using Flymake (built-in with Eglot) for diagnostics instead of Flycheck

;; Tree-sitter language sources
(setq treesit-language-source-alist
      '((ruby "https://github.com/tree-sitter/tree-sitter-ruby")
        (javascript "https://github.com/tree-sitter/tree-sitter-javascript" "master" "src")
        (typescript "https://github.com/tree-sitter/tree-sitter-typescript" "master" "typescript/src")
        (tsx "https://github.com/tree-sitter/tree-sitter-typescript" "master" "tsx/src")))

;; Tree-sitter language modes
;; NOTE: Tree-sitter grammars auto-install on first use if not present
(use-package ruby-ts-mode
  :ensure nil  ; Built-in
  :mode "\\.rb\\'")

(use-package js-ts-mode
  :ensure nil  ; Built-in
  :mode "\\.\\(js\\|mjs\\)\\'")

(use-package typescript-ts-mode
  :ensure nil  ; Built-in
  :mode "\\.ts\\'")

(use-package tsx-ts-mode
  :ensure nil  ; Built-in
  :mode "\\.tsx\\'")

;;; ============================================================================
;;; Git Workflow (ESSENTIAL)
;;; ============================================================================

;; Magit - Git interface
(use-package magit
  :bind (("C-x g" . magit-status)
         ("C-x M-g" . magit-dispatch)
         ("C-c g" . magit-file-dispatch))
  :custom
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))

;; Forge - GitHub integration
(use-package forge
  :after magit)

;;; ============================================================================
;;; AI Integration (TRY agent-shell)
;;; ============================================================================

;; agent-shell - Connect to claude-code-acp for Emacs-native Claude experience
;; NOTE: Requires claude-code-acp to be installed
;; TODO: Configure after Saturday development environment is working

;;; ============================================================================
;;; UI/UX
;;; ============================================================================

;; Modus themes - Accessible, elegant themes
(use-package modus-themes
  :custom
  (modus-themes-italic-constructs t)
  (modus-themes-bold-constructs t)
  (modus-themes-mixed-fonts t)
  :config
  (load-theme 'modus-vivendi t))  ; Dark theme

;; Font configuration - Simple direct setting
(set-face-attribute 'default nil :family "Maple Mono NF" :height 140)
(set-face-attribute 'variable-pitch nil :family "SF Pro")

;; Rainbow delimiters - Colorful parentheses
(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

;; Which-key - Show available keybindings
(use-package which-key
  :init
  (which-key-mode)
  :custom
  (which-key-idle-delay 0.5))

;;; ============================================================================
;;; Navigation
;;; ============================================================================

;; Avy - Jump to characters
(use-package avy
  :bind (("M-j" . avy-goto-char-timer)))

;; Ace-window - Window navigation
(use-package ace-window
  :bind (("M-o" . ace-window)))

;;; ============================================================================
;;; Workflow Tools
;;; ============================================================================

;; chezmoi.el - Dotfile management integration
(use-package chezmoi
  :defer t)

;; Denote - Note-taking (aspirational - want to use more)
;; TODO: Configure after basic setup is working

;; Notmuch - Email (aspirational - want to use more)
;; TODO: Configure after basic setup is working

;;; ============================================================================
;;; Server Mode
;;; ============================================================================

;; Enable Emacs server for emacsclient
(use-package server
  :ensure nil  ; Built-in
  :config
  (unless (server-running-p)
    (server-start)))

;;; ============================================================================
;;; Custom Functions
;;; ============================================================================

;; Machine detection functions
(defun rayners/personal-machine-p ()
  "Return non-nil if this is a personal machine.
Personal machines have username 'rayners'."
  (string= (user-login-name) "rayners"))

(defun rayners/work-machine-p ()
  "Return non-nil if this is a work machine.
Work machines are anything not personal."
  (not (rayners/personal-machine-p)))

;;; ============================================================================
;;; Custom Settings Location
;;; ============================================================================

;; Keep customize settings in separate file
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(when (file-exists-p custom-file)
  (load custom-file))

;;; ============================================================================
;;; Project List
;;; ============================================================================

;; Copy existing projects file if it exists
(let ((old-projects (expand-file-name "projects" "~/.emacs.d"))
      (new-projects (expand-file-name "projects" user-emacs-directory)))
  (when (and (file-exists-p old-projects)
             (not (file-exists-p new-projects)))
    (copy-file old-projects new-projects)))

(provide 'post-init)
;;; post-init.el ends here
