#!/bin/bash

set -e

source msg.sh

if [ ! -f "STAGE3_DONE.flag" ]
then
  msg "подчищаем ненужное"
  dnf -y autoremove

  msg s "centos8: очистка завершена."
  touch STAGE3_DONE.flag
fi
