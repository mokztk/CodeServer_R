# About this image

- **rocker/r-ver** を元に rocker/tidyverse 相当のパッケージと日本語設定、頻用パッケージをインストールした作業用イメージ
    - rocker/tidyverse 相当のうち、容量の大きな dbplyr database backend は RSQLite 以外を省略
- UIとして code-server を導入
    - Rの使用を前提に拡張機能や `{httpgd}` を追加
    - RStudioにあわせたキーボードショートカットを設定
- R用のコンソールとして [radian: A 21 century R console](https://github.com/randy3k/radian) を導入

```sell
# イメージ作成・起動
docker compose build
docker compose up -d
```

| アプリケーション | 固定バージョン                        |
|------------------|---------------------------------------|
| ベースイメージ   | rocker/r-ver:4.5.2                    |
| R                | 4.5.2                                 |
| Pandoc           | 3.9 （rocker/rstudio:4.5.2 準拠）     |
| Quarto           | 1.8.25 （rocker/rstudio:4.5.2 準拠）  |
| Typst            | 0.13.0 （Quarto 同梱）                |
| httpgd           | 2.1.4 (p3m.dev / 2026-03-10)          |
| uv               | 0.10.9                                |
| Python3          | 3.12.13                               |
| Node.js          | v24 (Active LTS)                      |
| Microsoft Edit   | 1.2.0                                 |

radian (via uv), npm (via n), pnpm (via npm) については、イメージ作成時点の各パッケージマネージャーの標準設定による。

## 詳細

### 日本語環境、フォント

- Ubuntu の `language-pack-ja`, `language-pack-ja-base`
- 環境変数で `ja_JP.UTF-8` ロケールとタイムゾーン `Asia/Tokyo` を指定
- 日本語フォント
    - **[Noto Sans/Serif JP](https://fonts.google.com/noto/fonts)**（"CJK" なし）
        - `fonts-noto-cjk` は KR, SC, TC のフォントも含むので用途に対して大きすぎる
        - Windows 11 に搭載された Noto Sans/Serif JP（"CJK" なし）と作図コードに互換性が確保できる
        - Github [notofonts/noto-cjk](https://github.com/notofonts/noto-cjk) から個別のOTF版をダウンロードして、Regular, Bold の2ウェイトと Noto Sans Mono CJK JP を手動でインストール
        - serif/sans/monospace の標準日本語フォントとして設定
        - 過去コードの文字化け回避のため、Noto Sans/Serif CJK JP を Noto Sans/Serif JP の別名として登録しておく
    - code-server ではエディターフォントなどはブラウザ側のOSのものが使用されるのでプログラミングフォントは導入なし

### R の追加パッケージ

- DB backend を除く、`rocker/tidyverse` 相当＋個人的な頻用パッケージ
    - [インストール済みのパッケージ一覧](package_list.md)
- インストールの高速化、システム依存パッケージの導入をスムーズにするため `pak::pak()` を活用
    - システム依存パッケージがスムーズに導入できるよう、ユーザー `coder` はパスワード無しで `sudo` 可（**非公開での運用前提**）
- rockerのスクリプトに倣い、インストール後にDLしたアーカイブや導入された *.so を整理

### code-server の拡張機能・設定

- https://github.com/coder/code-server のインストールスクリプトを使用してインストール
- 拡張機能 
    - REditorSupport (REditorSupport.r)
    - Air - R Language Support (posit.air-vscode)
    - Quarto (quarto.quarto)
    - Gemini Code Assist (Google.geminicodeassist)
- Language Server
    - R `{languageserver}`
- RStudio と同様のキーボードショートカット
    - `Shift + Ctrl + m` で `|>` を挿入（R, Rmd, Quarto）
    - `Shift + Ctrl + c` で行コメントの切り替え（デフォルトは `Ctrl + /`）

#### settings.json 見本ファイル

- R 用コンソールは radian (r.rterm.linux)
- R のグラフィックデバイスは `httpgd::hgd()` (r.plot.useHttpgd)
- タブ設定はスペース 2文字分 (editor.tabSize)
- Air, Quarto 拡張機能による保存時の自動整形は off (editor.formatOnSave)
- ファイルの自動保存は off (files.autoSave)

コンテナ起動時に `docker run -v ./settings.json:/home/coder/.local/share/code-server/User/settings.json` としてマウントするために、`/home/coder/.local/share/code-server/User/settings.json` に所有者 coder の空ファイルを作成済

### Pandoc / Quarto

`rocker/r-ver` 内に収録されている rocker project 製のインストールスクリプトを使用して、`rocker/rstudio:4.5.2` と同じバージョンをインストール

### Python3 / radian

- インストール高速化のため、[uv](https://docs.astral.sh/uv/) を導入
- 公式の `/rocker_scripts/install_python.sh` と同様に仮想環境 `/opt/venv` を作る（プロジェクトとしての `uv init` はなし）
- [radian: A 21 century R console](https://github.com/randy3k/radian) を導入
    - code-server の R 用コンソール（Rterm）として設定
    - `ESC m` で `|>` を挿入できるようキーボードショートカットを設定

### Node.js / npm / pnpm

[Gemini CLI](https://github.com/google-gemini/gemini-cli) などを導入できるよう、 [n](https://github.com/tj/n) 経由で Ubuntu の apt にあるバージョンより新しいものを導入

- 2026-03 現在の Active LTS である Node v24系＋ npm v11系
- [pnpm](https://pnpm.io/ja/): ユーザー coder が利用する場合、リリース後1週間以上経過したパッケージのみに制限

### [Microsoft Edit](https://github.com/microsoft/edit)

`docker exec -it ...` で設定を変更する際などのCLI用のテキストエディタがないので、`msedit` の名前で使用できるように導入しておく


## History

- **2022-06-06** :bookmark:[4.1.3_2022Jun](https://github.com/mokztk/CodeServer_R/releases/tag/4.1.3_2022Jun) : `rocker/r-ver:4.1.3` 対応版 (Gist)
- **2022-07-01** [Gist: mokztk/00_r-ver_4.1.3_with_code-server.md](https://gist.github.com/mokztk/37f6806e0d8734a500ab1ff766eff53b) から改めてレポジトリとして編集を開始
- **2022-07-01** :bookmark:[4.2.0_2022Jul](https://github.com/mokztk/CodeServer_R/releases/tag/4.2.0_2022Jul) : `rocker/r-ver:4.2.0` 対応版
- **2026-02-24** :bookmark:[4.5.1_2026Feb](https://github.com/mokztk/CodeServer_R/releases/tag/4.5.1_2026Feb) : `rocker/r-ver:4.5.1` ベースで作り直したもの
- **2026-03-20** :bookmark:[4.5.2_2026Mar](https://github.com/mokztk/CodeServer_R/releases/tag/4.5.2_2026Mar) : `rocker/r-ver:4.5.2` ベースに更新
