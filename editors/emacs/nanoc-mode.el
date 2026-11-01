;;; nanoc-mode.el --- Major mode for NanoC sources -*- lexical-binding: t; -*-
;; Install with: nanoc editor install emacs
;;; Code:
(defconst nanoc-font-lock
  `((,(regexp-opt '("@f" "@fn" "@m" "@macro" "@ct" "@bt" "@asm") 'symbols) . font-lock-keyword-face)
    ("@[A-Za-z_][A-Za-z0-9_]*" . font-lock-function-name-face)
    ("\\$\\$\\|\\$[A-Za-z_][A-Za-z0-9_]*\\(?::[A-Za-z_]+\\|\\.\\.\\.\\)?" . font-lock-variable-name-face)
    (,(regexp-opt '("if" "elif" "else" "for" "while" "break" "continue" "return" "goto") 'symbols)
     . font-lock-keyword-face)
    (,(regexp-opt '("emit" "quote" "ident" "fresh" "rewrite" "again" "source" "eval" "assert" "fail") 'symbols)
     . font-lock-builtin-face)
    (":=" . font-lock-operator-face)))

;;;###autoload
(define-derived-mode nanoc-mode prog-mode "NanoC"
  "Major mode for editing NanoC (.nc) sources."
  (setq-local comment-start "// ")
  (setq-local comment-end "")
  (setq-local comment-start-skip "\\(?://+\\|/\\*+\\)\\s-*")
  (setq-local font-lock-defaults '(nanoc-font-lock)))

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.nc\\'" . nanoc-mode))

(provide 'nanoc-mode)
;;; nanoc-mode.el ends here
