#!/bin/bash

set -e

source msg.sh

if [ ! -f "STAGE2_DONE.flag" ]
then
  msg "подключаем репозитории centos8 + epal"
  wget https://vault.centos.org/centos/8/BaseOS/x86_64/os/Packages/centos-linux-release-8.5-1.2111.el8.noarch.rpm
  wget https://vault.centos.org/centos/8/BaseOS/x86_64/os/Packages/centos-gpg-keys-8-3.el8.noarch.rpm
  wget https://vault.centos.org/centos/8/BaseOS/x86_64/os/Packages/centos-linux-repos-8-3.el8.noarch.rpm
  
  dnf install -y centos-linux-release-8.5-1.2111.el8.noarch.rpm centos-gpg-keys-8-3.el8.noarch.rpm centos-linux-repos-8-3.el8.noarch.rpm
  dnf upgrade -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm

  msg "cснова поправляем съехавшие репозитарии"
  grep --color -r "mirror" /etc/yum.repos.d/
  sed -i s/mirror.centos.org/vault.centos.org/g /etc/yum.repos.d/*.repo
  sed -i s/^#.*baseurl=http/baseurl=https/g /etc/yum.repos.d/*.repo
  sed -i s/^mirrorlist=http/#mirrorlist=https/g /etc/yum.repos.d/*.repo
  sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
  sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*

  msg "чистим мусор"
  rpm -e --nodeps sysvinit-tools
  rpm -e `rpm -q kernel`
  
  dnf -y remove dracut-network
  dnf -y remove python36-rpmconf-1.1.7-1.el7.1.noarch

  msg "distro-sync"
  dnf --releasever=8 --allowerasing --setopt=deltarpm=false distro-sync

  msg "ставим ядро"
  dnf -y install kernel-core
  dnf -y groupupdate "Core" "Minimal Install"
  
  msg s "сборка ядра centos8 завершена. требуется перезагрузка"
  touch STAGE2_DONE.flag
fi
