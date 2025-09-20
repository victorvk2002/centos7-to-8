#!/bin/bash

source msg.sh

if [ ! -f "STAGE3_DONE.flag" ]
then
  msg "удалить старые ядра"
  dnf remove -y --oldinstallonly --setopt installonly_limit=1
  rpm -qa | grep kernel

  msg "подтягиваем версии пакетов к ядру"
  dnf -y --releasever=8 --allowerasing --setopt=deltarpm=false distro-sync
  # будут ошибки зависимостей
  rpm -Va --nofiles --nodigest
  rpm --rebuilddb
  dnf clean all
  dnf makecache
  rpm -e dracut-network --nodeps
  dnf -y --releasever=8 --allowerasing --setopt=deltarpm=false distro-sync
  dnf remove -y sysvinit-tools-2.88-14.dsf.el7.x86_64 python36-rpmconf-1.1.7-1.el7.1.noarch
  dnf -y --releasever=8 --allowerasing --setopt=deltarpm=false distro-sync

  touch STAGE3_DONE.flag
fi
