(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(add-to-list 'package-archives '("nongnu" . "https://elpa.nongnu.org/nongnu/") t)

(setq frame-title-format '("%b")) ;; just show the buffer name

;; bell stuff
(setq ring-bell-function nil)
(setq visible-bell t)

;; follow symlinks
(setq vc-follow-symlinks t)

;; weird elpa SSL issues?
(setq gnutls-algorithm-priority "NORMAL:-VERS-TLS1.3")

(defun rayners/personal-machine-p ()
  (string= (user-real-login-name) "rayners"))

(defun rayners/work-machine-p ()
  (not (rayners/personal-machine-p)))

(use-package modus-themes
  :ensure
  :init
  (setq modus-themes-slanted-constructs t
	modus-themes-bold-constructs t
	modus-themes-region 'no-extend
	modus-themes-headings '((t . section))
	modus-themes-scale-headings t
	modus-themes-variable-pitch-headings t
	modus-themes-paren-match 'intense
	)
  
  (modus-themes-load-themes)
  :config
  (modus-themes-load-vivendi)

  :bind ("<f5>" . modus-themes-toggle))

(use-package org
  :ensure
  :bind (("C-c a" . org-agenda)
	 ("C-c c" . org-capture))
  :hook ((org-mode . auto-fill-mode)
	 (org-capture-mode . rayners/org-capture-setup)
	 (org-capture-after-finalize . rayners/org-capture-cleanup))
  :init
  (setq org-agenda-files '("~/org/" "~/org/org")
	org-default-notes-file "~/org/inbox.org"
	org-return-follows-link t
	org-startup-indented t
	org-refile-use-outline-path 'file
	org-refile-targets '((nil . (:maxlevel . 2))
			     (org-agenda-files . (:maxlevel . 2)))
	org-agenda-custom-commands '(("n" "Agenda and all TODOs"
				      ((agenda #1="")
				       (alltodo #1#)))
				     (" " "My agenda"
				      ((agenda ""
					       ((org-agenda-span 1)
						(org-agenda-skip-function '(org-agenda-skip-entry-if 'todo 'done 'deadline 'scheduled)))
					       )
				       (agenda nil
					       ((org-agenda-entry-types '(:scheduled :deadline))
						(org-agenda-format-date "")
						(org-deadline-warning-days 7)
						(org-agenda-use-time-grid nil)
						(org-agenda-show-all-dates nil)
						(org-agenda-overriding-header "Dates")
						))
				       (tags-todo "work"
						  ((org-agenda-skip-function '(org-agenda-skip-entry-if 'scheduled))
						   (org-agenda-overriding-header "Work Stuff"))
						  )
				       (tags-todo "-work"
						  ((org-agenda-overriding-header "Other Tasks"))
						  )
				       )))
	)
  :config
  (defun rayners/org-capture-cleanup ()
    (-when-let ((&alist 'name name) (frame-parameters))
      (when (equal name "org-protocol-capture")
	(delete-frame))))
  (defun rayners/org-capture-setup ()
    (-when-let ((&alist 'name name) (frame-parameters))
      (when (equal name "org-protocol-capture")
	(progn
	  (delete-other-windows)
	  (raise-frame)))))
  )

(use-package org-roam
  :ensure
  ;; split roam files from org files
  ; :hook (after-init . org-roam-mode)

  :bind (("C-c n l" . org-roam-buffer-toggle)
	 ("C-c n c" . org-roam-capture)
	 ("C-c n f" . org-roam-node-find)
	 ("C-c n i" . org-roam-node-insert)
	 ("C-c n t" . org-roam-dailies-capture-today)
	 )
  :config
  (org-roam-setup)
  (cl-defmethod org-roam-node-directories ((node org-roam-node))
    (if-let ((dirs (file-name-directory (file-relative-name (org-roam-node-file node) org-roam-directory))))
	(format "(%s)" (string-join (f-split dirs) "/"))
      ""))
  :init
  (add-to-list 'display-buffer-alist
	       '("\\*org-roam\\*"
		 (display-buffer-in-direction)
		 (direction . right)
		 (window-width . 0.33)
		 (window-height . fit-window-to-buffer)))
  (setq org-roam-directory "~/roam"
	org-roam-capture-templates '(("d" "default/local" plain "%?"
				      :if-new (file+head "${slug}.org"
							 "#+title: ${title}\n")
				      :unnarrowed t)
				     ("s" "shared" plain "%?"
				      :if-new (file+head "shared/${slug}.org"
							 "#+title: ${title}\n")
				      :unnarrowed t))
	org-roam-node-display-template "${directories:10} ${title:*} ${tags:10}"
	;; org-roam-dailies-directory "daily/" ;; default... for now
	;; org-roam-dailies-capture-templates '(("d" "default/local" entry "* %<%H:%M>\n\n%?"
	;; 				      :if-new (file+datetree "%<%Y-%b>.org" day))
	;; 				     ("s" "shared" entry "* %<%H:%M>\n\n%?"
	;; 				      :if-new (file+datetree "../shared/daily/%<%Y-%b>.org" day))
	;; 				     )
	;; org-roam-dailies-capture-templates '(("d" "daily" entry "* %?"
	;; 				      :if-new (file+datetree "%<%Y-%b>.org" week)))
	)
  ;; (n-roam-tag-sources '(prop vanilla all-directories))
  ;; (org-roam-capture-templates '(("d" "default/local" plain (function org-roam-capture--get-point)
  ;; 				 "%?"
  ;; 				 :file-name "${slug}"
  ;; 				 :head "#+title: ${title}\n\n"
  ;; 				 :unnarrowed t)
  ;; 				("w" "work" plain (function org-roam-capture--get-point)
  ;; 				 "%?"
  ;; 				 :file-name "work/${slug}"
  ;; 				 :head "#+title: ${title}\n\n"
  ;; 				 :unnarrowed t)
  ;; 				("i" "icloud" plain (function org-roam-capture--get-point)
  ;; 				 "%?"
  ;; 				 :file-name "icloud/${slug}"
  ;; 				 :head "#+title: ${title}\n\n"
  ;; 				 :unnarrowed t)))
  )

(use-package org-gcal
  :if (rayners/work-machine-p)
  :after org
  :config
  (let* ((creds (nth 0 (auth-source-search :host "org-gcal" :require '(:user :secret))))
	 (gcal-id (if creds (plist-get creds :user)))
	 (gcal-secret (if creds (funcall (plist-get creds :secret)))))
    (setq org-gcal-client-id gcal-id
	  org-gcal-client-secret gcal-secret
	  org-gcal-file-alist (list `(,(plist-get (nth 0 (auth-source-search :host "gmail")) :user) . "~/org/gcal.org"))
	  org-gcal-auto-archive nil
	  org-gcal-notify-p nil
	  org-gcal-remove-api-cancelled-events t))
  :hook ((org-agenda-mode . org-gcal-fetch)
	 (org-capture-after-finalize . org-gcal-fetch))
  )

(use-package mini-frame
  :ensure
  :init
  (mini-frame-mode +1))

(use-package selectrum
  :after mini-frame
  :ensure
  :init
  (selectrum-mode +1))

(use-package orderless
  :ensure
  :custom (completion-styles '(orderless))
  )

(use-package marginalia
  :ensure
  :init
  (marginalia-mode))

(use-package autorevert
  :hook (after-init . global-auto-revert-mode)) ; always on for everybody

(use-package exec-path-from-shell
  :ensure
  :config
  (when (memq window-system '(mac ns))
    (exec-path-from-shell-initialize)))

(use-package notmuch
  :ensure
  :bind (("C-c m m" . rayners-notmuch)
	 :map notmuch-search-mode-map
	 ("D" . (lambda ()
		  "Mark message as trash"
		  (interactive)
		  (notmuch-search-tag '("-inbox" "+trash"))
		  (notmuch-search-next-thread))))
  :config
  (defun rayners-notmuch ()
    (interactive)
    (delete-other-windows)
    (notmuch))

  :init
  (setq notmuch-archive-tags '("-inbox")
	notmuch-search-oldest-first nil))

(use-package rainbow-delimiters
  :ensure
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package paren
  :config
  (show-paren-mode 1))

(use-package consult
  :ensure
  :bind (("C-x b" . consult-buffer)
	 ("M-s l" . consult-line)
	 ("M-s e" . consult-isearch)
	 :map isearch-mode-map
	 ("M-e" . consult-isearch)
	 ("M-s e" . consult-isearch)
	 ("M-s l" . consult-line)
	 ))

(use-package embark
  :ensure t
  :bind (("C-." . embark-act)))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(consult embark embark-consult rainbow-delimiters mini-frame exec-path-from-shell notmuch org-gcal which-key selectrum marginalia orderless org-roam project use-package))
 '(safe-local-variable-values
   '((eval progn
	   (setq-local org-roam-directory
		       (locate-dominating-file default-directory ".dir-locals.el"))
	   (setq-local org-roam-db-location
		       (concat org-roam-directory "org-roam.db"))))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
