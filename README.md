## About this image

`rocker/r-ver` をベースに、UIとして code-server を導入したもの。ARM64 の環境でも使える解析環境を目指す。

- **rocker/r-ver:4.2.0**
    - CRAN repository は Public Rstudio Package Manager の 2022-06-22 で固定されている
- **code-server**
    - https://github.com/coder/code-server のインストールスクリプトを使用
    - Extensions: 
        - R Extension for Visual Studio Code (Ikuyadeu.r)
        - R Debugger (RDebugger.r-debugger)
        - indent-rainbow (oderwat.indent-rainbow)
        - GitHub Theme (GitHub.github-vscode-theme)
    - エディタフォントは [UDEV Gothic](https://github.com/yuru7/udev-gothic) （BIZ UD Gothic + JetBrains Mono）のリガチャ対応版を使用
    - RStudio のように Ctrl + Shift + m で `%>%` を入力できるように設定
    - Plot は {httpgd} を使って表示するよう設定（`0.0.0.0:59531` を使用）
- Ubuntu mirror
    - <s>自動選択の `mirror://mirrors.ubuntu.com/mirrors.txt` に変更</s>
    - x86_64 の場合は日本のミラーサーバーで一番回線が太い ICSCoE（IPA産業サイバーセキュリティセンター）に変更
    - Ref: https://launchpad.net/ubuntu/+archivemirrors
- 日本語ロケール
    - Ubuntu の `language-pack-ja`, `language-pack-ja-base`
    - 環境変数で `ja_JP.UTF-8` ロケールとタイムゾーン `Asia/Tokyo` を指定
    - フォントは容量節約のためパッケージを使わず下記を手動で追加
        - Noto Sans/Serif JP（[Google Fonts](https://fonts.google.com/) で配布されている日本語サブセット版）
        - UDEV Gothic LG（BIZ UD Gothic + JetBrains Mono のリガチャ対応版）
- R pachages
    - `rocker/tidyverse` に導入されているものから、容量の大きな database backend を省略したもの
    - 関連して必要となる Pandoc は、Ubuntu 20.04LTS のものはバージョンが古いので公式サイトの deb を使用
    - 個人的な頻用パッケージも追加しておく
    - `install2.r --ncpus -1 ...` で並列化すると、ARM64でうまくいかない場合があった(big.LITTLE構成のため？）ので `--ncpus` 指定を削除
- [radian: A 21 century R console](https://github.com/randy3k/radian)
- Python
    - Python3 のインストールには `/rocker_scripts/install_python.sh` を使用
    - グローバルに pandas と matplotlib/seaborn を入れておく

[rocker-org/rocker-versioned2](https://github.com/rocker-org/rocker-versioned2) のように、目的別のスクリプトを使って Dockerfile 自体は極力シンプルに。

## History

- **2022-06-06** :bookmark:[4.1.3_2022Jun](https://github.com/mokztk/CodeServer_R/releases/tag/4.1.3_2022Jun) : `rocker/r-ver:4.1.3` 対応版 (Gist)
- **2022-07-01** [Gist: mokztk/00_r-ver_4.1.3_with_code-server.md](https://gist.github.com/mokztk/37f6806e0d8734a500ab1ff766eff53b) から改めてレポジトリとして編集を開始
- **2022-07-01** :bookmark:[4.2.0_2022Jul](https://github.com/mokztk/CodeServer_R/releases/tag/4.2.0_2022Jul) : `rocker/r-ver:4.2.0` 対応版

