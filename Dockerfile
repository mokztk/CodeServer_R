# rocker/r-ver:4.1.3 に Radian + Code-server と頻用パッケージを追加する
#   CRAN snapshot: https://packagemanager.rstudio.com/cran/__linux__/focal/2022-04-21

FROM rocker/r-ver:4.1.3

# Ubuntuミラーサイトの設定
#RUN sed -i.bak -e 's%http://[^ ]\+%mirror://mirrors.ubuntu.com/mirrors.txt%g' /etc/apt/sources.list
RUN if [ `uname -m` = "x86_64" ]; then \
        sed -i.bak -e "s%http://[^ ]\+%http://ftp.udx.icscoe.jp/Linux/ubuntu/%g" /etc/apt/sources.list; \
    fi

# 日本語設定と必要なライブラリ（Rパッケージ用は別途スクリプト内で導入）
RUN set -x \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        language-pack-ja-base \
        ssh \
        libxt6 \
        patch \
    && /usr/sbin/update-locale LANG=ja_JP.UTF-8 LANGUAGE="ja_JP:ja" \
    && /bin/bash -c "source /etc/default/locale" \
    && ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# setup script
# 各スクリプトは改行コード LF(UNIX) でないとエラーになる
COPY my_scripts /my_scripts
RUN chmod 775 my_scripts/*

RUN /my_scripts/install_tidyverse.sh
RUN /my_scripts/install_r_packages.sh
RUN /my_scripts/install_radian.sh
RUN /my_scripts/install_codeserver.sh
RUN /my_scripts/install_fonts.sh

# non-root user を作成
# Ref: https://github.com/rocker-org/rocker-versioned2/blob/master/scripts/default_user.sh
ENV DEFAULT_USER=rserver
RUN useradd -s /bin/bash -m "$DEFAULT_USER" \
    && echo "${DEFAULT_USER}:${DEFAULT_USER}" | chpasswd \
    && addgroup "${DEFAULT_USER}" staff \
    && chown -R ${DEFAULT_USER}:${DEFAULT_USER} /home/${DEFAULT_USER}

USER ${DEFAULT_USER}
RUN /my_scripts/setup_codeserver.sh

# ${R_HOME}/etc/Renviron のタイムゾーン指定（Etc/UTC）を上書き
RUN echo "TZ=Asia/Tokyo" >> /home/${DEFAULT_USER}/.Renviron

ENV LANG=ja_JP.UTF-8 \
    LC_ALL=ja_JP.UTF-8 \
    TZ=Asia/Tokyo

EXPOSE 8080
EXPOSE 59531
CMD /usr/bin/code-server /home/${DEFAULT_USER}
