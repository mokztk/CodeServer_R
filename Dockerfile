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

# code-server
RUN curl -fsSL https://code-server.dev/install.sh | sh

# uv (Python manager) + radian
COPY --from=ghcr.io/astral-sh/uv:0.9.6 /uv /uvx /bin/
RUN uv python install 3.12 \
    && uv tool install radian

# Quarto CLI
RUN --mount=type=cache,target=/var/lib/apt,sharing=locked \
    --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/root/.cache/R,sharing=locked \
    --mount=type=cache,target=/tmp,sharing=locked \
    curl -fsSL https://quarto.org/download/latest/quarto-linux-amd64.deb \
        -o /tmp/quarto.deb \
    && apt-get update \
    && apt-get install -y /tmp/quarto.deb \
    && rm /tmp/quarto.deb

# pak + R packages (sysreqs handled by pak)
RUN --mount=type=cache,target=/var/lib/apt,sharing=locked \
    --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/root/.cache/R,sharing=locked \
    --mount=type=cache,target=/tmp,sharing=locked \
    Rscript -e "install.packages('pak')" \
    && Rscript -e "pak::pkg_install(c( \
        'languageserver', \
        'tidyverse', \
        'nx10/httpgd' \
        ))"

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
    && printf '%s\n' \
        'bind-addr: 0.0.0.0:8080' \
        'auth: none' \
        'cert: false' \
        > /home/coder/.config/code-server/config.yaml


WORKDIR /workspace

EXPOSE 8080 4190

CMD ["code-server"]
