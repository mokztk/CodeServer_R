#!/bin/bash
set -x

# まず、rocker/tidyverse 相当のパッケージを導入
# 容量の大きな database backend は省略
# Ref: https://github.com/eitsupi/r-ver/blob/main/scripts/install_editorsupports.sh
#      https://github.com/rocker-org/rocker-versioned2/blob/master/scripts/install_tidyverse.sh

# 依存ライブラリの追加
apt-get update
apt-get install -y --no-install-recommends \
    file \
    gdebi-core \
    git \
    lsb-release \
    procps \
    psmisc \
    python-setuptools \
    sudo \
    unixodbc-dev \
    wget \
    libapparmor1 \
    libcairo2-dev \
    libclang-dev \
    libcurl4-openssl-dev \
    libedit2 \
    libgc1c2 \
    libgit2-dev \
    libobjc4 \
    libsasl2-dev \
    libssh2-1-dev \
    libssl-dev \
    libxml2-dev \
    libxtst6 \
    libsqlite3-dev

# Pandoc は Ubuntu 20.04 LTS のものは ver.2.5 と古いので、新しいものをインストールする
if [ `uname -m` = "aarch64" ]; then
    PANDOC_DLFILE="pandoc-2.17.1.1-1-arm64.deb"
else
    PANDOC_DLFILE="pandoc-2.17.1.1-1-amd64.deb"
fi

wget -q https://github.com/jgm/pandoc/releases/download/2.17.1.1/${PANDOC_DLFILE}
gdebi -n $PANDOC_DLFILE
rm $PANDOC_DLFILE

apt-get clean
rm -rf /var/lib/apt/lists/*

# R packages
install2.r --error --ncpus -1 --skipinstalled \
    tidyverse \
    devtools \
    rmarkdown \
    BiocManager \
    vroom \
    gert
