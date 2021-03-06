;;; -*- coding: utf-8 mode: lisp -*-
(add-to-list 'load-path "~/elisp")
(add-to-list 'load-path "~/elisp/pod-mode-0.4")
(add-to-list 'load-path "~/elisp/gnuserv")
(add-to-list 'load-path "~/.emacs.d/elpa")

(require 'package)
(add-to-list 'package-archives
             '("melpa" . "http://melpa.org/packages/") t)
(package-initialize)

(set-background-color "dark slate gray")
(set-foreground-color "khaki")
(set-cursor-color "khaki")
(setq inhibit-splash-screen t)
(show-paren-mode 1)
(iswitchb-mode 1)
(scroll-bar-mode -1)
(tool-bar-mode -1)
(setq dabbrev-case-fold-search nil)
(setq split-height-threshold nil)

(add-hook 'after-init-hook #'global-flycheck-mode)

(require 'erlang)
(require 'pod-mode)

(require 'uniquify)
(setq uniquify-buffer-name-style 'forward)
(setq uniquify-after-kill-buffer-p t)

(defadvice iswitchb-kill-buffer (after rescan-after-kill activate)
  "*Regenerate the list of matching buffer names after a kill.
    Necessary if using `uniquify' with `uniquify-after-kill-buffer-p'
    set to non-nil."
  (setq iswitchb-buflist iswitchb-matches)
  (iswitchb-rescan))

(defun iswitchb-rescan ()
  "*Regenerate the list of matching buffer names."
  (interactive)
  (iswitchb-make-buflist iswitchb-default)
  (setq iswitchb-rescan t))

(require 'window-numbering)
(window-numbering-mode 1)

(require 'column-marker)
(add-hook 'c-mode-common-hook (lambda () (column-marker-1 80)))
(add-hook 'python-mode-hook (lambda () (column-marker-1 80)))
(add-hook 'js-mode-hook (lambda () (column-marker-1 80)))

(autoload 'pianobar "pianobar" nil t)
(global-set-key (kbd "C-x p") 'pianobar-play-or-pause)

;; (autoload 'dtrt-indent-mode "dtrt-indent" "Adapt to foreign indentation offsets" t)
;; (add-hook 'c-mode-common-hook 'dtrt-indent-mode)


(global-set-key (kbd "M-p") 'backward-paragraph)
(global-set-key (kbd "M-n") 'forward-paragraph)
(global-set-key (kbd "M-g") 'goto-line)

(global-set-key (kbd "M-h") 'help-command)
(global-unset-key (kbd "C-p"))
(global-set-key (kbd "C-h") 'previous-line)

(define-key minibuffer-local-map (kbd "M-p") nil)
(define-key minibuffer-local-map (kbd "M-h") 'previous-history-element)

(define-key isearch-mode-map (kbd "C-h") 'isearch-other-control-char)
(define-key isearch-mode-map (kbd "M-h M-h") 'isearch-help-for-help)

(add-hook 'term-exec-hook
           (lambda ()
             (define-key term-mode-map (kbd "<prior>") 'scroll-down)
             (define-key term-mode-map (kbd "<next>") 'scroll-up)))

(add-to-list 'exec-path "/usr/local/bin")

(defun entity-at-point ()
  (interactive)
  (let* ((beg (save-excursion (skip-chars-backward "a-z0-9A-Z_./\-" (point-at-bol))
                              (point)))
         (end (save-excursion (skip-chars-forward "a-z0-9A-Z_./\-" (point-at-eol))
                              (point))))
    (buffer-substring beg end)))

(defun switch-to-window-by-name (name)
  (select-window (get-buffer-window name)))

(defun ack-at-point-and-switch ()
  "ack and a half at point"
  (interactive)
  (let ((dir (ack-and-a-half-read-dir)))
    (ack-and-a-half-run dir
                        t
                        (read-from-minibuffer (concat "ack (dir: "
                                                      dir
                                                      "): ")
                                              (entity-at-point)
                                              nil
                                              nil
                                              'ack-and-a-half-regexp-history
                                              )
                        "--nopager"))
  (switch-to-window-by-name "*ack-and-a-half*"))
(global-set-key (kbd "C-c C-a") 'ack-at-point-and-switch)

(eval-after-load "ack-and-a-half-autoloads"
  '(require 'ack-and-a-half))

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
;; Postgres development stuff
;;

(c-add-style "pgsql"
             '("bsd"
               (fill-column . 79)
               (indent-tabs-mode . t)
               (c-basic-offset   . 4)
               (tab-width . 4)
               (c-offsets-alist .
                                ((case-label . +))))
             nil ) ; t = set this mode, nil = don't

(defun pgsql-c-mode ()
  (c-mode)
  (c-set-style "pgsql"))

(setq auto-mode-alist
      (cons '("\\(postgres\\|pgsql\\).*\\.[chyl]\\'" . pgsql-c-mode)
            auto-mode-alist))
(setq auto-mode-alist
      (cons '("\\(postgres\\|pgsql\\).*\\.cc\\'" . pgsql-c-mode)
            auto-mode-alist))
(setq auto-mode-alist
      (cons '("\\(tsearch_extras\\).*\\.[chyl]\\'" . pgsql-c-mode)
            auto-mode-alist))

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

;;
;; C/C++ stuff
;;

;; Rebinds RET to 'newline-and-indent, and C-j to 'newline
(global-set-key "\15" 'newline-and-indent)
(global-set-key "\12" 'newline)

(defun set-no-namespace-indentation ()
  (c-set-offset 'innamespace 0))

(defun set-no-extern-indentation ()
  (c-set-offset 'inextern-lang 0))

(defun indent-or-complete ()
  "Complete if point is at end of a word, otherwise indent line."
  (interactive)
  (indent-for-tab-command)
  (if (looking-at "\\>$")
      (senator-complete-symbol (point))))

(defun bind-tab-to-indent-or-complete ()
  "Binds the tab key to indent-or-complete"
  (interactive)
  (local-set-key "\11" 'indent-or-complete))

(add-hook 'cc-mode-hook 'bind-tab-to-indent-or-complete)
(add-hook 'cc-mode-hook 'set-no-namespace-indentation)
(add-hook 'cc-mode-hook 'set-no-extern-indentation)

(setq c-default-style '((java-mode . "java")
                        (awk-mode . "awk")
                        (other . "stroustrup")))

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
;; Perl stuff
;;

;;; cperl-mode is preferred to perl-mode
;;;"Brevity is the soul of wit" <foo at acm.org>
(defalias 'perl-mode 'cperl-mode)
(setq cperl-invalid-face nil)

(add-hook 'perl-mode-hook 'bind-tab-to-indent-or-complete)
(add-hook 'cperl-mode-hook 'bind-tab-to-indent-or-complete)

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
(setq pir-basic-indent 4)

;;
;; Scheme stuff
;;

(add-hook 'scheme-mode-hook 'bind-tab-to-indent-or-complete)

(defun pretty-lambdas ()
  (font-lock-add-keywords
   nil `(("\\<lambda\\>"
	  (0 (progn (compose-region (match-beginning 0) (match-end 0)
                                    ;,(make-char 'greek-iso8859-7 107))
				    ?λ)
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

;;
;; Vala
;;

(autoload 'vala-mode "vala-mode" "Major mode for editing Vala code." t)
(add-to-list 'auto-mode-alist '("\\.vala$" . vala-mode))
(add-to-list 'auto-mode-alist '("\\.vapi$" . vala-mode))
(add-to-list 'file-coding-system-alist '("\\.vala$" . utf-8))
(add-to-list 'file-coding-system-alist '("\\.vapi$" . utf-8))

;;
;; Puppet
;;

(autoload 'puppet-mode "puppet-mode" "Major mode for editing puppet manifests")

(add-to-list 'auto-mode-alist '("\\.pp$" . puppet-mode))

;;
;; Javascript
;;

(add-to-list 'auto-mode-alist '("\\.js\\'" . js-mode))


;;
;; org-mode
;;
(global-set-key "\C-ca" 'org-agenda)

(defun org-cmp-important-urgent (a b)
  (let* ((ta (get-text-property 1 'tags a))
         (tb (get-text-property 1 'tags b))
         (tai (if (member "important" ta) 2 0))
         (tbi (if (member "important" tb) 2 0))
         (tau (if (member "urgent" ta) 1 0))
         (tbu (if (member "urgent" tb) 1 0))
         (ar (+ tai tau))
         (br (+ tbi tbu)))
    (cond ((< ar br) -1)
          ((< br ar) +1))))

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
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(backup-by-copying t)
 '(backup-directory-alist (quote (("." . "~/.saves"))))
 '(case-fold-search t)
 '(epa-file-name-regexp "\\.\\(gpg\\|asc\\)\\(~\\|\\.~[0-9]+~\\)?\\'")
 '(fill-column 80)
 '(global-font-lock-mode t nil (font-lock))
 '(indent-tabs-mode nil)
 '(indicate-empty-lines t)
 '(org-agenda-cmp-user-defined (quote org-cmp-important-urgent))
 '(org-agenda-files (quote ("~/org/jaguar.org" "~/org/recruiting.org" "~/org/eventbus.org" "~/org/misc_work.org" "~/org/personal.org" "~/org/intern.org")))
 '(org-agenda-sorting-strategy (quote ((agenda habit-down time-up priority-down category-keep) (todo user-defined-down priority-down category-keep) (tags priority-down category-keep) (search category-keep))))
 '(ps-lpr-command "lpr-cups")
 '(ps-printer-name nil)
 '(save-abbrevs nil)
 '(transient-mark-mode t))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(column-marker-1 ((t (:background "dark cyan"))))
 '(js2-function-param ((t (:foreground "medium sea green"))))
 '(mmm-default-submode-face ((t (:background "black")))))

(put 'upcase-region 'disabled nil)

(put 'downcase-region 'disabled nil)
(setq confirm-kill-emacs 'yes-or-no-p)
(setq use-dialog-box nil)

(setq mac-command-modifier 'meta)
(setq mac-option-modifier 'super)
