#!/bin/bash

set -e

source msg.sh

if [ ! -f "STAGE3_DONE.flag" ]
then
  msg "подчищаем ненужное"
  dnf -y autoremove

  msg s "centos8: очистка завершена. неплохо будет перезагрузиться и убедиться что всё точно ок."
  touch STAGE3_DONE.flag
fi
