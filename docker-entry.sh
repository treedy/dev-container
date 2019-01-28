#! /bin/bash
set +x

USR_NAME=$1
USR_ID=$2
USR_SHELL=${3:-"/usr/bin/zsh"}

useradd -u $USR_ID -s $USR_SHELL -m $USR_NAME # -k /root/new_user_skeleton
shopt -s dotglob
mv /root/new_user_skeleton/* /home/${USR_NAME}

chown -R ${USR_NAME}:${USR_NAME} /home/${USR_NAME}
su - ${USR_NAME}