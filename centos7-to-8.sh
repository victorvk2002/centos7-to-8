#!/bin/bash

set -e

source msg.sh

if [ ! -f "STAGE2_DONE.flag" ]
then
  msg "Подключаем репозитории CentOS 8 + EPEL"
  wget https://vault.centos.org/8.5.2111/BaseOS/x86_64/os/Packages/centos-linux-release-8.5-1.2111.el8.noarch.rpm
  wget https://vault.centos.org/8.5.2111/BaseOS/x86_64/os/Packages/centos-gpg-keys-8-3.el8.noarch.rpm
  wget https://vault.centos.org/8.5.2111/BaseOS/x86_64/os/Packages/centos-linux-repos-8-3.el8.noarch.rpm

  dnf install -y \
      centos-linux-release-8.5-1.2111.el8.noarch.rpm \
      centos-gpg-keys-8-3.el8.noarch.rpm \
      centos-linux-repos-8-3.el8.noarch.rpm

  dnf upgrade -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm

  msg "Правим репозитории на vault.centos.org"
  sed -i 's|^mirrorlist=|#mirrorlist=|g' /etc/yum.repos.d/*.repo
  sed -i 's|^#baseurl=http://mirror.centos.org|baseurl=https://vault.centos.org|g' /etc/yum.repos.d/*.repo
  sed -i 's|^baseurl=http://mirror.centos.org|baseurl=https://vault.centos.org|g' /etc/yum.repos.d/*.repo
  grep --color -vE "^#|^$" /etc/yum.repos.d/*.repo
  
  msg "Чистим пакеты CentOS7"
  dnf -y remove sysvinit-tools || true
  dnf -y remove dracut-network || true
  dnf -y remove python36-rpmconf || true

  msg "Distro-sync"
  dnf -y --releasever=8 --allowerasing --setopt=deltarpm=false distro-sync

  msg "Ставим ядро и минимальные группы"
  dnf -y install kernel-core
  dnf -y groupupdate "Core" "Minimal Install"

  msg "Обновление завершено. Требуется перезагрузка."
  touch STAGE2_DONE.flag
fi
