FROM ubuntu:bionic-20181112 AS base-utils

# Set shell environments
ENV DEBIAN_FRONTEND=noninteractive
ENV EDITOR=vim
ENV SHELL=zsh
ENV HOME=/root

#Install dependencies
RUN apt-get update \
  && apt-get upgrade --no-install-recommends -y -q \
  && apt-get install --no-install-recommends -y -q \
    apt-utils \
    build-essential \
    ca-certificates \
    cmake \
    curl \
    git \
    golang \
    gnupg \
    lsb-release \
    man \
    npm \
    openjdk-8-jdk-headless \
    python-dev \
    python3-dev \
    python3-pip \
    tmux \
    vim-nox \
    vim-doc \
    vim-scripts \
    zsh \
  && apt-get autoremove && apt-get autoclean \
  && npm install -g typescript \
  && pip3 install virtualenvwrapper

# Install Google Cloud SDK (gcloud, gsutil, etc.)
# Install instructions at https://cloud.google.com/sdk/docs/#deb
RUN export CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)" \
  && echo "deb http://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" \
    >> /etc/apt/sources.list.d/google-cloud-sdk.list \
  && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg \
    | apt-key add - \
  && apt-get update && apt-get install -y google-cloud-sdk \
  && apt-get autoremove && apt-get autoclean

# Install oh-my-zsh
RUN sh -c \
  "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" \
  || true

# Add dot files here
COPY vimrc ${HOME}/.vimrc
COPY plugins.vimrc ${HOME}/.vim/plugins.vimrc
COPY tmux.conf ${HOME}/.tmux.conf
COPY zshrc ${HOME}/.zshrc

# Configure vim plugins
RUN mkdir -p ${HOME}/.vim/bundle \
  && git clone https://github.com/VundleVim/Vundle.vim.git \
    ${HOME}/.vim/bundle/Vundle.vim
RUN vim -E -u NONE -S ${HOME}/.vim/plugins.vimrc +PluginInstall +qa

