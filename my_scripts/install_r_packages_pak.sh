#!/bin/bash

# R パッケージのインストール

# まず最新の状態まで更新する
Rscript -e "update.packages(ask = FALSE)"

# pak::pak() で依存ライブラリもインストールしてくれるので apt install は省略
Rscript -e "install.packages('pak')"

# インストール補助の関数
# 引数を１つずつ '' で囲んで , で繋いだものを pak::pak() に渡す
function pak_pak() {
    local pkgs=""
    local first=true
    for item in "$@"; do
        if ! $first; then
            pkgs="${pkgs},"
        fi
        pkgs="${pkgs}'${item}'"
        first=false
    done
    Rscript -e "pak::pak(c(${pkgs}))"
}

# code-server で使うもの

pak_pak \
    languageserver \
    nx10/httpgd@dd6ed3a

# rocker/tidyverse 相当のパッケージ
# 容量の大きな database backend は RSQLite 以外省略（行番号は @5d33fd1 準拠）
# sed -e 48d -e 52,56d /rocker_scripts/install_tidyverse.sh | bash

pak_pak \
    tidyverse \
    devtools \
    rmarkdown \
    BiocManager \
    vroom \
    gert \
    dbplyr \
    DBI \
    dtplyr \
    RSQLite \
    fst

# 繁用パッケージ
pak_pak \
    here \
    pacman \
    knitr \
    quarto \
    tidylog \
    furrr \
    glmnetUtils \
    glmmTMB \
    ggeffects \
    pROC \
    cmprsk \
    car \
    mice \
    ggmice \
    survminer \
    ggsurvfit \
    GGally \
    ggfortify \
    gghighlight \
    ggsci \
    ggrepel \
    patchwork \
    gt \
    gtsummary \
    flextable \
    formattable \
    ftExtra \
    minidown \
    DiagrammeR \
    palmerpenguins \
    basepenguins \
    styler \
    svglite \
    export \
    tidyplots \
    tinytable \
    RcppEigen \
    cpp11 \
    plogr \
    reticulate

# R.cache (imported by styler) で使用するキャッシュディレクトリを準備
mkdir -p /home/coder/.cache/R/R.cache
chown -R coder:coder /home/coder/.cache

# Clean up
Rscript -e "pak::pak_cleanup(force = TRUE)"
rm -rf /tmp/downloaded_packages
rm -rf /tmp/Rtmp*
strip /usr/local/lib/R/site-library/*/libs/*.so

apt-get clean
#rm -rf /var/lib/apt/lists/*
