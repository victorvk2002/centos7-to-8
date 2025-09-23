#!/bin/bash

set -e

source msg.sh

if [ ! -f "STAGE1_DONE.flag" ]
then
  msg 'centos7: замена резозитариев'
  sed -i s/mirror.centos.org/vault.centos.org/g /etc/yum.repos.d/*.repo
  sed -i s/^#.*baseurl=http/baseurl=https/g /etc/yum.repos.d/*.repo
  sed -i s/^mirrorlist=http/#mirrorlist=https/g /etc/yum.repos.d/*.repo
  sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
  sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*

  echo "sslverify=false" >> /etc/yum.conf

  msg ' centos7: обновление пакетов'
  yum upgrade -y
  
  msg 'centos7: установка epel через метапакет'
  yum install -y epel-release

  msg 'centos7: установка дополнительных пакетов'
  yum install -y yum-utils rpmconf mc nano wget

  msg 'centos7: очистка старых пакетов'
  rpmconf -a

  package-cleanup --orphans

  # возможно это ломет дальнейший переход
  # for pkg in $(package-cleanup --leaves -q)
  # do
  #   yum remove -y $pkg
  # done

  yum autoremove
  
  cat /etc/os-release
  uname -a
  ls -lhF /boot

  msg s "centos7 обновлён до последней версии. требуется ребут"
  touch STAGE1_DONE.flag
fi
