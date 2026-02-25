;; Package setup
(require 'package)
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

(setq package-check-signature nil)

;; Fuzzy matching in minibuffer (file finder, M-x, etc.)
(fido-vertical-mode 1)

;; Scala setup
(require 'scala-mode)
(add-hook 'scala-mode-hook 'eglot-ensure)
(require 'sbt-mode)

;; Use metals-launcher for Scala LSP (reads .metals-version from project root)
(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs
               '(scala-mode . ("metals-launcher"))))

;; Cross-platform system clipboard integration for terminal Emacs
;; M-w / C-y = Emacs kill ring (internal, with history)
;; C-c w / C-c y = System clipboard (shares with browser, etc.)
(defun my/copy-to-clipboard ()
  "Copy region to system clipboard (works on macOS and Linux)"
  (interactive)
  (when (region-active-p)
    (let ((clipboard-cmd
           (cond
            ((eq system-type 'darwin) "pbcopy")
            ((eq system-type 'gnu/linux) "xclip -selection clipboard"))))
      (shell-command-on-region (region-beginning) (region-end) clipboard-cmd)
      (message "Copied to system clipboard")
      (deactivate-mark))))

(defun my/paste-from-clipboard ()
  "Paste from system clipboard (works on macOS and Linux)"
  (interactive)
  (let ((clipboard-cmd
         (cond
          ((eq system-type 'darwin) "pbpaste")
          ((eq system-type 'gnu/linux) "xclip -selection clipboard -o"))))
    (insert (shell-command-to-string clipboard-cmd))))

(global-set-key (kbd "C-c w") 'my/copy-to-clipboard)
(global-set-key (kbd "C-c y") 'my/paste-from-clipboard)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages '(sbt-mode scala-mode cmake-mode)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
