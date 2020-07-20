;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!

;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "Hans Liljestrand"
      user-mail-address "hans@liljestrand.dev")

;; Doom exposes five (optional) variables for controlling fonts in Doom. Here
;; are the three important ones:
;;
;; + `doom-font'
;; + `doom-variable-pitch-font'
;; + `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;;
;; They all accept either a font-spec, font string ("Input Mono-12"), or xlfd
;; font string. You generally only need these two:
;; (setq doom-font (font-spec :family "monospace" :size 12 :weight 'semi-light)
;;       doom-variable-pitch-font (font-spec :family "sans" :size 13))

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-one)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

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

(defun add-property-with-date-captured()
  "Add DATE_CAPTURED property to the current item."
  (interactive)
  (org-set-property "Created" (format-time-string "%F")))

(use-package! org-fancy-priorities
  :hook (org-mode . org-fancy-priorities-mode))

(use-package! imenu-list)

(use-package! xcscope
  :init (setq cscope-display-cscope-buffer nil)
  :config (cscope-setup))

;; Maximize on startup
(add-to-list 'default-frame-alist '(fullscreen . maximized))
;; Disable exit prompts
(setq confirm-kill-emacs nil)

;; Make projectile search all files in a project.
(setq projectile-git-command "git-ls-all-files")

(setq +mu4e-backend 'offlineimap)
(setq mu4e-maildir "~/.Mail")
(set-email-account! "pm"
  '((mu4e-sent-folder       . "/pm/Sent")
    (mu4e-drafts-folder     . "/pm//Drafts")
    (mu4e-trash-folder      . "/pm/Trash")
    (mu4e-refile-folder     . "/pm/All Mail")
    (smtpmail-smtp-user     . "hans.liljestrand@pm.me")
    (user-mail-address      . "hans.liljestrand@pm.me")    ;; only needed for mu < 1.4
    (mu4e-compose-signature . "---\nHans Liljestrand"))
  t)

(setq ;; org-mode Doom-specific configuration
 +org-capture-todo-file "inbox.org"
 +org-capture-journal-file "journal.org"
 +org-capture-notes-file "inbox.org"
 )

(add-to-list 'org-modules 'org-id)
(after! org
  (add-hook 'org-capture-before-finalize-hook 'add-property-with-date-captured)
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
     (sequence "[ ](T)" "|" "[X](D)")
     (sequence "[_](p)" "[x](P)" "|"))
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
       "* TODO %a notes %u\nSCHEDULED: %t\nParticipants: %?" :prepend t :clock-in t :clock-resume t)
     ("c" "Chat notes" entry
       (file +org-capture-todo-file)
       "* TODO Notes on %?\nSCHEDULED: %t\n" :prepend t :clock-in t :clock-resume t)
     ("n" "Personal notes" entry
      (file +org-capture-notes-file)
      "* %u %?\n:PROPERTIES:\nCreated: %U\n:END:\n%i\n%a" :prepend t)
     ("j" "Journal" entry
      (file+olp+datetree +org-capture-journal-file)
      "* %U %?\n%i\n%a" :prepend t)
     ("p" "Templates for projects")
     ("pt" "Project-local todo" entry
      (file+headline +org-capture-project-todo-file "Inbox")
      "* TODO %?\n%i\n%a" :prepend t)
     ("pn" "Project-local notes" entry
      (file+headline +org-capture-project-notes-file "Inbox")
      "* %U %?\n%i\n%a" :prepend t)
     ("pc" "Project-local changelog" entry
      (file+headline +org-capture-project-changelog-file "Unreleased")
      "* %U %?\n%i\n%a" :prepend t)
     ;; ("o" "Centralized templates for projects")
     ;; ("ot" "Project todo" entry #'+org-capture-central-project-todo-file "* TODO %?\n %i\n %a" :heading "Tasks" :prepend nil)
     ;; ("on" "Project notes" entry #'+org-capture-central-project-notes-file "* %U %?\n %i\n %a" :heading "Notes" :prepend t)
     ;; ("oc" "Project changelog" entry #'+org-capture-central-project-changelog-file "* %U %?\n %i\n %a" :heading "Changelog" :prepend t)
     )
   ))

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

(setq-default TeX-master nil)
