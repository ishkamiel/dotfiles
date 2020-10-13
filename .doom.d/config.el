;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Here are some additional functions/macros that could help you configure Doom:
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

(setq user-full-name "Hans Liljestrand"
      user-mail-address "hans@liljestrand.dev")

;; Select Doom theme
(setq doom-theme 'doom-one)

;; Set the font to use
(setq doom-font (font-spec :family "Fira Code Retina" :size 16))

;; Also enable liagture support (based on Fira Code support)
(use-package! ligature
  :config
  (ligature-set-ligatures 't '("www"))
  (ligature-set-ligatures 'prog-mode '("www" "**" "***" "**/" "*>" "*/" "\\\\" "\\\\\\" "{-" "::" ":::" ":=" "!!" "!=" "!==" "-}" "----" "-->" "->" "->>" "-<" "-<<" "-~" "#{" "#[" "##" "###" "####" "#(" "#?" "#_" "#_(" ".-" ".=" ".." "..<" "..." "?=" "??" ";;" "/*" "/**" "/=" "/==" "/>" "//" "///" "&&" "||" "||=" "|=" "|>" "^=" "$>" "++" "+++" "+>" "=:=" "==" "===" "==>" "=>" "=>>" "<=" "=<<" "=/=" ">-" ">=" ">=>" ">>" ">>-" ">>=" ">>>" "<*" "<*>" "<|" "<|>" "<$" "<$>" "<!--" "<-" "<--" "<->" "<+" "<+>" "<=" "<==" "<=>" "<=<" "<>" "<<" "<<-" "<<=" "<<<" "<~" "<~~" "</" "</>" "~@" "~-" "~>" "~~" "~~>" "%%"))
  (global-ligature-mode 't))

;; Display line numbers
(setq display-line-numbers-type t)
;; Maximize on startup
(add-to-list 'default-frame-alist '(fullscreen . maximized))
;; Disable exit prompts
(setq confirm-kill-emacs nil)

;; Make projectile search all files in a project.
(setq projectile-git-command "git-ls-all-files")

;; Auto-save buffers (i.e., do backups)
(setq backup-directory-alist `(("." . ,(concat user-emacs-directory "backups")))
      auto-save-visited-mode t)

;; automatically save on buffer/window switch
(defadvice switch-to-buffer (before save-buffer-now activate) (when buffer-file-name (save-buffer)))
(defadvice other-window (before other-window-now activate) (when buffer-file-name (save-buffer)))
(defadvice windmove-up (before other-window-now activate) (when buffer-file-name (save-buffer)))
(defadvice windmove-down (before other-window-now activate) (when buffer-file-name (save-buffer)))
(defadvice windmove-left (before other-window-now activate) (when buffer-file-name (save-buffer)))
(defadvice windmove-right (before other-window-now activate) (when buffer-file-name (save-buffer)))

;; org-mode Doom-specific configuration
(setq +org-capture-todo-file "inbox.org"
      +org-capture-journal-file "journal.org"
      +org-capture-notes-file "inbox.org")

;; ???
(add-to-list 'org-modules 'org-id)

;; Configure org-mode
(after! org
  (add-hook 'org-capture-before-finalize-hook
            (lambda ()
              (org-set-property "Created" (format-time-string "%F"))))
  (add-hook 'org-agenda-mode-hook
          (lambda ()
            (add-hook 'auto-save-hook 'org-save-all-org-buffers nil t)
            (auto-save-mode)))
  (advice-add 'org-agenda-quit :before 'org-save-all-org-buffers)
  (setq
   org-directory "~/org/"
   org-default-notes-file "~/org/inbox.org"
   org-startup-folded 'overview
   org-log-into-drawer t
   org-agenda-log-mode-items '(closed clock state)
   org-hide-emphasis-markers t
   org-id-link-to-org-use-id t
   org-log-done 'time
   org-duration-format (quote h:mm)
   org-archive-location "::* Archived"
   org-todo-keywords
   '((sequence "TODO(t)" "STRT(s)" "WAIT(w)" "HOLD(h)" "DELEGATED(o)" "|" "DONE(d)" "KILL(k)")
     (sequence "READ(r)" "|" "----")
     (sequence "[ ](T)" "[X](D)"))
   org-todo-keyword-faces
   '(("[-]" . +org-todo-active)
     ("STRT" . +org-todo-active)
     ("[?]" . +org-todo-onhold)
     ("WAIT" . +org-todo-onhold)
     ("HOLD" . +org-todo-onhold)
     ("PROJ" . +org-todo-project)
     ("READ" . (:foreground "darkgray" :weight "bold"))
     )
   org-agenda-custom-commands
   '(("c" . "My Custom Agendas")
     ("cu" "Unscheduled TODO"
      ((todo "TODO|[ ]"
             ((org-agenda-overriding-header "\nUnscheduled TODO")
              (org-agenda-skip-function '(org-agenda-skip-entry-if 'timestamp)))))
      ))
   org-capture-templates
   '(("t" "Personal todo" entry
      (file +org-capture-todo-file)
      "* TODO %?\nSCHEDULED: %t\n%i\n%a" :prepend t :clock-in t :clock-resume t)
     ("m" "Meeting notes" entry
       (file +org-capture-todo-file)
       "* TODO %? notes %u\nSCHEDULED: %t\nParticipants:\n\n" :prepend t :clock-in t :clock-resume t)
     )
   ))

;; Configure evil-org
(after! evil-org
  (remove-hook 'org-tab-first-hook #'+org-cycle-only-current-subtree-h))

(defun ish-add-c-include (path)
  (let ((root (ignore-errors (projectile-project-root))))
    (when root
      (let ((default-directory root))
        (add-to-list (make-variable-buffer-local
                      'flycheck-clang-include-path)
                     (expand-file-name path))
        (add-to-list (make-variable-buffer-local
                      'flycheck-gcc-include-path)
                     (expand-file-name path))
        (add-to-list (make-variable-buffer-local
                      'company-clang-arguments)
                     (concat "-I" (expand-file-name path)))
        ))))

(defun ish-remove-invisiasble-unicode()
  "Query replace some invisible Unicode chars. source:`http://ergoemacs.org/emacs/elisp_unicode_replace_invisible_chars.html' (Version 2018-09-07)"
  (interactive)
  (query-replace-regexp "\ufeff\\|\u200b\\|\u200f\\|\u202e\\|\u200e\\|\ufffc" ""))

;; What was this for?
;; (setq-default TeX-master nil)

;; (setq +mu4e-backend 'offlineimap)
;; (setq mu4e-maildir "~/.Mail")
;; (set-email-account! "pm"
;;   '((mu4e-sent-folder       . "/pm/Sent")
;;     (mu4e-drafts-folder     . "/pm//Drafts")
;;     (mu4e-trash-folder      . "/pm/Trash")
;;     (mu4e-refile-folder     . "/pm/All Mail")
;;     (smtpmail-smtp-user     . "hans.liljestrand@pm.me")
;;     (user-mail-address      . "hans.liljestrand@pm.me")    ;; only needed for mu < 1.4
;;     (mu4e-compose-signature . "---\nHans Liljestrand"))
;;   t)
