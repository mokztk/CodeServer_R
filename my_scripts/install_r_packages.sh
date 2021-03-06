#!/bin/bash
set -x

# 依存ライブラリ
apt-get update
apt-get install -y --no-install-recommends \
    libcairo2-dev \
    libcurl4-openssl-dev \
    libfontconfig1-dev \
    libfreetype6-dev \
    libgl1-mesa-dev \
    libglu1-mesa-dev \
    libjpeg-dev \
    libpng-dev \
    libssl-dev \
    libxft-dev \
    zlib1g-dev

apt-get clean
rm -rf /var/lib/apt/lists/*

# RSPMのcheckpointが変わった場合に対応するため、まずcheckpointの状態まで更新する
Rscript -e "update.packages(ask = FALSE)"

# CRANパッケージをRSPMからインストール
# --deps TRUE をつけると依存関係 Suggests までインストールされ膨大になる
install2.r --error --skipinstalled \
    pacman \
    here \
    tidylog \
    furrr \
    glmnetUtils \
    pROC \
    cmprsk \
    psych \
    clinfun \
    car \
    survminer \
    GGally \
    ggfortify \
    gghighlight \
    ggsci \
    ggrepel \
    patchwork \
    tableone \
    gt \
    gtsummary \
    flextable \
    formattable \
    ftExtra \
    minidown \
    palmerpenguins \
    svglite \
    httpgd

# install dev version of {export} from GitHub repo (commit 1afc8e2 / 2021-03-09)
install2.r --error --skipinstalled \
    officer \
    rvg \
    openxlsx \
    flextable \
    xtable \
    rgl \
    stargazer \
    devEMF

installGithub.r tomwenseleers/export@1afc8e2


# Clean up
# Ref: https://github.com/rocker-org/rocker-versioned2/commit/75dd95c6cee7da29ceed363b9fe4823a12f575f8
rm -rf /tmp/downloaded_packages

## Strip binary installed libraries from RSPM
## https://github.com/rocker-org/rocker-versioned2/issues/340
strip /usr/local/lib/R/site-library/*/libs/*.so
