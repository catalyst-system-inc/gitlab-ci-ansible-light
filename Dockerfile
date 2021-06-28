FROM debian:buster-slim

RUN apt update && \
    apt upgrade -y && \
    apt install -y --no-install-recommends python3 \
                                               python3-pip \
                                               git \
                                               curl \
                                               ssh \
                                               locales \
                                               sshpass && \
    rm -rf /var/lib/apt/lists/*

RUN /usr/bin/python3 -m pip install -U pip && \
    /usr/bin/python3 -m pip install setuptools && \
    /usr/bin/python3 -m pip install ansible==4.0.0 \
                                    ansible-lint==5.0.12

# テスト用
# RUN ansible --version
# RUN ansible-lint --version

# CIサーバーからsshの警告が出ないように設定を追加する
ADD ansible.cfg /etc/ansible/ansible.cfg

RUN cd /usr/local/src/ && \
    /usr/bin/curl -OL 'https://github.com/synchro-food/filelint/releases/download/v0.3.0/filelint_linux_amd64.tar.gz' && \
    tar xvf filelint_linux_amd64.tar.gz && \
    rm -rf filelint_linux_amd64.tar.gz && \
    cd filelint_linux_amd64 && \
    cp -p filelint /usr/local/bin/filelint

RUN mkdir /root/.ssh && \
    chmod 600 /root/.ssh

COPY config /root/.ssh/config

RUN chmod 600 /root/.ssh/config

RUN ln -s /usr/bin/python3 /usr/bin/python

RUN ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

RUN echo 'ja_JP.UTF-8 UTF-8' >> /etc/locale.gen &&\
    /usr/sbin/locale-gen

ENV LANG=ja_JP.utf8 LC_ALL=ja_JP.utf8

CMD ["/bin/bash"]
