## About this image

`r-ver:4.1.3` をベースに、UIとして code-server を導入したもの。ARM64 の環境でも使える解析環境を目指す。

- **rocker/r-ver:4.1.3**
    - CRAN repository は Public Rstudio Package Manager の 2022-04-21 に固定されている
- **code-server**
    - https://github.com/coder/code-server のインストールスクリプトを使用
    - Extensions
        - R Extension for Visual Studio Code (Ikuyadeu.r)
        - R LSP Client for VS Code (REditorSupport.r-lsp)
    - エディタフォントは [UDEV Gothic](https://github.com/yuru7/udev-gothic) （BIZ UD Gothic + JetBrains Mono）のリガチャ対応版を使用
    - RStudio のように Ctrl + Shift + m で `%>%` を入力できるように設定
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
- [radian: A 21 century R console](https://github.com/randy3k/radian)
- Python
    - Python3 のインストールには `/rocker_scripts/install_python.sh` を使用
    - グローバルに pandas と matplotlib/seaborn を入れておく

---

[rocker-org/rocker-versioned2](https://github.com/rocker-org/rocker-versioned2) のように、目的別のスクリプトを使って Dockerfile 自体は極力シンプルにしてみる。

Gist ではディレクトリが使えないので、各インストールスクリプトは "my_scripts__\*" として保存してある。\
`docker image build` の際は Dockerfile と同じ階層の "my_scripts" というディレクトリに "install_\*.sh" と改名して格納しておく。改行コードが LF(UNIX) でないとエラーになるので注意。

```sh
unzip {id_of_this_gist}.zip
cd {id_of_this_gist}
mkdir my_scripts
find my_scripts* | sed -e 's%\(my_scripts__\(.*\)\)%mv \1 my_scripts\/\2%g' | sh
```
