;;; helm-utils.el --- Utilities Functions for helm. -*- lexical-binding: t -*-

;; Copyright (C) 2012 ~ 2017 Thierry Volpiatto <thierry.volpiatto@gmail.com>

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Code:

(require 'cl-lib)
(require 'helm)
(require 'helm-help)
(require 'compile) ; Fixme: Is this needed?
(require 'dired)

(declare-function helm-find-files-1 "helm-files.el" (fname &optional preselect))
(declare-function popup-tip "ext:popup")
(defvar winner-boring-buffers)


(defgroup helm-utils nil
  "Utilities routines for Helm."
  :group 'helm)

(defcustom helm-su-or-sudo "sudo"
  "What command to use for root access."
  :type 'string
  :group 'helm-utils)

(defcustom helm-default-kbsize 1024.0
  "Default Kbsize to use for showing files size.
It is a float, usually 1024.0 but could be 1000.0 on some systems."
  :group 'helm-utils
  :type 'float)

(define-obsolete-variable-alias
  'helm-highlight-number-lines-around-point
  'helm-highlight-matches-around-point-max-lines
  "20160119")

(defcustom helm-highlight-matches-around-point-max-lines 15
  "Number of lines around point where matched items are highlighted."
  :group 'helm-utils
  :type 'integer)

(defcustom helm-buffers-to-resize-on-pa nil
  "A list of helm buffers where the helm-window should be reduced on persistent actions."
  :group 'helm-utils
  :type '(repeat (choice string)))

(defcustom helm-resize-on-pa-text-height 12
  "The size of the helm-window when resizing on persistent action."
  :group 'helm-utils
  :type 'integer)

(defcustom helm-sources-using-help-echo-popup '("Moccur" "Imenu in all buffers"
                                                "Ack-Grep" "AG" "Gid" "Git-Grep")
  "Show the buffer name or the filename in a popup at selection."
  :group 'helm-utils
  :type '(repeat (choice string)))

(defcustom helm-html-decode-entities-function #'helm-html-decode-entities-string
  "Function used to decode html entities in html bookmarks.
Helm comes by default with `helm-html-decode-entities-string', if you need something
more sophisticated you can use `w3m-decode-entities-string' if available.

In emacs itself org-entities seems broken and `xml-substitute-numeric-entities'
supports only numeric entities."
  :group 'helm-utils
  :type 'function)


(defvar helm-goto-line-before-hook '(helm-save-current-pos-to-mark-ring)
  "Run before jumping to line.
This hook run when jumping from `helm-goto-line', `helm-etags-default-action',
and `helm-imenu-default-action'.
This allow you to retrieve a previous position after using the different helm
tools for searching (etags, grep, gid, (m)occur etc...).
By default positions are added to `mark-ring' you can also add to register
by using instead (or adding) `helm-save-pos-to-register-before-jump'.
In this case last position is added to the register
`helm-save-pos-before-jump-register'.")

(defvar helm-save-pos-before-jump-register ?_
  "The register where `helm-save-pos-to-register-before-jump' save position.")

(defconst helm-html-entities-alist
  '(("&quot;"   . 34)   ;; "
    ("&gt;"     . 62)   ;; >
    ("&lt;"     . 60)   ;; <
    ("&amp;"    . 38)   ;; &
    ("&euro;"   . 8364) ;; ???
    ("&Yuml;"   . 89)   ;; Y
    ("&iexcl;"  . 161)  ;; ??
    ("&cent;"   . 162)  ;; ??
    ("&pound;"  . 163)  ;; ??
    ("&curren;" . 164)  ;; ??
    ("&yen"     . 165)  ;; ??
    ("&brvbar;" . 166)  ;; ??
    ("&sect;"   . 167)  ;; ??
    ("&uml;"    . 32)   ;; SPC 
    ("&copy;"   . 169)  ;; ??
    ("&ordf;"   . 97)   ;; a
    ("&laquo;"  . 171)  ;; ??
    ("&not;"    . 172)  ;; ??
    ("&masr;"   . 174)  ;; ??
    ("&deg;"    . 176)  ;; ??
    ("&plusmn;" . 177)  ;; ??
    ("&sup2;"   . 50)   ;; 2
    ("&sup3;"   . 51)   ;; 3
    ("&acute;"  . 39)   ;; '
    ("&micro;"  . 956)  ;; ??
    ("&para;"   . 182)  ;; ??
    ("&middot;" . 183)  ;; ??
    ("&cedil;"  . 32)   ;; SPC 
    ("&sup1;"   . 49)   ;; 1
    ("&ordm;"   . 111)  ;; o
    ("&raquo;"  . 187)  ;; ??
    ("&frac14;" . 49)   ;; 1
    ("&frac12;" . 49)   ;; 1
    ("&frac34;" . 51)   ;; 3
    ("&iquest;" . 191)  ;; ??
    ("&Agrave;" . 192)  ;; ??
    ("&Aacute;" . 193)  ;; ??
    ("&Acirc;"  . 194)  ;; ??
    ("&Atilde;" . 195)  ;; ??
    ("&Auml;"   . 196)  ;; ??
    ("&Aring;"  . 197)  ;; ??
    ("&Aelig"   . 198)  ;; ??
    ("&Ccedil;" . 199)  ;; ??
    ("&Egrave;" . 200)  ;; ??
    ("&Eacute;" . 201)  ;; ??
    ("&Ecirc;"  . 202)  ;; ??
    ("&Euml;"   . 203)  ;; ??
    ("&Igrave;" . 204)  ;; ??
    ("&Iacute;" . 205)  ;; ??
    ("&Icirc;"  . 206)  ;; ??
    ("&Iuml;"   . 207)  ;; ??
    ("&eth;"    . 208)  ;; ??
    ("&Ntilde;" . 209)  ;; ??
    ("&Ograve;" . 210)  ;; ??
    ("&Oacute;" . 211)  ;; ??
    ("&Ocirc;"  . 212)  ;; ??
    ("&Otilde;" . 213)  ;; ??
    ("&Ouml;"   . 214)  ;; ??
    ("&times;"  . 215)  ;; ??
    ("&Oslash;" . 216)  ;; ??
    ("&Ugrave;" . 217)  ;; ??
    ("&Uacute;" . 218)  ;; ??
    ("&Ucirc;"  . 219)  ;; ??
    ("&Uuml;"   . 220)  ;; ??
    ("&Yacute;" . 221)  ;; ??
    ("&thorn;"  . 222)  ;; ??
    ("&szlig;"  . 223)  ;; ??
    ("&agrave;" . 224)  ;; ??
    ("&aacute;" . 225)  ;; ??
    ("&acirc;"  . 226)  ;; ??
    ("&atilde;" . 227)  ;; ??
    ("&auml;"   . 228)  ;; ??
    ("&aring;"  . 229)  ;; ??
    ("&aelig;"  . 230)  ;; ??
    ("&ccedil;" . 231)  ;; ??
    ("&egrave;" . 232)  ;; ??
    ("&eacute;" . 233)  ;; ??
    ("&ecirc;"  . 234)  ;; ??
    ("&euml;"   . 235)  ;; ??
    ("&igrave;" . 236)  ;; ??
    ("&iacute;" . 237)  ;; ??
    ("&icirc;"  . 238)  ;; ??
    ("&iuml;"   . 239)  ;; ??
    ("&eth;"    . 240)  ;; ??
    ("&ntilde;" . 241)  ;; ??
    ("&ograve;" . 242)  ;; ??
    ("&oacute;" . 243)  ;; ??
    ("&ocirc;"  . 244)  ;; ??
    ("&otilde;" . 245)  ;; ??
    ("&ouml;"   . 246)  ;; ??
    ("&divide;" . 247)  ;; ??
    ("&oslash;" . 248)  ;; ??
    ("&ugrave;" . 249)  ;; ??
    ("&uacute;" . 250)  ;; ??
    ("&ucirc;"  . 251)  ;; ??
    ("&uuml;"   . 252)  ;; ??
    ("&yacute;" . 253)  ;; ??
    ("&thorn;"  . 254)  ;; ??
    ("&yuml;"   . 255)  ;; ??
    ("&reg;"    . 174)  ;; ??
    ("&shy;"    . 173)) ;; ??

  "Table of html character entities and values.")

(defvar helm-find-many-files-after-hook nil
  "Hook that run at end of `helm-find-many-files'.")

;;; Faces.
;;
(defface helm-selection-line
    '((t (:inherit highlight :distant-foreground "black")))
  "Face used in the `helm-current-buffer' when jumping to candidate."
  :group 'helm-faces)

(defface helm-match-item
    '((t (:inherit isearch)))
  "Face used to highlight item matched in a selected line."
  :group 'helm-faces)


;;; Utils functions
;;
;;
(defun helm-switch-to-buffers (buffer-or-name &optional other-window)
  "Switch to buffer BUFFER-OR-NAME.
If more than one buffer marked switch to these buffers in separate windows.
If OTHER-WINDOW is specified keep current-buffer and switch to others buffers
in separate windows."
  (let* ((mkds (helm-marked-candidates))
         (size (/ (window-height) (length mkds))))
    (or (<= window-min-height size)
        (error "Too many buffers to visit simultaneously."))
    (helm-aif (cdr mkds)
        (progn
          (if other-window
              (switch-to-buffer-other-window (car mkds))
            (switch-to-buffer (car mkds)))
          (save-selected-window
            (cl-loop for b in it
                  do (progn
                       (select-window (split-window))
                       (switch-to-buffer b)))))
      (if other-window
          (switch-to-buffer-other-window buffer-or-name)
        (switch-to-buffer buffer-or-name)))))

(defun helm-switch-to-buffers-other-window (buffer-or-name)
  "switch to buffer BUFFER-OR-NAME in other window.
See `helm-switch-to-buffers' for switching to marked buffers."
  (helm-switch-to-buffers buffer-or-name t))

(cl-defun helm-current-buffer-narrowed-p (&optional
                                            (buffer helm-current-buffer))
  "Check if BUFFER is narrowed.
Default is `helm-current-buffer'."
  (with-current-buffer buffer
    (let ((beg (point-min))
          (end (point-max))
          (total (buffer-size)))
      (or (/= beg 1) (/= end (1+ total))))))

(defun helm-goto-char (loc)
  "Go to char, revealing if necessary."
  (goto-char loc)
  (when (or (eq major-mode 'org-mode)
            (and (boundp 'outline-minor-mode)
                 outline-minor-mode))
    (require 'org) ; On some old Emacs versions org may not be loaded.
    (org-reveal)))

(defun helm-goto-line (lineno &optional noanim)
  "Goto LINENO opening only outline headline if needed.
Animation is used unless NOANIM is non--nil."
  (helm-log-run-hook 'helm-goto-line-before-hook)
  (helm-match-line-cleanup)
  (with-helm-current-buffer
    (unless helm-yank-point (setq helm-yank-point (point))))
  (goto-char (point-min))
  (helm-goto-char (point-at-bol lineno))
  (unless noanim
    (helm-highlight-current-line)))

(defun helm-save-pos-to-register-before-jump ()
  "Save current buffer position to `helm-save-pos-before-jump-register'.
To use this add it to `helm-goto-line-before-hook'."
  (with-helm-current-buffer
    (unless helm-in-persistent-action
      (point-to-register helm-save-pos-before-jump-register))))

(defun helm-save-current-pos-to-mark-ring ()
  "Save current buffer position to mark ring.
To use this add it to `helm-goto-line-before-hook'."
  (with-helm-current-buffer
    (unless helm-in-persistent-action
      (set-marker (mark-marker) (point))
      (push-mark (point) 'nomsg))))

(defun helm-show-all-in-this-source-only (arg)
  "Show only current source of this helm session with all its candidates.
With a numeric prefix arg show only the ARG number of candidates."
  (interactive "p")
  (with-helm-alive-p
    (with-helm-window
      (with-helm-default-directory (helm-default-directory)
          (let ((helm-candidate-number-limit (and (> arg 1) arg)))
            (helm-set-source-filter
             (list (assoc-default 'name (helm-get-current-source)))))))))
(put 'helm-show-all-in-this-source-only 'helm-only t)

(defun helm-display-all-sources ()
  "Display all sources previously hidden by `helm-set-source-filter'."
  (interactive)
  (with-helm-alive-p
    (helm-set-source-filter nil)))
(put 'helm-display-all-sources 'helm-only t)

(defun helm-displaying-source-names ()
  "Return the list of sources name for this helm session."
  (with-current-buffer helm-buffer
    (goto-char (point-min))
    (cl-loop with pos
          while (setq pos (next-single-property-change (point) 'helm-header))
          do (goto-char pos)
          collect (buffer-substring-no-properties (point-at-bol)(point-at-eol))
          do (forward-line 1))))

(defun helm-handle-winner-boring-buffers ()
  "Add `helm-buffer' to `winner-boring-buffers' when quitting/exiting helm.
Add this function to `helm-cleanup-hook' when you don't want to see helm buffers
after running winner-undo/redo."
  (require 'winner)
  (cl-pushnew helm-buffer winner-boring-buffers :test 'equal))
(add-hook 'helm-cleanup-hook #'helm-handle-winner-boring-buffers)

(defun helm-quit-and-find-file ()
  "Drop into `helm-find-files' from `helm'.
If current selection is a buffer or a file, `helm-find-files'
from its directory."
  (interactive)
  (with-helm-alive-p
    (require 'helm-grep)
    (helm-run-after-exit
     (lambda (f)
       ;; Ensure specifics `helm-execute-action-at-once-if-one'
       ;; fns don't run here.
       (let (helm-execute-action-at-once-if-one)
         (if (file-exists-p f)
             (helm-find-files-1 (file-name-directory f)
                                (concat
                                 "^"
                                 (regexp-quote
                                  (if helm-ff-transformer-show-only-basename
                                      (helm-basename f) f))))
             (helm-find-files-1 f))))
     (let* ((sel       (helm-get-selection))
            (marker    (if (consp sel) (markerp (cdr sel))))
            (grep-line (and (stringp sel)
                            (helm-grep-split-line sel)))
            (bmk-name  (and (stringp sel)
                            (not grep-line)
                            (replace-regexp-in-string "\\`\\*" "" sel)))
            (bmk       (and bmk-name (assoc bmk-name bookmark-alist)))
            (buf       (helm-aif (and (bufferp sel) (get-buffer sel))
                           (buffer-name it)))
            (default-preselection (or (buffer-file-name helm-current-buffer)
                                      default-directory)))
       (cond
         ;; Buffer.
         (buf (or (buffer-file-name sel)
                  (car (rassoc buf dired-buffers))
                  (and (with-current-buffer buf
                         (eq major-mode 'org-agenda-mode))
                       org-directory
                       (expand-file-name org-directory))
                  (with-current-buffer buf
                    (expand-file-name default-directory))))
         ;; imenu (marker).
         (marker
          (or (buffer-file-name (marker-buffer (cdr sel)))
              default-preselection))
         ;; Bookmark.
         (bmk (helm-aif (bookmark-get-filename bmk)
                  (if (and ffap-url-regexp
                           (string-match ffap-url-regexp it))
                      it (expand-file-name it))
                (expand-file-name default-directory)))
         ((and (stringp sel) (or (file-remote-p sel)
                                 (file-exists-p sel)))
          (expand-file-name sel))
         ;; Grep.
         ((and grep-line (file-exists-p (car grep-line)))
          (expand-file-name (car grep-line)))
         ;; Occur.
         (grep-line
          (with-current-buffer (get-buffer (car grep-line))
            (expand-file-name (or (buffer-file-name) default-directory))))
         ;; Url.
         ((and (stringp sel) ffap-url-regexp (string-match ffap-url-regexp sel)) sel)
         ;; Default.
         (t (expand-file-name default-preselection)))))))
(put 'helm-quit-and-find-file 'helm-only t)

(defun helm-generic-sort-fn (s1 s2)
  "Sort predicate function for helm candidates.
Args S1 and S2 can be single or \(display . real\) candidates,
that is sorting is done against real value of candidate."
  (let* ((qpattern (regexp-quote helm-pattern))
         (reg1  (concat "\\_<" qpattern "\\_>"))
         (reg2  (concat "\\_<" qpattern))
         (reg3  helm-pattern)
         (split (helm-mm-split-pattern helm-pattern))
         (str1  (if (consp s1) (cdr s1) s1))
         (str2  (if (consp s2) (cdr s2) s2))
         (score (lambda (str r1 r2 r3 lst)
                    (+ (if (string-match (concat "\\`" qpattern) str) 1 0)
                       (cond ((string-match r1 str) 5)
                             ((and (string-match " " qpattern)
                                   (string-match
                                    (concat "\\_<" (regexp-quote (car lst))) str)
                                   (cl-loop for r in (cdr lst)
                                            always (string-match r str))) 4)
                             ((and (string-match " " qpattern)
                                   (cl-loop for r in lst
                                            always (string-match r str))) 3)
                             ((string-match r2 str) 2)
                             ((string-match r3 str) 1)
                             (t 0)))))
         (sc1 (funcall score str1 reg1 reg2 reg3 split))
         (sc2 (funcall score str2 reg1 reg2 reg3 split)))
    (cond ((or (zerop (string-width qpattern))
               (and (zerop sc1) (zerop sc2)))
           (string-lessp str1 str2))
          ((= sc1 sc2)
           (< (length str1) (length str2)))
          (t (> sc1 sc2)))))

(defun helm-ff-get-host-from-tramp-invalid-fname (fname)
  "Extract hostname from an incomplete tramp file name.
Return nil on valid file name remote or not."
  (let* ((str (helm-basename fname))
         (split (split-string str ":" t))
         (meth (car (member (car split)
                            (helm-ff-get-tramp-methods))))) 
    (when meth (car (last split)))))

(cl-defun helm-file-human-size (size &optional (kbsize helm-default-kbsize))
  "Return a string showing SIZE of a file in human readable form.
SIZE can be an integer or a float depending it's value.
`file-attributes' will take care of that to avoid overflow error.
KBSIZE is a floating point number, defaulting to `helm-default-kbsize'."
  (cl-loop with result = (cons "B" size)
           for i in '("k" "M" "G" "T" "P" "E" "Z" "Y")
           while (>= (cdr result) kbsize)
           do (setq result (cons i (/ (cdr result) kbsize)))
           finally return
           (pcase (car result)
             (`"B" (format "%s" size))
             (suffix (format "%.1f%s" (cdr result) suffix)))))

(cl-defun helm-file-attributes
    (file &key type links uid gid access-time modif-time
            status size mode gid-change inode device-num dired human-size
            mode-type mode-owner mode-group mode-other (string t))
  "Return `file-attributes' elements of FILE separately according to key value.
Availables keys are:
- TYPE: Same as nth 0 `files-attributes' if STRING is nil
        otherwise return either symlink, directory or file (default).
- LINKS: See nth 1 `files-attributes'.
- UID: See nth 2 `files-attributes'.
- GID: See nth 3 `files-attributes'.
- ACCESS-TIME: See nth 4 `files-attributes', however format time
               when STRING is non--nil (the default).
- MODIF-TIME: See nth 5 `files-attributes', same as above.
- STATUS: See nth 6 `files-attributes', same as above.
- SIZE: See nth 7 `files-attributes'.
- MODE: See nth 8 `files-attributes'.
- GID-CHANGE: See nth 9 `files-attributes'.
- INODE: See nth 10 `files-attributes'.
- DEVICE-NUM: See nth 11 `files-attributes'.
- DIRED: A line similar to what 'ls -l' return.
- HUMAN-SIZE: The size in human form, see `helm-file-human-size'.
- MODE-TYPE, mode-owner,mode-group, mode-other: Split what
  nth 7 `files-attributes' return in four categories.
- STRING: When non--nil (default) `helm-file-attributes' return
          more friendly values.
If you want the same behavior as `files-attributes' ,
\(but with return values in proplist\) use a nil value for STRING.
However when STRING is non--nil, time and type value are different from what
you have in `file-attributes'."
  (let* ((all (cl-destructuring-bind
                    (type links uid gid access-time modif-time
                          status size mode gid-change inode device-num)
                  (file-attributes file string)
                (list :type        (if string
                                       (cond ((stringp type) "symlink") ; fname
                                             (type "directory")         ; t
                                             (t "file"))                ; nil
                                     type)
                      :links       links
                      :uid         uid
                      :gid         gid
                      :access-time (if string
                                       (format-time-string
                                        "%Y-%m-%d %R" access-time)
                                     access-time)
                      :modif-time  (if string
                                       (format-time-string
                                        "%Y-%m-%d %R" modif-time)
                                     modif-time)
                      :status      (if string
                                       (format-time-string
                                        "%Y-%m-%d %R" status)
                                     status)
                      :size        size
                      :mode        mode
                      :gid-change  gid-change
                      :inode       inode
                      :device-num  device-num)))
         (modes (helm-split-mode-file-attributes (cl-getf all :mode))))
    (cond (type        (cl-getf all :type))
          (links       (cl-getf all :links))
          (uid         (cl-getf all :uid))
          (gid         (cl-getf all :gid))
          (access-time (cl-getf all :access-time))
          (modif-time  (cl-getf all :modif-time))
          (status      (cl-getf all :status))
          (size        (cl-getf all :size))
          (mode        (cl-getf all :mode))
          (gid-change  (cl-getf all :gid-change))
          (inode       (cl-getf all :inode))
          (device-num  (cl-getf all :device-num))
          (dired       (concat
                        (helm-split-mode-file-attributes
                         (cl-getf all :mode) t) " "
                        (number-to-string (cl-getf all :links)) " "
                        (cl-getf all :uid) ":"
                        (cl-getf all :gid) " "
                        (if human-size
                            (helm-file-human-size (cl-getf all :size))
                            (int-to-string (cl-getf all :size))) " "
                        (cl-getf all :modif-time)))
          (human-size (helm-file-human-size (cl-getf all :size)))
          (mode-type  (cl-getf modes :mode-type))
          (mode-owner (cl-getf modes :user))
          (mode-group (cl-getf modes :group))
          (mode-other (cl-getf modes :other))
          (t          (append all modes)))))

(defun helm-split-mode-file-attributes (str &optional string)
  "Split mode file attributes STR into a proplist.
If STRING is non--nil return instead a space separated string."
  (cl-loop with type = (substring str 0 1)
        with cdr = (substring str 1)
        for i across cdr
        for count from 1
        if (<= count 3)
        concat (string i) into user
        if (and (> count 3) (<= count 6))
        concat (string i) into group
        if (and (> count 6) (<= count 9))
        concat (string i) into other
        finally return
        (if string
            (mapconcat 'identity (list type user group other) " ")
          (list :mode-type type :user user :group group :other other))))

(defmacro with-helm-display-marked-candidates (buffer-or-name candidates &rest body)
  (declare (indent 0) (debug t))
  (helm-with-gensyms (buffer window)
    `(let* ((,buffer (temp-buffer-window-setup ,buffer-or-name))
            (helm-always-two-windows t)
            (helm-split-window-default-side
             (if (eq helm-split-window-default-side 'same)
                 'below helm-split-window-default-side))
            helm-split-window-in-side-p
            helm-reuse-last-window-split-state
            ,window)
       (with-current-buffer ,buffer
         (dired-format-columns-of-files ,candidates))
       (unwind-protect
            (with-selected-window
                (setq ,window (temp-buffer-window-show
                               ,buffer
                               '(display-buffer-below-selected
                                 (window-height . fit-window-to-buffer))))
              (progn ,@body))
         (quit-window 'kill ,window)))))

;;; Persistent Action Helpers
;;
;;
;; Internal
(defvar helm-match-line-overlay nil)
(defvar helm--match-item-overlays nil)

(defun helm-highlight-current-line (&optional start end buf face)
  "Highlight and underline current position"
  (let* ((start (or start (line-beginning-position)))
         (end (or end (1+ (line-end-position))))
         start-match end-match
         (args (list start end buf)))
    ;; Highlight the current line.
    (if (not helm-match-line-overlay)
        (setq helm-match-line-overlay (apply 'make-overlay args))
      (apply 'move-overlay helm-match-line-overlay args))
    (overlay-put helm-match-line-overlay
                 'face (or face 'helm-selection-line))
    ;; Now highlight matches only if we are in helm session, we are
    ;; maybe coming from helm-grep-mode or helm-moccur-mode buffers.
    (when helm-alive-p
      (if (or (null helm-highlight-matches-around-point-max-lines)
              (zerop helm-highlight-matches-around-point-max-lines))
          (setq start-match start
                end-match   end)
          (setq start-match
                (save-excursion
                  (forward-line
                   (- helm-highlight-matches-around-point-max-lines))
                  (point-at-bol))
                  end-match
                  (save-excursion
                    (forward-line
                     helm-highlight-matches-around-point-max-lines)
                    (point-at-bol))))
      (catch 'empty-line
        (cl-loop with ov
                 for r in (helm-remove-if-match
                           "\\`!" (helm-mm-split-pattern
                                   (if (with-helm-buffer
                                         ;; Needed for highlighting AG matches.
                                         (assq 'pcre (helm-get-current-source)))
                                       (helm--translate-pcre-to-elisp helm-input)
                                       helm-input)))
                 do (save-excursion
                      (goto-char start-match)
                      (while (condition-case _err
                                 (if helm-migemo-mode
                                     (helm-mm-migemo-forward r end-match t)
                                     (re-search-forward r end-match t))
                               (invalid-regexp nil))
                        (let ((s (match-beginning 0))
                              (e (match-end 0)))
                          (if (= s e)
                              (throw 'empty-line nil)
                              (push (setq ov (make-overlay s e))
                                    helm--match-item-overlays)
                              (overlay-put ov 'face 'helm-match-item)
                              (overlay-put ov 'priority 1))))))))
    (recenter)))

(defun helm--translate-pcre-to-elisp (regexp)
  "Should translate pcre REGEXP to elisp regexp.
Assume regexp is a pcre based regexp."
  (with-temp-buffer
    (insert " " regexp " ")
    (goto-char (point-min))
    (save-excursion
      ;; match (){}| unquoted
      (helm-awhile (and (re-search-forward "\\([(){}|]\\)" nil t)
                        (match-string 1))
        (let ((pos (match-beginning 1)))
          (if (eql (char-before pos) ?\\)
              (delete-region pos (1- pos))
              (replace-match (concat "\\" it) t t nil 1)))))
    ;; match \s or \S
    (helm-awhile (and (re-search-forward "\\S\\?\\(\\s\\[sS]\\)[^-]" nil t)
                      (match-string 1))
      (replace-match (concat it "-") t t nil 1))
    (buffer-substring (1+ (point-min)) (1- (point-max)))))

(defun helm-match-line-cleanup ()
  (when helm-match-line-overlay
    (delete-overlay helm-match-line-overlay)
    (setq helm-match-line-overlay nil))
  (when helm--match-item-overlays
    (mapc 'delete-overlay helm--match-item-overlays)))

(defun helm-match-line-cleanup-maybe ()
  (when (helm-empty-buffer-p)
    (helm-match-line-cleanup)))

(defun helm-match-line-update ()
  (when helm-match-line-overlay
    (delete-overlay helm-match-line-overlay)
    (helm-highlight-current-line)))

(defun helm-persistent-autoresize-hook ()
  (when (and helm-buffers-to-resize-on-pa
             (member helm-buffer helm-buffers-to-resize-on-pa)
             (eq helm-split-window-state 'vertical))
    (set-window-text-height (helm-window) helm-resize-on-pa-text-height)))

(defun helm-match-line-cleanup-pulse ()
  (run-with-timer 0.3 nil #'helm-match-line-cleanup))

(add-hook 'helm-after-update-hook 'helm-match-line-cleanup-maybe)
(add-hook 'helm-after-persistent-action-hook 'helm-persistent-autoresize-hook)
(add-hook 'helm-cleanup-hook 'helm-match-line-cleanup)
(add-hook 'helm-after-action-hook 'helm-match-line-cleanup-pulse)
(add-hook 'helm-after-persistent-action-hook 'helm-match-line-update)

;;; Popup buffer-name or filename in grep/moccur/imenu-all.
;;
(defvar helm--show-help-echo-timer nil)

(defun helm-cancel-help-echo-timer ()
  (when helm--show-help-echo-timer
    (cancel-timer helm--show-help-echo-timer)
    (setq helm--show-help-echo-timer nil)))

(defun helm-show-help-echo ()
  (when helm--show-help-echo-timer
    (cancel-timer helm--show-help-echo-timer)
    (setq helm--show-help-echo-timer nil))
  (when (and helm-alive-p
             (member (assoc-default 'name (helm-get-current-source))
                     helm-sources-using-help-echo-popup))
    (setq helm--show-help-echo-timer
          (run-with-timer
           1 nil
           (lambda ()
             (save-selected-window
               (with-helm-window
                 (helm-aif (get-text-property (point-at-bol) 'help-echo)
                     (popup-tip (concat " " (abbreviate-file-name
                                             (replace-regexp-in-string "\n.*" "" it)))
                                :around nil
                                :point (save-excursion
                                         (end-of-visual-line) (point)))))))))))

;;;###autoload
(define-minor-mode helm-popup-tip-mode
    "Show help-echo informations in a popup tip at end of line."
  :global t
  (require 'popup)
  (if helm-popup-tip-mode
      (progn
        (add-hook 'helm-after-update-hook 'helm-show-help-echo) ; Needed for async sources.
        (add-hook 'helm-move-selection-after-hook 'helm-show-help-echo)
        (add-hook 'helm-cleanup-hook 'helm-cancel-help-echo-timer))
      (remove-hook 'helm-after-update-hook 'helm-show-help-echo)
      (remove-hook 'helm-move-selection-after-hook 'helm-show-help-echo)
      (remove-hook 'helm-cleanup-hook 'helm-cancel-help-echo-timer)))

(defun helm-open-file-with-default-tool (file)
  "Open FILE with the default tool on this platform."
  (let (process-connection-type)
    (if (eq system-type 'windows-nt)
        (helm-w32-shell-execute-open-file file)
      (start-process "helm-open-file-with-default-tool"
                     nil
                     (cond ((eq system-type 'gnu/linux)
                            "xdg-open")
                           ((or (eq system-type 'darwin) ;; Mac OS X
                                (eq system-type 'macos)) ;; Mac OS 9
                            "open"))
                     file))))

(defun helm-open-dired (file)
  "Opens a dired buffer in FILE's directory.  If FILE is a
directory, open this directory."
  (if (file-directory-p file)
      (dired file)
    (dired (file-name-directory file))
    (dired-goto-file file)))

(defun helm-require-or-error (feature function)
  (or (require feature nil t)
      (error "Need %s to use `%s'." feature function)))

(defun helm-find-file-as-root (candidate)
  (let* ((buf (helm-basename candidate))
         (host (file-remote-p candidate 'host))
         (remote-path (format "/%s:%s:%s"
                              helm-su-or-sudo
                              (or host "")
                              (expand-file-name
                               (if host
                                   (file-remote-p candidate 'localname)
                                 candidate))))
         non-essential)
    (if (buffer-live-p (get-buffer buf))
        (progn
          (set-buffer buf)
          (find-alternate-file remote-path))
      (find-file remote-path))))

(defun helm-find-many-files (_ignore)
  "Simple action that run `find-file' on marked candidates.
Run `helm-find-many-files-after-hook' at end"
  (let ((helm--reading-passwd-or-string t))
    (mapc 'find-file (helm-marked-candidates))
    (helm-log-run-hook 'helm-find-many-files-after-hook)))

(defun helm-read-repeat-string (prompt &optional count)
  "Prompt as many time PROMPT is not empty.
If COUNT is non--nil add a number after each prompt."
  (cl-loop with elm
        while (not (string= elm ""))
        for n from 1
        do (when count
             (setq prompt (concat prompt (int-to-string n) ": ")))
        collect (setq elm (helm-read-string prompt)) into lis
        finally return (remove "" lis)))

(defun helm-html-bookmarks-to-alist (file url-regexp bmk-regexp)
  "Parse html bookmark FILE and return an alist with (title . url) as elements."
  (let (bookmarks-alist url title)
    (with-temp-buffer
      (insert-file-contents file)
      (goto-char (point-min))
      (while (re-search-forward "href=\\|^ *<DT><A HREF=" nil t)
        (forward-line 0)
        (when (re-search-forward url-regexp nil t)
          (setq url (match-string 0)))
        (when (re-search-forward bmk-regexp nil t)
          (setq title (url-unhex-string
                       (funcall helm-html-decode-entities-function
                               (match-string 1)))))
        (push (cons title url) bookmarks-alist)
        (forward-line)))
    (nreverse bookmarks-alist)))

(defun helm-html-entity-to-string (entity)
  "Replace an html ENTITY by its string value.
When unable to decode ENTITY returns nil."
  (helm-aif (assoc entity helm-html-entities-alist)
      (string (cdr it))
    (save-match-data
      (when (string-match "[0-9]+" entity)
        (string (string-to-number (match-string 0 entity)))))))

(defun helm-html-decode-entities-string (str)
  "Decode entities in the string STR."
  (save-match-data
    (with-temp-buffer
      (insert str)
      (goto-char (point-min))
      (while (re-search-forward "&#?\\([^;]*\\);" nil t)
        (helm-aif (helm-html-entity-to-string (match-string 0))
            (replace-match it)))
      (buffer-string))))

(provide 'helm-utils)

;; Local Variables:
;; byte-compile-warnings: (not obsolete)
;; coding: utf-8
;; indent-tabs-mode: nil
;; End:

;;; helm-utils.el ends here
