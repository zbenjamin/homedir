(load "~/.emacs.d/load-directory")
(load-directory "~/.emacs.d/config")

;;; Load configuration specific to the local host
(let ((local-config-file "~/.emacs.d/local-config"))
  (if (file-exists-p (concat local-config-file ".el"))
      (load local-config-file)))
