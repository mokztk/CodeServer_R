# rocker/r-ver に code-server を追加する

FROM rocker/r-ver:4.5.1

ENV DEBIAN_FRONTEND=noninteractive

# 日本語設定と必要なライブラリ（Rパッケージ用は別途スクリプト内で導入）
# 以降も何度か apt-get を使うので BuildKit のキャッシュマウント機能を使う
RUN --mount=type=cache,target=/var/lib/apt,sharing=locked \
    --mount=type=cache,target=/var/cache/apt,sharing=locked \
    apt-get update \
    && apt-get install -y --no-install-recommends \
        sudo \
        curl \
        wget \
        zstd \
        ca-certificates \
        git \
        language-pack-ja-base \
    && /usr/sbin/update-locale LANG=ja_JP.UTF-8 LANGUAGE="ja_JP:ja" \
    && /bin/bash -c "source /etc/default/locale" \
    && ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime \
    && apt-get clean \
    && mkdir -p /etc/R

# coder user (passwordless sudo)
RUN useradd -m -s /bin/bash coder \
 && echo "coder ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/coder \
 && chmod 0440 /etc/sudoers.d/coder

# code-server
RUN curl -fsSL https://code-server.dev/install.sh | sh

# Quarto CLI
# rocker/rstudio:4.5.1 と同じバージョンを指定して、rocker公式のインストールスクリプトで導入
# wget, ca-certicifates は導入済みのため apt の処理はスキップ（行番号は @07c155e 準拠）

ARG PANDOC_VERSION="3.8.2.1" \
    QUARTO_VERSION="1.7.32"

RUN --mount=type=cache,target=/var/lib/apt,sharing=locked \
    --mount=type=cache,target=/var/cache/apt,sharing=locked \
    sed -e "16,26d" /rocker_scripts/install_pandoc.sh | bash \
    && sed -e "21,31d" /rocker_scripts/install_quarto.sh | bash

# uv (Python manager) & radian
COPY --from=ghcr.io/astral-sh/uv:0.9.8 /uv /uvx /opt/uv/bin/

ENV UV_PYTHON_INSTALL_DIR=/opt/uv/python \
    PATH=/opt/venv/bin:/opt/uv/bin:$PATH

RUN /opt/uv/bin/uv venv --python 3.12.12 /opt/venv \
    && chmod -R a+rX /opt \
    && uv pip install radian

# Node.js / npm / pnpm
# 公式の npm 不要のインストールスクリプトで 2025-10-30 時点の Active LTS = v24系をインストール
RUN wget -qO- https://raw.githubusercontent.com/tj/n/master/bin/n | bash -s install v24 \
    && npm install -g pnpm

# Microsoft Edit
RUN wget -O /tmp/msedit.tar.zst \
        https://github.com/microsoft/edit/releases/download/v1.2.0/edit-1.2.0-`uname -m`-linux-gnu.tar.zst \
    && cd /tmp \
    && tar -Izstd -xvf msedit.tar.zst \
    && mv edit /usr/local/bin/msedit \
    && rm msedit.tar.zst

# mokztk/RStudio_docker から流用した setup script
# 各スクリプトは改行コード LF(UNIX) でないとエラーになる
COPY my_scripts /my_scripts

RUN --mount=type=cache,target=/var/lib/apt,sharing=locked \
    --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/root/.cache/R,sharing=locked \
    chmod 775 my_scripts/* \
    && bash /my_scripts/install_r_packages_pak.sh \
    && bash /my_scripts/install_notojp.sh

# ユーザー設定
USER coder
RUN bash /my_scripts/user_settings.sh

WORKDIR /workspace

EXPOSE 8080 8088

ENV TZ=Asia/Tokyo \
    LANG=ja_JP.UTF-8 \
    LC_ALL=ja_JP.UTF-8

CMD ["code-server", "--auth", "none", "--bind-addr", "0.0.0.0:8080", "/workspace"]
