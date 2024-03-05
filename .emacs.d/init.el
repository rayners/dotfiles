(defvar elpaca-installer-version 0.6)
(defvar elpaca-directory (expand-file-name "elpaca/" user-emacs-directory))
(defvar elpaca-builds-directory (expand-file-name "builds/" elpaca-directory))
(defvar elpaca-repos-directory (expand-file-name "repos/" elpaca-directory))
(defvar elpaca-order '(elpaca :repo "https://github.com/progfolio/elpaca.git"
                              :ref nil
                              :files (:defaults "elpaca-test.el" (:exclude "extensions"))
                              :build (:not elpaca--activate-package)))
(let* ((repo  (expand-file-name "elpaca/" elpaca-repos-directory))
       (build (expand-file-name "elpaca/" elpaca-builds-directory))
       (order (cdr elpaca-order))
       (default-directory repo))
  (add-to-list 'load-path (if (file-exists-p build) build repo))
  (unless (file-exists-p repo)
    (make-directory repo t)
    (when (< emacs-major-version 28) (require 'subr-x))
    (condition-case-unless-debug err
        (if-let ((buffer (pop-to-buffer-same-window "*elpaca-bootstrap*"))
                 ((zerop (call-process "git" nil buffer t "clone"
                                       (plist-get order :repo) repo)))
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

;; Workaround to load development version of seq
(defun +elpaca-unload-seq (e) "Unload seq before continuing the elpaca build, then continue to build the recipe E."
  (and (featurep 'seq) (unload-feature 'seq t))
  (elpaca--continue-build e))
(elpaca `(seq :build ,(append (butlast (if (file-exists-p (expand-file-name "seq" elpaca-builds-directory))
                                          elpaca--pre-built-steps
                                        elpaca-build-steps))
                             (list '+elpaca-unload-seq 'elpaca--activate-package))))

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
  :demand t
  :init
  (setq fontaine-presets
        '((regular :default-family "Cascadia Code PL";;:default-family "JetBrainsMono Nerd Font Mono"
                   :default-weight regular
                   :default-height 130
                   :fixed-pitch-family nil ; falls back to :default-family
                   :fixed-pitch-weight nil ; falls back to :default-weight
                   :fixed-pitch-height 1.0
                   :fixed-pitch-serif-family nil ; falls back to :default-family
                   :fixed-pitch-serif-weight nil ; falls back to :default-weight
                   :fixed-pitch-serif-height 1.0
                   ;; :variable-pitch-family "ETBembo"
                   :variable-pitch-family "CaskaydiaCove Nerd Font Propo"
                   :variable-pitch-weight nil
                   :variable-pitch-height 1.2
                   :bold-family nil ; use whatever the underlying face has
                   :bold-weight bold
                   :italic-family nil
                   :italic-slant italic
                   :line-spacing nil)))
  :config
  (fontaine-set-preset 'regular)
  )

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
  :ensure t
  :config
  ;; put config bits here

  (load-theme 'modus-vivendi)

  (define-key global-map (kbd "<f5>") #'modus-themes-toggle))

;; work or personal machine, I use the config for both
(defun rayners/personal-machine-p ()
  (string= (user-real-login-name) "rayners"))

(defun rayners/work-machine-p ()
  (not (rayners/personal-machine-p)))

(use-package vertico
  :init
  (vertico-mode))

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

(setq treesit-language-source-alist
      '(
        (javascript "https://github.com/tree-sitter/tree-sitter-javascript" "master" "src")
        (typescript "https://github.com/tree-sitter/tree-sitter-typescript" "master" "typescript/src")
        ))

(use-package project)

(use-package magit
  :commands magit-project-status
  :bind ("C-x p m" . magit-project-status)
  :hook (git-commit-setup . git-commit-turn-on-flyspell)
  )

(use-package transient)
(use-package emacsql-sqlite)
(use-package forge
  :after (magit transient emacsql-sqlite))

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

(use-package consult
  :bind (("C-s" . consult-line)))

(use-package flycheck
  :after (exec-path-from-shell rbenv) ;; need to make sure paths are available first
  :init
  (setq flycheck-check-syntax-automatically '(save idle-change mode-enabled)
        flycheck-idle-change-delay 4)
  (global-flycheck-mode))

(use-package rbenv
  :ensure t)

(defun rayners/ruby-setup ()
  (setq-local flycheck-command-wrapper-function
              (lambda (command)
                (append '("bundle" "exec") command))))

(add-hook 'ruby-mode-hook #'rayners/ruby-setup)

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

(use-package denote
  :custom
  (denote-directory (expand-file-name "~/notes"))
  )
