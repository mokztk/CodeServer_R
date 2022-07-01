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
