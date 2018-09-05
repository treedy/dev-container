FROM ubuntu:bionic-20180821 AS base-vim

RUN apt-get update \
  && apt-get upgrade \
  && apt-get install -y man vim vim-doc vim-scripts # Install base vim \
  && apt-get autoremove && apt-get autoclean

FROM base-vim AS vim-with-vundle
RUN apt-get install -y \
    curl \
    git \
  && apt-get autoremove && apt-get autoclean

FROM vim-with-vundle AS ycm-deps
RUN apt-get install -y \
    build-essential \
    cmake \
    curl \
    git \
    golang \
    man \
    npm \
    openjdk-8-jdk-headless \
    python-dev \
    python3-dev \
  && apt-get autoremove && apt-get autoclean \
  && npm install -g typescript

FROM ycm-deps AS treedy-python-dev
RUN apt-get install -y \
    python3-pip \
  && apt-get autoremove && apt-get autoclean \
  && pip3 install virtualenvwrapper
WORKDIR /root

FROM treedy-python-dev AS gcloud-dev
# Install instructions at https://cloud.google.com/sdk/docs/#deb
RUN apt-get install -y lsb-release \
  && export CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)" \
  && echo "deb http://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" \
    >> /etc/apt/sources.list.d/google-cloud-sdk.list \
  && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg \
    | apt-key add - \
  && apt-get update && apt-get install -y google-cloud-sdk \
  && apt-get autoremove && apt-get autoclean

LABEL maintainer="Todd Reedy <todd.reedy+dev@gmail.com>"

# Use https://github.com/jeroenpeeters/docker-ssh for SSH terminal?
