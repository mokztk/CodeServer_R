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
        fonts-noto-cjk \
    && /usr/sbin/update-locale LANG=ja_JP.UTF-8 LANGUAGE="ja_JP:ja" \
    && /bin/bash -c "source /etc/default/locale" \
    && ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime \
    && apt-get clean \
    && mkdir -p /etc/R

# code-server
RUN curl -fsSL https://code-server.dev/install.sh | sh

# uv (Python manager)
COPY --from=ghcr.io/astral-sh/uv:0.9.8 /uv /uvx /opt/uv/bin/

# Quarto CLI
# rocker/rstudio:4.5.1 と同じバージョンを指定して、rocker公式のインストールスクリプトで導入
# wget, ca-certicifates は導入済みのため apt の処理はスキップ（行番号は @07c155e 準拠）

ENV PANDOC_VERSION="3.8.2.1" \
    QUARTO_VERSION="1.7.32"

RUN --mount=type=cache,target=/var/lib/apt,sharing=locked \
    --mount=type=cache,target=/var/cache/apt,sharing=locked \
    sed -e "16,26d" /rocker_scripts/install_pandoc.sh | bash \
    && sed -e "21,31d" /rocker_scripts/install_quarto.sh | bash

# pak + R packages (sysreqs handled by pak)
RUN --mount=type=cache,target=/var/lib/apt,sharing=locked \
    --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/root/.cache/R,sharing=locked \
    --mount=type=cache,target=/tmp,sharing=locked \
    Rscript -e "install.packages('pak')" \
    && Rscript -e "pak::pkg_install(c( \
        'languageserver', \
        'tidyverse', \
        'nx10/httpgd@dd6ed3a' \
        ))"

# radian
RUN /opt/uv/bin/uv venv --python 3.12.12 /opt/venv \
    && export PATH=/opt/venv/bin:/opt/uv/bin:$PATH \
    && uv pip install radian

# coder user (passwordless sudo)
RUN useradd -m -s /bin/bash coder \
 && echo "coder ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/coder \
 && chmod 0440 /etc/sudoers.d/coder

# VS Code extensions & config
USER coder
RUN code-server --install-extension REditorSupport.r \
    && code-server --install-extension posit.air-vscode \
    && code-server --install-extension Google.geminicodeassist \
    && code-server --install-extension quarto.quarto \
    && mkdir -p /home/coder/.config/code-server \
    && touch /home/coder/.local/share/code-server/User/settings.json \
    && echo 'options(device = "httpgd", httpgd.host = "0.0.0.0", httpgd.port = 8088, httpgd.token = "")' > /home/coder/.Rprofile

# R user library
RUN Rscript -e 'dir.create(Sys.getenv("R_LIBS_USER"), recursive = TRUE)' \
    && echo '.libPaths(c(Sys.getenv("R_LIBS_USER"), .Library.site, .Library))' >> /home/coder/.Rprofile

WORKDIR /workspace

EXPOSE 8080 8088

ENV TZ=Asia/Tokyo \
    LANG=ja_JP.UTF-8 \
    LC_ALL=ja_JP.UTF-8 \
    PATH=/opt/venv/bin:/opt/uv/bin:$PATH

CMD ["code-server", "--auth", "none", "--bind-addr", "0.0.0.0:8080", "/workspace"]
