#! /bin/bash

ACTION=$1
USR=$2
ARCHIVE=$3

backup() {
  tar acvf $ARCHIVE /home/$USR
}

restore() {
  cd / ; tar axvf $ARCHIVE
}

$ACTION

