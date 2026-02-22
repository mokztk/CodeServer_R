#!/bin/bash

# 各アプリのユーザー設定

#-------------------------------
#  R
#-------------------------------

# User library
# R_LIBS_USER に指定されているディレクトリを .libPaths() の先頭にする

Rscript -e 'dir.create(Sys.getenv("R_LIBS_USER"), recursive = TRUE)'
echo '.libPaths(c(Sys.getenv("R_LIBS_USER"), .Library.site, .Library))' >> /home/coder/.Rprofile

#-------------------------------
#  code-server
#-------------------------------

# VS Code plugins
code-server --install-extension REditorSupport.r
code-server --install-extension posit.air-vscode
code-server --install-extension Google.geminicodeassist
code-server --install-extension quarto.quarto

# 設定ファイルを docker run -v でマウントするための空ファイル
# 所有者を coder にして準備しておかないと root になってしまい変更が書き込めない
mkdir -p /home/coder/.config/code-server
touch /home/coder/.local/share/code-server/User/settings.json

# Rのグラフィックデバイスとして httpgd::hgd() を使う設定
# settings.json で "r.plot.useHttpgd": true が必要

cat << EOF >> /home/coder/.Rprofile

# use httpgd::hgd() for preview R plots
options(
  device = "httpgd",
  httpgd.host = "0.0.0.0",
  httpgd.port = 8088,
  httpgd.token = ""
)

EOF

# RStudio に合わせたキーボードショートカット
cat << EOF > ~/.local/share/code-server/User/keybindings.json
[
    {
        "key": "ctrl+shift+m",
        "command": "type",
        "args": {
          "text": " |> "
        },
        "when": "editorTextFocus && editorLangId == 'r'"
    },
    {
        "key": "ctrl+shift+m",
        "command": "type",
        "args": {
          "text": " |> "
        },
        "when": "editorTextFocus && editorLangId == 'rmd'"
    },
    {
        "key": "ctrl+shift+m",
        "command": "type",
        "args": {
          "text": " |> "
        },
        "when": "editorTextFocus && editorLangId == 'quarto'"
    },
    {
        "key": "ctrl+shift+c",
        "command": "editor.action.commentLine",
        "when": "editorTextFocus && !editorReadonly"
    },
    {
        "key": "ctrl+/",
        "command": "-editor.action.commentLine",
        "when": "editorTextFocus && !editorReadonly"
    }
]
EOF

#-------------------------------
#  radian
#-------------------------------

cat << EOF > ~/.radian_profile
options(
  radian.auto_match = TRUE,
  radian.highlight_matching_bracket = TRUE,
  radian.prompt = "\033[1;35mr$>\033[0m ",
  radian.escape_key_map = list(
    list(key = "m", value = " |> ")
  ),
  radian.force_reticulate_python = TRUE
)
EOF

#-------------------------------
#  PNPM
#-------------------------------

# 安全のため、リリース後1週間以上経ったパッケージのみインストールできるようにする

pnpm setup
pnpm config set --location=global minimumReleaseAge 10080

