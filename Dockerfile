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


# Helper scripts
ARG DEVSHELL_TOOLS
ENV DEVSHELL_TOOLS ${DEVSHELL_TOOLS:-/opt/devshell}
WORKDIR $DEVSHELL_TOOLS
COPY first-run.sh .
COPY docker-entry.sh .

# Add dot files here
ENV DEVSHELL_SKEL new_user_skeleton
COPY vimrc ${DEVSHELL_SKEL}/.vimrc
COPY plugins.vimrc ${DEVSHELL_SKEL}/.vim/plugins.vimrc
COPY tmux.conf ${DEVSHELL_SKEL}/.tmux.conf
COPY zshrc ${DEVSHELL_SKEL}/.zshrc

VOLUME ["/home"]

ENTRYPOINT [ "./docker-entry.sh" ]

