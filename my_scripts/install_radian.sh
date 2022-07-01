#!/bin/bash
set -x

# Python3 のインストール
source /rocker_scripts/install_python.sh
install2.r --skipinstalled reticulate

# aptキャッシュを消去
apt-get clean
rm -rf /var/lib/apt/lists/*

# グローバルに pandas と matplotlib/seaborn を入れておく
python3 -m pip --no-cache-dir install pandas seaborn

# radian: A 21 century R console. のインストール
python3 -m pip --no-cache-dir install radian jedi
