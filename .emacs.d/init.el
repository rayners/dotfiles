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
	)
  
  (modus-themes-load-themes)
  :config
  (modus-themes-load-vivendi)

  :bind ("<f5>" . modus-themes-toggle))

(use-package org
  :ensure
  :bind (("C-c a" . org-agenda)
	 ("C-c c" . org-capture))
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
				      ((agenda "" ((org-agenda-span 1)))
				       (tags-todo "work|snapdocs"
						  ((org-agenda-overriding-header "\nWork Stuff\n"))
						  )
				       (tags-todo "-work-snapdocs"
						  ((org-agenda-overriding-header "\nOther Tasks\n"))
						  )
				       )))
	)
  )

(use-package org-roam
  :ensure
  ;; split roam files from org files
  :hook (after-init . org-roam-mode)

  :bind (:map org-roam-mode-map
	      (("C-c n l" . org-roam)
	       ("C-c n f" . org-roam-find-file)))
  :custom
  (org-roam-directory "~/roam")
  (org-roam-tag-sources '(prop vanilla all-directories))
  (org-roam-capture-templates '(("d" "default" plain (function org-roam-capture--get-point)
				 "%?"
				 :file-name "${slug}"
				 :head "#+title: ${title}\n\n"
				 :unnarrowed t)
				("w" "work" plain (function org-roam-capture--get-point)
				 "%?"
				 :file-name "work/${slug}"
				 :head "#+title: ${title}\n\n"
				 :unnarrowed t)
				("p" "personal" plain (function org-roam-capture--get-point)
				 "%?"
				 :file-name "personal/${slug}"
				 :head "#+title: ${title}\n\n"
				 :unnarrowed t)))
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

(use-package selectrum
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

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(exec-path-from-shell notmuch org-gcal which-key selectrum marginalia orderless org-roam project use-package))
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
