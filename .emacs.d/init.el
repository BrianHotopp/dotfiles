;; Package setup
(require 'package)
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

(setq package-check-signature nil)

;; Fuzzy matching in minibuffer (file finder, M-x, etc.)
(fido-vertical-mode 1)

;; Auto-revert buffers when files change on disk (e.g. after git operations)
(global-auto-revert-mode 1)

;; Scala setup
(require 'scala-mode)
(add-hook 'scala-mode-hook 'eglot-ensure)
(require 'sbt-mode)

(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs
               '(scala-mode . ("metals" :initializationOptions
                                (:defaultBspToBuildTool t)))))

;; jarchive: open files inside JARs via M-. (xref-find-definitions).
;; Without this, eglot passes jar:file: URIs through to find-file-noselect,
;; which has no handler and mangles them into bogus local paths.
(require 'jarchive)
(jarchive-mode 1)

;; Flymake error navigation in Scala buffers
(with-eval-after-load 'scala-mode
  (define-key scala-mode-map (kbd "M-n") 'flymake-goto-next-error)
  (define-key scala-mode-map (kbd "M-p") 'flymake-goto-prev-error)
  (define-key scala-mode-map (kbd "C-c a") 'eglot-code-actions))

;; Cross-platform system clipboard integration for terminal Emacs
;; Fallback chain: pbcopy → wl-copy → xclip → xsel (same as tmux config)
;; M-w / C-y = Emacs kill ring (internal, with history)
;; C-c w / C-c y = System clipboard (shares with browser, etc.)
;; C-c W = Copy current buffer filename to system clipboard
(defun my/clipboard-copy-cmd ()
  "Return the best available clipboard copy command."
  (cond
   ((executable-find "pbcopy") "pbcopy")
   ((executable-find "wl-copy") "wl-copy")
   ((executable-find "xclip") "xclip -selection clipboard -in")
   ((executable-find "xsel") "xsel --clipboard --input")))

(defun my/clipboard-paste-cmd ()
  "Return the best available clipboard paste command."
  (cond
   ((executable-find "pbpaste") "pbpaste")
   ((executable-find "wl-paste") "wl-paste")
   ((executable-find "xclip") "xclip -selection clipboard -out")
   ((executable-find "xsel") "xsel --clipboard --output")))

(defun my/copy-to-clipboard ()
  "Copy region to system clipboard."
  (interactive)
  (when (region-active-p)
    (shell-command-on-region (region-beginning) (region-end) (my/clipboard-copy-cmd))
    (message "Copied to system clipboard")
    (deactivate-mark)))

(defun my/paste-from-clipboard ()
  "Paste from system clipboard."
  (interactive)
  (insert (shell-command-to-string (my/clipboard-paste-cmd))))

(defun my/copy-filename-to-clipboard ()
  "Copy the current buffer's filename to the system clipboard."
  (interactive)
  (if-let ((name (buffer-file-name)))
      (progn
        (with-temp-buffer
          (insert name)
          (shell-command-on-region (point-min) (point-max) (my/clipboard-copy-cmd)))
        (message "Copied: %s" name))
    (message "Buffer has no file")))

(global-set-key (kbd "C-c w") 'my/copy-to-clipboard)
(global-set-key (kbd "C-c y") 'my/paste-from-clipboard)
(global-set-key (kbd "C-c W") 'my/copy-filename-to-clipboard)

;; Use ripgrep for project-find-regexp when available, else default grep
(when (executable-find "rg")
  (setq xref-search-program 'ripgrep))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages '(jarchive sbt-mode scala-mode cmake-mode)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
