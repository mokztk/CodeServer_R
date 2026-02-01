FROM codercom/code-server:latest

USER root

# 1. 基本ツールと CRAN PPA のセットアップ
RUN apt-get update && apt-get install -y --no-install-recommends \
    software-properties-common dirmngr gnupg ca-certificates curl sudo fontconfig \
    fonts-noto-cjk fonts-firacode \
    && wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | tee /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc \
    && add-apt-repository "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/" \
    && apt-get update && apt-get install -y r-base r-base-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# 2. ユーザー coder を sudo 可能にする (pak のシステム依存解決用)
RUN echo "coder ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/nopasswd && chmod 0440 /etc/sudoers.d/nopasswd

# 3. Noto Sans JP のエイリアス設定
RUN mkdir -p /etc/fonts/local.conf && \
    echo '<?xml version="1.0"?><!DOCTYPE fontconfig SYSTEM "fonts.dtd"><fontconfig><match target="pattern"><test qual="any" name="family"><string>Noto Sans JP</string></test><edit name="family" mode="assign" binding="same"><string>Noto Sans CJK JP</string></edit></match></fontconfig>' > /etc/fonts/local.conf \
    && fc-cache -f -v

# 4. R システム設定 (PPM, pak, httpgd, ragg)
RUN echo 'options(repos = c(CRAN = "https://packagemanager.posit.co/cran/__linux__/$(lsb_release -cs)/latest"))' >> /etc/R/Rprofile.site \
    && echo 'options(HTTPUserAgent = sprintf("R/%s R (%s)", getRversion(), paste(getRversion(), R.version$platform, R.version$arch, R.version$os)))' >> /etc/R/Rprofile.site \
    && echo 'options(pak.sysreqs = TRUE, vsc.use_httpgd = TRUE, device = "httpgd", httpgd.host = "0.0.0.0", httpgd.port = 8081)' >> /etc/R/Rprofile.site \
    && echo 'options(ggplot2.utils.device = ragg::agg_png)' >> /etc/R/Rprofile.site

# 5. pak インストールと主要パッケージの導入 (ARMバイナリ利用)
RUN R -e "install.packages('pak', repos = sprintf('https://r-lib.github.io/p/pak/stable/%s/%s/%s', .Platform\$pkgType, R.version\$os, R.version\$arch))" \
    && R -e "pak::pkg_install(c('languageserver', 'tidyverse', 'httpgd', 'ragg', 'systemfonts', 'quarto', 'rmarkdown', 'knitr', 'jsonlite'))"

# 6. Quarto CLI のインストール (ARM64)
ARG QUARTO_VERSION=1.5.57
RUN curl -o quarto-arm64.tar.gz -L "https://github.com/quarto-dev/quarto-cli/releases/download/v${QUARTO_VERSION}/quarto-${QUARTO_VERSION}-linux-arm64.tar.gz" \
    && mkdir -p /opt/quarto && tar -zxvf quarto-arm64.tar.gz -C /opt/quarto --strip-components=1 \
    && ln -s /opt/quarto/bin/quarto /usr/local/bin/quarto && rm quarto-arm64.tar.gz

# 7. VS Code 拡張機能の導入
USER coder
RUN code-server --install-extension REditorSupport.r \
    && code-server --install-extension posit.air-vscode \
    && code-server --install-extension Google.geminicodeassist \
    && code-server --install-extension quarto.quarto

# Python3 と pip のインストール、および radian の導入
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3-pip \
    python3-setuptools \
    && apt-get clean \
    && pip3 install -U radian

WORKDIR /workspace
