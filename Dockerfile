FROM ubuntu:bionic-20190122

# Set shell environments
ENV DEBIAN_FRONTEND=noninteractive
ENV EDITOR=vim

#Install dependencies
RUN apt-get update -q \
  && apt-get upgrade --no-install-recommends -y -q \
  && apt-get install --no-install-recommends -y -q \
    apt-utils \
    build-essential \
    ca-certificates \
    cmake \
    curl \
    flake8 \
    git \
    golang \
    gnupg \
    less \
    lsb-release \
    man \
    maven \
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

WORKDIR /root

# Add dot files here
COPY vimrc .vimrc
COPY plugins.vimrc .vim/plugins.vimrc
COPY tmux.conf .tmux.conf
COPY zshrc zshrc

# Change over to the real user
RUN chown -R $USR:$USR /home/$USR
USER $USR

# Install oh-my-zsh
RUN sh -c \
  "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" \
  || mv .zshrc .zshrc.orig && mv zshrc .zshrc


# Configure vim plugins
RUN mkdir -p .vim/bundle \
  && git clone https://github.com/VundleVim/Vundle.vim.git \
    .vim/bundle/Vundle.vim
RUN vim -E -u NONE -S .vim/plugins.vimrc +PluginInstall +qa
RUN mkdir new_user_skeleton \
  && cp -R .oh* .vim* .tmux.conf .zshrc new_user_skeleton/

COPY docker-entry.sh .

VOLUME ["/root", "/home"]

ENTRYPOINT ["/root/docker-entry.sh"]
