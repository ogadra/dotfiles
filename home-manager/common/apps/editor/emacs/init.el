;;; init.el --- Personal Emacs configuration -*- lexical-binding: t -*-

(setq inhibit-startup-screen t
      initial-scratch-message nil
      ring-bell-function 'ignore
      use-short-answers t
      create-lockfiles nil
      make-backup-files nil
      auto-save-default nil)
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(global-display-line-numbers-mode 1)
(column-number-mode 1)
(show-paren-mode 1)
(electric-pair-mode 1)
(delete-selection-mode 1)
(global-auto-revert-mode 1)
(setq-default indent-tabs-mode nil
              tab-width 2)

(set-face-attribute 'default nil
                    :family "CodeNewRoman Nerd Font Mono"
                    :height 120)

(use-package doom-themes
  :config (load-theme 'doom-one t))

(use-package doom-modeline
  :hook (after-init . doom-modeline-mode))

(use-package nerd-icons)

(use-package which-key
  :config (which-key-mode 1))

(use-package vertico
  :init (vertico-mode 1))

(use-package marginalia
  :init (marginalia-mode 1))

(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles . (partial-completion))))))

(use-package consult
  :bind (("C-s" . consult-line)
         ("M-y" . consult-yank-pop)
         ("C-x b" . consult-buffer)))

(use-package embark
  :bind ("C-." . embark-act))

(use-package embark-consult
  :hook (embark-collect-mode . consult-preview-at-point-mode))

(use-package corfu
  :init (global-corfu-mode 1)
  :custom (corfu-auto t))

(use-package cape
  :init
  (add-to-list 'completion-at-point-functions #'cape-dabbrev)
  (add-to-list 'completion-at-point-functions #'cape-file))

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package eglot
  :hook ((go-ts-mode typescript-ts-mode js-ts-mode
          terraform-mode hcl-ts-mode) . eglot-ensure))

(setq major-mode-remap-alist
      '((js-mode         . js-ts-mode)
        (javascript-mode . js-ts-mode)
        (typescript-mode . typescript-ts-mode)
        (go-mode         . go-ts-mode)))

(add-to-list 'auto-mode-alist '("\\.tf\\'" . hcl-ts-mode))
(add-to-list 'auto-mode-alist '("\\.tsx\\'" . tsx-ts-mode))

(use-package magit
  :bind ("C-x g" . magit-status))

(use-package dirvish
  :init (dirvish-override-dired-mode)
  :custom
  (dirvish-quick-access-entries
   '(("h" "~/"           "Home")
     ("c" "~/codes/"     "Codes")
     ("d" "~/Downloads/" "Downloads")))
  :config
  (setq dirvish-attributes
        '(nerd-icons file-time file-size collapse subtree-state vc-state git-msg)))

(use-package org
  :custom
  (org-startup-indented t)
  (org-hide-emphasis-markers t)
  (org-todo-keywords '((sequence "TODO" "DOING" "|" "DONE" "CANCELLED")))
  :bind (("C-c a" . org-agenda)
         ("C-c c" . org-capture)))

(use-package org-modern
  :hook (org-mode . org-modern-mode))

(use-package markdown-mode
  :mode ("\\.md\\'" . markdown-mode))

(provide 'init)
;;; init.el ends here
