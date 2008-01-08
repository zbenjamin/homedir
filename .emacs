(add-to-list 'load-path "~/elisp")
(add-to-list 'load-path "~/elisp/ses21-031130")
(add-to-list 'load-path "~/elisp/pod-mode-0.4")
(add-to-list 'load-path "~/elisp/cc-mode-5.31.3")
(add-to-list 'load-path "~/elisp/gnuserv")

(require 'pod-mode)
(require 'dirvars)

(require 'winring)
(winring-initialize)

(set-background-color "dark slate gray")
(set-foreground-color "khaki")
(set-cursor-color "khaki")
(setq inhibit-splash-screen t)
(show-paren-mode 1)
(iswitchb-mode 1)
(scroll-bar-mode -1)
(tool-bar-mode -1)
(setq dabbrev-case-fold-search nil)

(global-set-key (kbd "M-p") 'backward-paragraph)
(global-set-key (kbd "M-n") 'forward-paragraph)

(add-hook 'term-exec-hook
           (lambda ()
             (define-key term-mode-map (kbd "<prior>") 'scroll-down)
             (define-key term-mode-map (kbd "<next>") 'scroll-up)))

;;
;; stuff for ROOT/PROOF development
;;
(c-add-style 
 "root"
 '((c-basic-offset . 3)
   (indent-tabs-mode . nil)))

(defun root-mode ()
  (c++-mode)
  (c-set-style "root"))

(setq 
 auto-mode-alist
 (append '(("^/home/zev/root/.+\\.h" . root-mode))
	 '(("^/home/zev/root/.+\\.cxx" . root-mode))
	 '(("^/home/zev/mit/urop/cms/root/.+\\.h" . root-mode))
	 '(("^/home/zev/mit/urop/cms/root/.+\\.cxx" . root-mode))
	 auto-mode-alist))
;;
;; end ROOT/PROOF stuff
;;

;;
;; 6.004 stuff
;;

(autoload 'jsim-mode "jsim" nil t)
(setq auto-mode-alist (cons '("\.jsim$" . jsim-mode) auto-mode-alist))

;;
;; java stuff
;;
(add-hook 'java-mode-hook
	  (lambda ()
	    (setq c-basic-offset 4)
	    (setq indent-tabs-mode nil)))

;; Rebinds RET to 'newline-and-indent, and C-j to 'newline
(global-set-key "\15" 'newline-and-indent)
(global-set-key "\12" 'newline)

(defun indent-or-complete ()
  "Complete if point is at end of a word, otherwise indent line."
  (interactive)
  (indent-for-tab-command)
  (if (looking-at "\\>$")
      (dabbrev-expand nil)))

(defun bind-tab-to-indent-or-complete ()
  "Binds the tab key to indent-or-complete"
  (interactive)
  (local-set-key "\11" 'indent-or-complete))

(add-hook 'cc-mode-hook 'bind-tab-to-indent-or-complete)

(defun astyle-region ()
  "Run astyle on the current region, preserving initial whitespace"
  (interactive)
  (save-excursion
    (re-search-forward "^\\([ \t]*\\)"))
  (let ((initial-ws (match-string 0))
        (end (region-end)))
    (save-excursion
      (shell-command-on-region (point) (mark) "astyle -j 2> /dev/null" nil t))
    (save-excursion
      (goto-char (region-beginning))
      (while (and (< (point) end)
                  (re-search-forward "^" end t))
        (replace-match initial-ws)
        (if (< (point) end)
            (forward-line 1))))))


;;
;; end 6.170 stuff
;;

;;
;; Perl stuff
;;

;;; cperl-mode is preferred to perl-mode
;;;"Brevity is the soul of wit" <foo at acm.org>
(defalias 'perl-mode 'cperl-mode)
(setq cperl-invalid-face nil)

(add-hook 'perl-mode-hook 'bind-tab-to-indent-or-complete)
(add-hook 'cperl-mode-hook 'bind-tab-to-indent-or-complete)

(global-set-key (kbd "C-x p") 'cperl-perldoc)

(add-to-list 'auto-mode-alist '("\\.t$" . cperl-mode))
(add-to-list 'auto-mode-alist '("\\.pod$" . pod-mode))

(add-hook 'pod-mode-hook
          '(lambda ()
             (progn
              (font-lock-mode)
              (auto-fill-mode 1)
              (flyspell-mode 1))))

(defun perltidy-region ()
  "Run perltidy on the current region."
  (interactive)
  (save-excursion
    (shell-command-on-region (point) (mark) "perltidy -i=2 -q -pt 2 -sbt 2 -bt 2" nil t)))

;;
;; Parrot stuff
;;

(autoload 'pir-mode "pir-mode" nil t)
(add-to-list 'auto-mode-alist '("\\.pir\\'" . pir-mode))


;;
;; Scheme stuff
;;

(add-hook 'scheme-mode-hook 'bind-tab-to-indent-or-complete)

(defun pretty-lambdas ()
  (font-lock-add-keywords
   nil `(("\\<lambda\\>"
	  (0 (progn (compose-region (match-beginning 0) (match-end 0)
				    ,(make-char 'greek-iso8859-7 107))
		    nil))))))

(add-hook 'emacs-lisp-mode-hook 'pretty-lambdas)
(add-hook 'scheme-mode-hook 'pretty-lambdas)

(font-lock-add-keywords
 'scheme-mode
 '(("(\\(class\\|constructor\\|parents\\|variables\\|methods\\)\\>"
    1 font-lock-keyword-face)))

(defun 6001-scheme ()
  (interactive)
  (load "xscheme")
  (run-scheme "~/bin/6001-scheme -emacs"))

(defun 6034-scheme ()
  (interactive)
  (load "xscheme")
  (run-scheme "~/bin/6034-scheme -emacs"))

(defun 6891-scheme ()
  (interactive)
  (load "xscheme")
  (run-scheme "~/bin/6891-scheme -emacs"))

(defun scmutils ()
  (interactive)
  (load "xscheme")
  (run-scheme "~/bin/scmutils -emacs"))

;;
;; Flex/Jflex
;;

(autoload 'jflex-mode "jflex-mode" nil t)
(setq auto-mode-alist (cons '("\\(\\.flex\\|\\.jflex\\)\\'" . jflex-mode) auto-mode-alist))

;;; Stefan Monnier <foo at acm.org>. It is the opposite of fill-paragraph
;;; Takes a multi-line paragraph and makes it into a single line of text.
(defun unfill-paragraph ()
  (interactive)
  (let ((fill-column (point-max)))
    (fill-paragraph nil)))

; I did this one :-)
(defun unfill-region (beg end)
  (interactive "r")
  (let ((fill-column (point-max)))
    (fill-region beg end)))


(custom-set-variables
  ;; custom-set-variables was added by Custom -- don't edit or cut/paste it!
  ;; Your init file should contain only one such instance.
 '(backup-by-copying t)
 '(backup-directory-alist (quote (("." . "~/.saves"))))
 '(case-fold-search t)
 '(current-language-environment "Latin-1")
 '(default-input-method "latin-1-prefix")
 '(fill-column 69)
 '(global-font-lock-mode t nil (font-lock))
 '(indent-tabs-mode nil)
 '(indicate-empty-lines t)
 '(printer-name "jarthur" t)
 '(ps-lpr-command "lpr")
 '(ps-printer-name nil)
 '(transient-mark-mode t))
(custom-set-faces
  ;; custom-set-faces was added by Custom -- don't edit or cut/paste it!
  ;; Your init file should contain only one such instance.
 '(mmm-default-submode-face ((t (:background "black")))))

(put 'upcase-region 'disabled nil)
