#!/bin/bash

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

  for pkg in $(package-cleanup --leaves -q)
  do
    yum remove -y $pkg
  done

  for pkg in $(package-cleanup --orphans -q)
  do
    yum remove -y $pkg
  done

  msg 'centos7: замена yam на dnf'
  yum install -y dnf
  dnf -y remove yum yum-metadata-parser
  rm -Rf /etc/yum
  dnf upgrade -y

  cat /etc/os-release
  uname -a
  ls -lhF /boot

  touch STAGE1_DONE.flag
fi
