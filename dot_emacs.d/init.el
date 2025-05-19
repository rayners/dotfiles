(defvar elpaca-installer-version 0.10)
(defvar elpaca-directory (expand-file-name "elpaca/" user-emacs-directory))
(defvar elpaca-builds-directory (expand-file-name "builds/" elpaca-directory))
(defvar elpaca-repos-directory (expand-file-name "repos/" elpaca-directory))
(defvar elpaca-order '(elpaca :repo "https://github.com/progfolio/elpaca.git"
			      :ref nil :depth 1 :inherit ignore
			      :files (:defaults "elpaca-test.el" (:exclude "extensions"))
			      :build (:not elpaca--activate-package)))
(let* ((repo  (expand-file-name "elpaca/" elpaca-repos-directory))
       (build (expand-file-name "elpaca/" elpaca-builds-directory))
       (order (cdr elpaca-order))
       (default-directory repo))
  (add-to-list 'load-path (if (file-exists-p build) build repo))
  (unless (file-exists-p repo)
    (make-directory repo t)
    (when (<= emacs-major-version 28) (require 'subr-x))
    (condition-case-unless-debug err
	(if-let* ((buffer (pop-to-buffer-same-window "*elpaca-bootstrap*"))
		  ((zerop (apply #'call-process `("git" nil ,buffer t "clone"
						  ,@(when-let* ((depth (plist-get order :depth)))
						      (list (format "--depth=%d" depth) "--no-single-branch"))
						  ,(plist-get order :repo) ,repo))))
		  ((zerop (call-process "git" nil buffer t "checkout"
					(or (plist-get order :ref) "--"))))
		  (emacs (concat invocation-directory invocation-name))
		  ((zerop (call-process emacs nil buffer nil "-Q" "-L" "." "--batch"
					"--eval" "(byte-recompile-directory \".\" 0 'force)")))
		  ((require 'elpaca))
		  ((elpaca-generate-autoloads "elpaca" repo)))
	    (progn (message "%s" (buffer-string)) (kill-buffer buffer))
	  (error "%s" (with-current-buffer buffer (buffer-string))))
      ((error) (warn "%s" err) (delete-directory repo 'recursive))))
  (unless (require 'elpaca-autoloads nil t)
    (require 'elpaca)
    (elpaca-generate-autoloads "elpaca" repo)
    (load "./elpaca-autoloads")))
(add-hook 'after-init-hook #'elpaca-process-queues)
(elpaca `(,@elpaca-order))

;; Install use-package support
(elpaca elpaca-use-package
  ;; Enable :elpaca use-package keyword.
  (elpaca-use-package-mode)
  ;; Assume :elpaca t unless otherwise specified.
  (setq use-package-always-ensure t))

;; Block until current queue processed.
(elpaca-wait)

;; ;; Workaround to load development version of seq
;; (defun +elpaca-unload-seq (e) "Unload seq before continuing the elpaca build, then continue to build the recipe E."
;;   (and (featurep 'seq) (unload-feature 'seq t))
;;   (elpaca--continue-build e))
;; (elpaca `(seq :build ,(append (butlast (if (file-exists-p (expand-file-name "seq" elpaca-builds-directory))
;;                                           elpaca--pre-built-steps
;;                                         elpaca-build-steps))
;;                              (list '+elpaca-unload-seq 'elpaca--activate-package))))

;; (use-package eldoc
;;   :preface
;;   ;; avoid loading of built-in eldoc, see https://github.com/progfolio/elpaca/issues/236#issuecomment-1879838229
;;   (unload-feature 'eldoc t)
;;   (setq custom-delayed-init-variables '())
;;   (defvar global-eldoc-mode nil)
;;   :demand t
;;   :config
;;   (global-eldoc-mode))

;; (elpaca-wait)

(use-package emacs
  :ensure nil ;; no actual package involved
  :init
  (setq load-prefer-newer t)
  )

(use-package savehist
  :ensure nil ;; builtin
  :init
  (savehist-mode))

(use-package server
  :ensure nil ;; for builtins, skip elpaca
  :if window-system
  :config
  (unless (server-running-p)
    (server-start)))

;; bell pieces
(setq visible-bell t)
(setq ring-bell-function nil)

(use-package fontaine
  :hook
  ((after-init . fontaine-mode)
   (after-init . (lambda ()
                   ;; Set last preset or fall back to desired style from `fontaine-presets'.
                   (fontaine-set-preset (or (fontaine-restore-latest-preset) 'regular)))))
  :config
  (setq fontaine-presets
        '((regular
           :default-family "Maple Mono NF"
           :default-height 130
           ))))

;; (use-package fontaine
;;   :demand t
;;   :init
;;   (setq fontaine-presets
;;         '((regular ::default-family "iA Writer Mono V Text";;  "Cascadia Code PL";;:default-family "JetBrainsMono Nerd Font Mono"
;;                    :default-weight regular
;;                    :default-height 130
;;                    :fixed-pitch-family nil ; falls back to :default-family
;;                    :fixed-pitch-weight nil ; falls back to :default-weight
;;                    :fixed-pitch-height 1.0
;;                    :fixed-pitch-serif-family nil ; falls back to :default-family
;;                    :fixed-pitch-serif-weight nil ; falls back to :default-weight
;;                    :fixed-pitch-serif-height 1.0
;;                    ;; :variable-pitch-family "ETBembo"
;;                    :variable-pitch-family "iA Writer Duo V Text" ;;"CaskaydiaCove Nerd Font Propo"
;;                    :variable-pitch-weight nil
;;                    :variable-pitch-height 1.2
;;                    :bold-family nil ; use whatever the underlying face has
;;                    :bold-weight bold
;;                    :italic-family nil
;;                    :italic-slant italic
;;                    :line-spacing nil)))
;;   :config
;;   (fontaine-set-preset 'regular)
;;   )

;; (use-package ef-themes
;;   :init
;;   (setq ef-themes-to-toggle '(ef-frost ef-night)
;; 	ef-themes-mixed-fonts t)
;;   (setq ef-themes-headings
;; 	'((1 . (variable-pitch 1.5))
;; 	  (2 . (variable-pitch 1.3))
;; 	  (3 . (1.1))
;; 	  (agenda-date . (1.3))
;; 	  (agenda-structure . (variable-pitch light 1.8))
;; 	  (t . (t))))
;;   (mapc #'disable-theme custom-enabled-themes)
;;   (ef-themes-select 'ef-frost)
;;   )

(use-package modus-themes
  :config
  ;; put config bits here

  (setq modus-themes-italic-constructs t
        modus-themes-bold-constructs t
        modus-themes-mixed-fonts t
        modus-themes-variable-pitch-ui nil

        modus-themes-prompts '(italic bold)

        modus-themes-completions
        '((matches . (extrabold))
          (selection . (semibold italic text-also)))

        modus-themes-org-blocks 'gray-background

        modus-themes-headings
      '((1 . (variable-pitch 1.5))
        (2 . (1.3))
        (agenda-date . (1.3))
        (agenda-structure . (variable-pitch light 1.8))
        (t . (1.1))))
  (load-theme 'modus-vivendi)

  (define-key global-map (kbd "<f5>") #'modus-themes-toggle))

(use-package avy
  :bind ("M-j" . avy-goto-char-timer)
  )

(use-package ace-window
  :bind ("M-o" . ace-window)
  )

;; work or personal machine, I use the config for both
(defun rayners/personal-machine-p ()
  (string= (user-real-login-name) "rayners"))

(defun rayners/work-machine-p ()
  (not (rayners/personal-machine-p)))

(use-package vertico
  :init
  (vertico-mode))

;; (use-package vertico-posf'rame
;;   :after vertico
;;   :init
;;   (vertico-posframe-mode 1))

(use-package marginalia
  :init
  (marginalia-mode))

(use-package orderless
  :custom
  (completion-styles '(orderless basic)))

(use-package corfu
  :init
  (global-corfu-mode))



(setq org-startup-indented t)

(require 'org-tempo)

(setq treesit-language-source-alist
      '(
        (javascript "https://github.com/tree-sitter/tree-sitter-javascript" "v0.20.1" "src")
        (typescript "https://github.com/tree-sitter/tree-sitter-typescript" "v0.20.3" "typescript/src")
        (dockerfile "https://github.com/camdencheek/tree-sitter-dockerfile" "main" "src")
        (tsx "https://github.com/tree-sitter/tree-sitter-typescript" "v0.20.3" "tsx/src")
        (ruby "https://github.com/tree-sitter/tree-sitter-ruby" "v0.20.1" "src")
        ))

;; (use-package project
;;   :custom (project-vc-extra-root-markers '("module.json"))
;;   )

(use-package magit
  :commands magit-project-status
  :bind ("C-x p m" . magit-project-status)
  :hook (git-commit-setup . git-commit-turn-on-flyspell)
  )

(use-package transient)
(use-package forge
  :after (magit transient))

(setq xref-search-program 'ripgrep)

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode)
  )

(setq-default indent-tabs-mode nil)

(use-package haml-mode)

;; (use-package js-ts
;;   :elpaca nil
;;   )

;; (defun rayners/js-setup ()
;;   (setq-local flycheck-command-wrapper-function
;;               (lambda (command)
;;                 (append '("npx") command))))

;; (add-hook 'js-mode-hook #'rayners/js-setup)

(use-package groovy-mode)

(use-package yaml-mode)

(use-package markdown-mode)

(use-package protobuf-mode)

;; (use-package consult
;;   :bind (("C-s" . consult-line)))

;; Swiped from Consult docs for now

;; Example configuration for Consult
(use-package consult
  ;; Replace bindings. Lazily loaded due by `use-package'.
  :bind (;; C-c bindings in `mode-specific-map'
         ("C-c M-x" . consult-mode-command)
         ("C-c h" . consult-history)
         ("C-c k" . consult-kmacro)
         ("C-c m" . consult-man)
         ("C-c i" . consult-info)
         ([remap Info-search] . consult-info)
         ;; C-x bindings in `ctl-x-map'
         ("C-x M-:" . consult-complex-command)     ;; orig. repeat-complex-command
         ("C-x b" . consult-buffer)                ;; orig. switch-to-buffer
         ("C-x 4 b" . consult-buffer-other-window) ;; orig. switch-to-buffer-other-window
         ("C-x 5 b" . consult-buffer-other-frame)  ;; orig. switch-to-buffer-other-frame
         ("C-x t b" . consult-buffer-other-tab)    ;; orig. switch-to-buffer-other-tab
         ("C-x r b" . consult-bookmark)            ;; orig. bookmark-jump
         ("C-x p b" . consult-project-buffer)      ;; orig. project-switch-to-buffer
         ;; Custom M-# bindings for fast register access
         ("M-#" . consult-register-load)
         ("M-'" . consult-register-store)          ;; orig. abbrev-prefix-mark (unrelated)
         ("C-M-#" . consult-register)
         ;; Other custom bindings
         ("M-y" . consult-yank-pop)                ;; orig. yank-pop
         ;; M-g bindings in `goto-map'
         ("M-g e" . consult-compile-error)
         ("M-g f" . consult-flycheck)              ;; Alternative: consult-flycheck
         ("M-g g" . consult-goto-line)             ;; orig. goto-line
         ("M-g M-g" . consult-goto-line)           ;; orig. goto-line
         ("M-g o" . consult-outline)               ;; Alternative: consult-org-heading
         ("M-g m" . consult-mark)
         ("M-g k" . consult-global-mark)
         ("M-g i" . consult-imenu)
         ("M-g I" . consult-imenu-multi)
         ;; M-s bindings in `search-map'
         ("M-s d" . consult-find)                  ;; Alternative: consult-fd
         ("M-s c" . consult-locate)
         ("M-s g" . consult-grep)
         ("M-s G" . consult-git-grep)
         ("M-s r" . consult-ripgrep)
         ("M-s l" . consult-line)
         ("M-s L" . consult-line-multi)
         ("M-s k" . consult-keep-lines)
         ("M-s u" . consult-focus-lines)
         ;; Isearch integration
         ("M-s e" . consult-isearch-history)
         :map isearch-mode-map
         ("M-e" . consult-isearch-history)         ;; orig. isearch-edit-string
         ("M-s e" . consult-isearch-history)       ;; orig. isearch-edit-string
         ("M-s l" . consult-line)                  ;; needed by consult-line to detect isearch
         ("M-s L" . consult-line-multi)            ;; needed by consult-line to detect isearch
         ;; Minibuffer history
         :map minibuffer-local-map
         ("M-s" . consult-history)                 ;; orig. next-matching-history-element
         ("M-r" . consult-history))                ;; orig. previous-matching-history-element

  ;; Enable automatic preview at point in the *Completions* buffer. This is
  ;; relevant when you use the default completion UI.
  :hook (completion-list-mode . consult-preview-at-point-mode)

  ;; The :init configuration is always executed (Not lazy)
  :init

  ;; Optionally configure the register formatting. This improves the register
  ;; preview for `consult-register', `consult-register-load',
  ;; `consult-register-store' and the Emacs built-ins.
  (setq register-preview-delay 0.5
        register-preview-function #'consult-register-format)

  ;; Optionally tweak the register preview window.
  ;; This adds thin lines, sorting and hides the mode line of the window.
  (advice-add #'register-preview :override #'consult-register-window)

  ;; Use Consult to select xref locations with preview
  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref)

  ;; Configure other variables and modes in the :config section,
  ;; after lazily loading the package.
  :config

  ;; Optionally configure preview. The default value
  ;; is 'any, such that any key triggers the preview.
  ;; (setq consult-preview-key 'any)
  ;; (setq consult-preview-key "M-.")
  ;; (setq consult-preview-key '("S-<down>" "S-<up>"))
  ;; For some commands and buffer sources it is useful to configure the
  ;; :preview-key on a per-command basis using the `consult-customize' macro.
  (consult-customize
   consult-theme :preview-key '(:debounce 0.2 any)
   consult-ripgrep consult-git-grep consult-grep
   consult-bookmark consult-recent-file consult-xref
   consult--source-bookmark consult--source-file-register
   consult--source-recent-file consult--source-project-recent-file
   ;; :preview-key "M-."
   :preview-key '(:debounce 0.4 any))

  ;; Optionally configure the narrowing key.
  ;; Both < and C-+ work reasonably well.
  (setq consult-narrow-key "<") ;; "C-+"

  ;; Optionally make narrowing help available in the minibuffer.
  ;; You may want to use `embark-prefix-help-command' or which-key instead.
  ;; (define-key consult-narrow-map (vconcat consult-narrow-key "?") #'consult-narrow-help)

  ;; By default `consult-project-function' uses `project-root' from project.el.
  ;; Optionally configure a different project root function.
  ;;;; 1. project.el (the default)
  ;; (setq consult-project-function #'consult--default-project--function)
  ;;;; 2. vc.el (vc-root-dir)
  ;; (setq consult-project-function (lambda (_) (vc-root-dir)))
  ;;;; 3. locate-dominating-file
  ;; (setq consult-project-function (lambda (_) (locate-dominating-file "." ".git")))
  ;;;; 4. projectile.el (projectile-project-root)
  ;; (autoload 'projectile-project-root "projectile")
  ;; (setq consult-project-function (lambda (_) (projectile-project-root)))
  ;;;; 5. No project support
  ;; (setq consult-project-function nil)
)

(use-package flycheck
  :after (exec-path-from-shell rbenv) ;; need to make sure paths are available first
  :init
  (setq flycheck-check-syntax-automatically '(save idle-change mode-enabled)
        flycheck-idle-change-delay 8)
  (global-flycheck-mode))

(use-package rbenv)

(defun rayners/ruby-setup ()
  (setq-local flycheck-command-wrapper-function
              (lambda (command)
                (append '("bundle" "exec") command))))

(add-hook 'ruby-mode-hook #'rayners/ruby-setup)

;; workaround from https://github.com/progfolio/elpaca/issues/236
;; (elpaca-test
;;   :interactive t
;;   :early-init
;;   (setq elpaca-menu-functions '(elpaca-menu-extensions elpaca-menu-gnu-devel-elpa))
;;   :init

;;   (elpaca elpaca-use-package
;;     (elpaca-use-package-mode)
;;     (setq elpaca-use-package-by-default t))
;;   (elpaca-wait)

;;   (use-package eldoc
;;     :preface
;;     (unload-feature 'eldoc t)
;;     (setq custom-delayed-init-variables '())
;;     (defvar global-eldoc-mode nil)
;;     :config
;;     (global-eldoc-mode)))

;; (use-package eldoc
;;   :preface
;;   (unload-feature 'eldoc t)
;;   (setq custom-delayed-init-variables '())
;;   (defvar global-eldoc-mode nil)
;;   :config
;;   (global-eldoc-mode))

(use-package jsonrpc)
(use-package eglot
  :after (eldoc jsonrpc)
  :hook (prog-mode . eglot-ensure))

(use-package flycheck-eglot
  :after (flycheck eglot)
  :config
  (global-flycheck-eglot-mode 1))

(use-package consult-flycheck)

(use-package exec-path-from-shell
  :demand t
  :config
  (when (memq window-system '(mac ns))
    (exec-path-from-shell-initialize)))

(setq switch-to-buffer-obey-display-actions t)
(add-to-list 'display-buffer-alist
  '("\\*\\(?:[a-z0-9_-]+-\\)?e?shell\\*"
    (display-buffer-reuse-mode-window display-buffer-in-direction)
    (mode eshell-mode)
    (direction . bottom)
    (window . root)
    (window-height . 0.25)))

(use-package nov
  :mode ("\\.epub\\'" . nov-mode))

(use-package notmuch
  :init
  (setq notmuch-archive-tags '("-inbox")
        notmuch-search-oldest-first nil)
  )

(use-package elfeed
  :config
  (setq elfeed-feeds
        '("https://karthinks.com/index.xml")))

(use-package denote
  :custom
  (denote-directory (expand-file-name "~/notes"))
  )

(setq custom-file "~/.emacs.d/custom.el")
(load custom-file)

(use-package chezmoi
  :ensure (:host github :repo "tuh8888/chezmoi.el"))

(use-package gptel
  :custom
  (gptel-model 'anthropic/claude-3.7-sonnet)
  (gptel-backend
   (gptel-make-openai "OpenRouter"
     :host "openrouter.ai"
     :endpoint "/api/v1/chat/completions"
     :stream t
     :key (plist-get (nth 0 (auth-source-search :host "openrouter.ai")) :secret) ;; "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"
     :models '(anthropic/claude-3-5-haiku
               anthropic/claude-3-5-haiku-20241022
               anthropic/claude-3-haiku
               anthropic/claude-3-haiku-20240307
               anthropic/claude-3-opus
               anthropic/claude-3-sonnet
               anthropic/claude-3.5-sonnet
               anthropic/claude-3.5-sonnet:beta
               anthropic/claude-3.7-sonnet))))
