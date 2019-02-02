#! /bin/bash
set +x

USR_NAME=$1
USR_ID=$2
USR_SHELL=${3:-"/usr/bin/zsh"}

FORCE_FIRST_RUN=false

if ! [ -d "/home/${USR_NAME}" ] ; then
  useradd -u $USR_ID -s $USR_SHELL -m $USR_NAME
  shopt -s dotglob
  cp -R /root/new_user_skeleton/* /home/${USR_NAME}
  chown -R ${USR_NAME}:${USR_NAME} /home/${USR_NAME}
  mkdir -p /root/${USR_NAME}/etc
  cp /etc/{passwd,shadow} /root/${USR_NAME}/etc/
  FORCE_FIRST_RUN=true
fi

cp /root/${USR_NAME}/etc/* /etc/
if $FORCE_FIRST_RUN ; then
  su - $USR_NAME -c ./first-run.sh
else
  su - $USR_NAME
fi 
