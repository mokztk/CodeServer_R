#!/bin/bash

# Code-server のセットアップ

# 拡張機能の導入
code-server --install-extension Ikuyadeu.r
code-server --install-extension RDebugger.r-debugger
code-server --install-extension oderwat.indent-rainbow
code-server --install-extension GitHub.github-vscode-theme

# 設定ファイル
cat << EOF > ~/.config/code-server/config.yaml
bind-addr: 0.0.0.0:8080
auth: none
cert: false
EOF

cat << EOF > ~/.local/share/code-server/User/settings.json
{
    "r.rpath.linux": "/usr/local/bin/R",
    "r.rterm.linux": "/usr/local/bin/radian",
    "r.bracketedPaste": true,
    "r.plot.useHttpgd": true,
    "workbench.colorTheme": "GitHub Dark Default",
    "files.autoSave": "off",
    "editor.fontFamily": "'UDEV Gothic LG'",
    "editor.fontLigatures": true,
    "editor.fontSize": 16,
    "terminal.integrated.fontSize": 16,
    "editor.tabSize": 2,
    "editor.guides.indentation": false,
    "indentRainbow.colors": [
        "rgba(59,82,139,0.2)",
        "rgba(33,144,140,0.2)",
        "rgba(93,200,99,0.2)",
        "rgba(253,231,37,0.2)"
    ]
}
EOF

cat << EOF > ~/.local/share/code-server/User/keybindings.json
[
    {
        "key": "ctrl+shift+m",
        "command": "type",
        "args": {
          "text": " %>% "
        },
        "when": "editorTextFocus && editorLangId == 'r'"
    },
    {
        "key": "ctrl+shift+m",
        "command": "type",
        "args": {
          "text": " %>% "
        },
        "when": "editorTextFocus && editorLangId == 'rmd'"
    },
]
EOF

cat << EOF > ~/.radian_profile
options(radian.auto_match = TRUE)
options(radian.highlight_matching_bracket = TRUE)
options(radian.prompt = "\033[0;32mr$>\033[0m ")
options(radian.escape_key_map = list(
  list(key = "-", value = " <- "),
  list(key = "m", value = " %>% ")
))
options(radian.force_reticulate_python = TRUE)
EOF

cat << EOF > ~/.Rprofile
# httpgd settings
options(httpgd.host = "0.0.0.0")
options(httpgd.port = 59531)
EOF
