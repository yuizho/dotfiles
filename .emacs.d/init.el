;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;外観                                                      ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ウィンドウサイズの位置、サイズ
(if window-system (progn
  (setq initial-frame-alist '((width . 100)(height . 53)(top . 0)(left . 48)))
  (set-background-color "Black")
  (set-foreground-color "White")
  (set-cursor-color "Gray")
))

;; ウィンドウの透明化
(add-to-list 'default-frame-alist '(alpha . (0.8 0.8)))

;;; ツールバーを非表示
;; M-x tool-bar-mode で表示非表示を切り替えられる
(tool-bar-mode -1)

;; タイトルバーにファイル名表示
(setq frame-title-format (format "%%f - Emacs@%s" (system-name)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 3.2 Emacsの起動と終了                                  ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; P30 デバッグモードでの起動
;; おまじない
(require 'cl)
;; Emacsからの質問をy/nで回答する
(fset 'yes-or-no-p 'y-or-n-p)
;; スタートアップメッセージを非表示
;;(setq inhibit-startup-screen t)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 4.1 効率的な設定ファイルの作り方と管理方法             ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; P60-61 Elisp配置用のディレクトリを作成
;; Emacs 23より前のバージョンを利用している方は
;; user-emacs-directory変数が未定義のため次の設定を追加
(when (< emacs-major-version 23)
  (defvar user-emacs-directory "~/.emacs.d/"))

;; load-path を追加する関数を定義
(defun add-to-load-path (&rest paths)
  (let (path)
    (dolist (path paths paths)
      (let ((default-directory
              (expand-file-name (concat user-emacs-directory path))))
        (add-to-list 'load-path default-directory)
        (if (fboundp 'normal-top-level-add-subdirs-to-load-path)
            (normal-top-level-add-subdirs-to-load-path))))))

;; 引数のディレクトリとそのサブディレクトリをload-pathに追加
;; (add-to-load-path "elisp" "conf" "public_repos")


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 4.2 環境に応じた設定の分岐                             ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; P65 CUIとGUIによる分岐
;; ターミナル以外はツールバー、スクロールバーを非表示
(when window-system
  ;; tool-barを非表示
  (tool-bar-mode 0)
  ;; scroll-barを非表示
  (scroll-bar-mode 0))

;; CocoaEmacs以外はメニューバーを非表示
(unless (eq window-system 'ns)
  ;; menu-barを非表示
  (menu-bar-mode 0))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 5.2 キーバインドの設定                                 ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; P80 C-hをバックスペースにする
;; 入力されるキーシーケンスを置き換える
;; ?\C-?はDELのキーシケンス
(keyboard-translate ?\C-h ?\C-?)

;;; P79-81 お勧めのキー操作
;; C-mにnewline-and-indentを割り当てる。
;; 先ほどとは異なりglobal-set-keyを利用
(global-set-key (kbd "C-m") 'newline-and-indent)
;; 折り返しトグルコマンド
(define-key global-map (kbd "C-c l") 'toggle-truncate-lines)
;; "C-t" でウィンドウを切り替える。初期値はtranspose-chars
(define-key global-map (kbd "C-t") 'other-window)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ファイル読み込みの設定　                                  ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 自動で外部でのファイル更新を読み込み
(global-auto-revert-mode 1)

;; F5キーでファイルを再読み込み
;; (global-set-key (kbd "<f5>") 'revert-buffer-no-confirm)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 5.3 環境変数の設定                                     ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; P82-83 パスの設定
(add-to-list 'exec-path "/opt/local/bin")
(add-to-list 'exec-path "/usr/local/bin")
(add-to-list 'exec-path "~/bin")
;; shellのpathを引き継ぎ
;; http://qiita.com/catatsuy/items/3dda714f4c60c435bb25
(defun set-exec-path-from-shell-PATH ()
    "Set up Emacs' `exec-path' and PATH environment variable to match that used by the user's shell.

This is particularly useful under Mac OSX, where GUI apps are not started from a shell."
    (interactive)
    (let ((path-from-shell (replace-regexp-in-string "[ \t\n]*$" "" (shell-command-to-string "$SHELL --login -i -c 'echo $PATH'"))))
      (setenv "PATH" path-from-shell)
      (setq exec-path (split-string path-from-shell path-separator))))
(set-exec-path-from-shell-PATH)

;;; P85 文字コードを指定する
(set-language-environment "Japanese")
(prefer-coding-system 'utf-8)

;;; P86 ファイル名の扱い
;; Mac OS Xの場合のファイル名の設定
(when (eq system-type 'darwin)
  (require 'ucs-normalize)
  (set-file-name-coding-system 'utf-8)
  (setq locale-coding-system 'utf-8))

;; Windowsの場合のファイル名の設定
(when (eq window-system 'w32)
  (set-file-name-coding-system 'cp932)
  (setq locale-coding-system 'cp932))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 5.4 フレームに関する設定                               ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; P87-89 モードラインに関する設定
;; カラム番号も表示
(column-number-mode t)
;; ファイルサイズを表示
(size-indication-mode t)
;; 時計を表示（好みに応じてフォーマットを変更可能）
;; (setq display-time-day-and-date t) ; 曜日・月・日を表示
(setq display-time-24hr-format t) ; 24時表示
(display-time-mode t)
;; バッテリー残量を表示
(display-battery-mode t)

;; リージョン内の行数と文字数をモードラインに表示する（範囲指定時のみ）
;; http://d.hatena.ne.jp/sonota88/20110224/1298557375
(defun count-lines-and-chars ()
  (if mark-active
      (format "%d lines,%d chars "
              (count-lines (region-beginning) (region-end))
              (- (region-end) (region-beginning)))
      ;; これだとエコーエリアがチラつく
      ;;(count-lines-region (region-beginning) (region-end))
    ""))

(add-to-list 'default-mode-line-format
             '(:eval (count-lines-and-chars)))

;;; P90 タイトルバーにファイルのフルパスを表示
(setq frame-title-format "%f")
;; 行番号を常に表示する
(global-linum-mode t)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 5.5インデントの設定                                    ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; P92-94 タブ文字の表示幅
;; TABの表示幅。初期値は8
(setq-default tab-width 4)
;; インデントにタブ文字を使用しない
(setq-default indent-tabs-mode nil)
;; php-modeのみタブを利用しない
;; (add-hook 'php-mode-hook
;;           '(lambda ()
;;             (setq indent-tabs-mode nil)))

;; C、C++、JAVA、PHPなどのインデント
(add-hook 'c-mode-common-hook
          '(lambda ()
             (c-set-style "java")))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 5.6 表示・装飾に関する設定                             ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Emacs24からのColor-theme
(load-theme 'misterioso t)

;;; P97-99 フォントの設定
(when (eq window-system 'ns)
  ;; asciiフォントをMenloに
  (set-face-attribute 'default nil
                      :family "Menlo"
                      :height 240)
  ;; 日本語フォントをヒラギノ明朝 Proに
  (set-fontset-font
   nil 'japanese-jisx0208
   ;; 英語名の場合
   ;; (font-spec :family "Hiragino Mincho Pro"))
   (font-spec :family "ヒラギノ明朝 Pro"))
  ;; ひらがなとカタカナをモトヤシーダに
  ;; U+3000-303FCJKの記号および句読点
  ;; U+3040-309Fひらがな
  ;; U+30A0-30FFカタカナ
  (set-fontset-font
   nil '(#x3040 . #x30ff)
   (font-spec :family "NfMotoyaCedar"))
  ;; フォントの横幅を調節する
  (setq face-font-rescale-alist
        '((".*Menlo.*" . 1.0)
          (".*Hiragino_Mincho_Pro.*" . 1.2)
          (".*nfmotoyacedar-bold.*" . 1.2)
          (".*nfmotoyacedar-medium.*" . 1.2)
          ("-cdac$" . 1.3))))

(when (eq system-type 'windows-nt)
  ;; asciiフォントをConsolasに
  (set-face-attribute 'default nil
                      :family "Consolas"
                      :height 120)
  ;; 日本語フォントをメイリオに
  (set-fontset-font
   nil
   'japanese-jisx0208
   (font-spec :family "メイリオ"))
  ;; フォントの横幅を調節する
  (setq face-font-rescale-alist
        '((".*Consolas.*" . 1.0)
          (".*メイリオ.*" . 1.15)
          ("-cdac$" . 1.3))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 5.7 ハイライトの設定                                   ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; P100 現在行のハイライト
(defface my-hl-line-face
  ;; 背景がdarkならば背景色を紺に
  '((((class color) (background dark))
     (:background "gray8" t))
    ;; 背景がlightならば背景色を緑に
    (((class color) (background light))
     (:background "98FB98" t))
    (t (:bold t)))
  "hl-line's my face")
(setq hl-line-face 'my-hl-line-face)
(global-hl-line-mode t)

;; P101 括弧の対応関係のハイライト
;; paren-mode：対応する括弧を強調して表示する
(setq show-paren-delay 0) ; 表示までの秒数。初期値は0.125
(show-paren-mode t) ; 有効化
;; parenのスタイル: expressionは括弧内も強調表示
(setq show-paren-style 'expression)
;; フェイスを変更する
(set-face-background 'show-paren-match-face nil)
(set-face-underline-p 'show-paren-match-face "gray8")


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 5.8 バックアップとオートセーブ                         ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; P102-103 バックアップとオートセーブの設定
;; バックアップファイルを作成しない
;; (setq make-backup-files nil) ; 初期値はt
;; オートセーブファイルを作らない
;; (setq auto-save-default nil) ; 初期値はt

;; バックアップファイルの作成場所をシステムのTempディレクトリに変更する
;; (setq backup-directory-alist
;;       `((".*" . ,temporary-file-directory)))
;; オートセーブファイルの作成場所をシステムのTempディレクトリに変更する
;; (setq auto-save-file-name-transforms
;;       `((".*" ,temporary-file-directory t)))

;; バックアップとオートセーブファイルを~/.emacs.d/backups/へ集める
(add-to-list 'backup-directory-alist
             (cons "." "~/.emacs.d/backups/"))
(setq auto-save-file-name-transforms
      `((".*" ,(expand-file-name "~/.emacs.d/backups/") t)))

;; オートセーブファイル作成までの秒間隔
(setq auto-save-timeout 15)
;; オートセーブファイル作成までのタイプ間隔
(setq auto-save-interval 60)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 5.9 フック                                             ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ファイルが #! から始まる場合、+xを付けて保存する
(add-hook 'after-save-hook
          'executable-make-buffer-file-executable-if-script-p)

;; emacs-lisp-mode-hook用の関数を定義
(defun elisp-mode-hooks ()
  "lisp-mode-hooks"
  (when (require 'eldoc nil t)
    (setq eldoc-idle-delay 0.2)
    (setq eldoc-echo-area-use-multiline-p t)
    (turn-on-eldoc-mode)))

;; emacs-lisp-modeのフックをセット
(add-hook 'emacs-lisp-mode-hook 'elisp-mode-hooks)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 6.1 Elispをインストールしよう                          ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ▼要拡張機能インストール▼
;;; P113 拡張機能を自動インストール──auto-install
;; auto-installの設定
(when (require 'auto-install nil t); ←1●
  ;; 2●インストールディレクトリを設定する 初期値は ~/.emacs.d/auto-install/
  (setq auto-install-directory "~/.emacs.d/elisp/")
  ;; EmacsWikiに登録されているelisp の名前を取得する
  ;; FIXME: これいつも失敗してしまうので、とりあえずコメントアウト。
  ;;(auto-install-update-emacswiki-package-name t)
  ;; 必要であればプロキシの設定を行う
  ;; (setq url-proxy-services '(("http" . "localhost:8339")))
  ;; 3●install-elisp の関数を利用可能にする
  (auto-install-compatibility-setup)) ; 4●

;; ▼要拡張機能インストール▼
;;; P114-115 auto-installを利用する
;; FIXME: ここの設定がEmacs24.4ではうまく反映されない
;; (install-elisp "http://www.emacswiki.org/emacs/download/redo+.el")
;;(when (require 'redo+ nil t)
  ;; C-' にリドゥを割り当てる
;;  (global-set-key (kbd "C-'") 'redo)
  ;; 日本語キーボードの場合C-. などがよいかも
  ;; (global-set-key (kbd "C-.") 'redo)
;;  ) ; ←ここでC-x C-eで設定反映

;; ▼要拡張機能インストール▼（ただし、Emacs24からはインストール不要）
;;; P115-116 Emacs Lisp Package Archive（ELPA）──Emacs Lispパッケージマネージャ
;; package.elの設定
(when (require 'package nil t)
  ;; パッケージリポジトリにMarmaladeと開発者運営のELPAを追加
  (add-to-list 'package-archives
               '("marmalade" . "http://marmalade-repo.org/packages/"))
  ;;(add-to-list 'package-archives '("ELPA" . "http://tromey.com/elpa/"))
  (add-to-list 'package-archives '("melpa" . "http://melpa.milkbox.net/packages/"))
  ;; インストールしたパッケージにロードパスを通して読み込む
  (package-initialize))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 6.2 統一したインタフェースでの操作                     ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; helmの設定
(global-set-key (kbd "C-x b") 'helm-buffers-list)
(global-set-key (kbd "C-x r b") 'helm-bookmarks)
(global-set-key (kbd "C-x m") 'helm-M-x)
(global-set-key (kbd "M-y") 'helm-show-kill-ring)
(global-set-key (kbd "C-x C-f") 'helm-find-files)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 6.3 入力の効率化                                       ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ▼要拡張機能インストール▼
;;; P130-131 利用可能にする
(when (require 'auto-complete-config nil t)
  (add-to-list 'ac-dictionary-directories 
    "~/.emacs.d/elisp/ac-dict")
  (define-key ac-mode-map (kbd "M-TAB") 'auto-complete)
  (ac-config-default))

;; 閉じカッコの自動挿入
;; http://bhby39.blogspot.jp/2014/02/emacs.html
(electric-pair-mode 1)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 6.4 検索と置換の拡張                                   ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ▼要拡張機能インストール▼
;;; P132 検索結果をリストアップする──color-moccur
;; color-moccurの設定
(when (require 'color-moccur nil t)
  ;; M-oにoccur-by-moccurを割り当て
  (define-key global-map (kbd "M-o") 'occur-by-moccur)
  ;; スペース区切りでAND検索
  (setq moccur-split-word t)
  ;; ディレクトリ検索のとき除外するファイル
  (add-to-list 'dmoccur-exclusion-mask "\\.DS_Store")
  (add-to-list 'dmoccur-exclusion-mask "^#.+#$")
  ;; Migemoを利用できる環境であればMigemoを使う
  (when (and (executable-find "cmigemo")
             (require 'migemo nil t))
    (setq moccur-use-migemo t)))

;; ▼要拡張機能インストール▼
;;; P133-134 moccurの結果を直接編集──moccur-edit
;; moccur-editの設定
(require 'moccur-edit nil t)
;; moccur-edit-finish-editと同時にファイルを保存する
;; (defadvice moccur-edit-change-file
;;   (after save-after-moccur-edit-buffer activate)
;;   (save-buffer))

;; ▼要拡張機能インストール▼
;;; P136 grepの結果を直接編集──wgrep
;; wgrepの設定
(require 'wgrep nil t)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ********* 各言語ごとの設定 *********
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Python用の設定
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; python-modeの基本設定
(add-hook 'python-mode-hook
    (lambda ()
      (setq indent-tabs-mode nil)
      (setq indent-level 4)
      (setq python-indent 4)
      (setq tab-width 4)))

;;; 自動インデントの設定
(add-hook 'python-mode-hook
          (lambda ()
            (define-key python-mode-map (kbd "\C-m") 'newline-and-indent)
            (define-key python-mode-map (kbd "RET") 'newline-and-indent)))

;;; jediの設定
;;(add-hook 'python-mode-hook 'jedi:setup)
;;(setq jedi:complete-on-dot t)

;;; flake8の設定
;; pyflake - flake8 - pep8
(defun flycheck-python-setup ()(flycheck-mode))
(add-hook 'python-mode-hook #'flycheck-python-setup)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; JS, Html, Cssの設定
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; js2-modeの基本設定
(autoload 'js2-mode "js2-mode" nil t)
(add-to-list 'auto-mode-alist '("\\.js\\'" . js2-mode))
;; defaultのシンタクスチェックをoffに
;; http://umi-uyura.hatenablog.com/entry/2015/10/28/182320
(setq js2-include-browser-externs nil)
(setq js2-mode-show-parse-errors nil)
(setq js2-mode-show-strict-warnings nil)
(setq js2-highlight-external-variables nil)
(setq js2-include-jslint-globals nil)
;; FlycheckのJSHint設定を解除
(eval-after-load 'flycheck
  '(custom-set-variables
    '(flycheck-disabled-checkers '(javascript-jshint javascript-jscs))
    ))
;; .jsx のファイルで js2-jsx-mode を使う
(add-to-list 'auto-mode-alist '("\\.jsx$" . js2-jsx-mode))
;; js2-jsx-mode を使う時には flycheck-mode も使う
(add-hook 'js2-jsx-mode-hook #'flycheck-mode)

;;; web-mod(html, css)eの設定
(require 'web-mode)
;;; emacs 23以下の互換
(when (< emacs-major-version 24)
  (defalias 'prog-mode 'fundamental-mode))

;;; 適用する拡張子
(add-to-list 'auto-mode-alist '("\\.html?$"     . web-mode))

;;; インデント数
(defun web-mode-hook ()
  "Hooks for Web mode."
  (setq web-mode-html-offset   2)
  (setq web-mode-css-offset    2)
  (setq web-mode-script-offset 2)
  (setq web-mode-php-offset    2)
  (setq web-mode-java-offset   2)
  (setq web-mode-asp-offset    2))
(add-hook 'web-mode-hook 'web-mode-hook)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Erlang用の設定
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(add-hook 'erlang-mode-hook 'erlang-font-lock-level-4)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; OCaml用の設定
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(add-to-list 'auto-mode-alist '("\\.ml[iylp]?" . tuareg-mode))
(autoload 'tuareg-mode "tuareg" "Major mode for editing OCaml code" t)
(autoload 'tuareg-run-ocaml "tuareg" "Run an inferior OCaml process." t)
(autoload 'ocamldebug "ocamldebug" "Run the OCaml debugger" t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Haskell用の設定
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(add-to-list 'auto-mode-alist '("\\.hs" . haskell-mode))
(add-hook 'haskell-mode-hook 'turn-on-haskell-doc-mode)
(add-hook 'haskell-mode-hook 'turn-on-haskell-indent)
(add-hook 'haskell-mode-hook 'font-lock-mode)
(add-hook 'haskell-mode-hook 'imenu-add-menubar-index)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(flycheck-disabled-checkers (quote (javascript-jshint javascript-jscs)))
 '(package-selected-packages
   (quote
    (ensime wgrep web-mode tuareg python-mode pos-tip multi-term magit js2-mode htmlize helm-swoop haskell-mode flymake flycheck erlang))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Scala用の設定
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; scala-mode
(require 'scala-mode)
(add-to-list 'auto-mode-alist '("\.scala$" . scala-mode))
;;
;; ensime
(require 'ensime)
(add-hook 'scala-mode-hook 'ensime)
