#!/bin/bash
set -x

apt-get update

# Code-server のインストール（セットアップは別にユーザーアカウントで行う）
curl -fsSL https://code-server.dev/install.sh | sh

# aptキャッシュを消去
apt-get clean
rm -rf /var/lib/apt/lists/*

# R Language server の導入
install2.r languageserver

# Clean up
# Ref: https://github.com/rocker-org/rocker-versioned2/commit/75dd95c6cee7da29ceed363b9fe4823a12f575f8
rm -rf /tmp/downloaded_packages

## Strip binary installed libraries from RSPM
## https://github.com/rocker-org/rocker-versioned2/issues/340
strip /usr/local/lib/R/site-library/*/libs/*.so
