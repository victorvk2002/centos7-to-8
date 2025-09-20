#!/bin/bash

set -e

source msg.sh

if [ ! -f "STAGE2_DONE.flag" ]
then
  msg "centos7: установка репозитариев centos8"
  wget https://vault.centos.org/centos/8/BaseOS/x86_64/os/Packages/centos-linux-release-8.5-1.2111.el8.noarch.rpm
  wget https://vault.centos.org/centos/8/BaseOS/x86_64/os/Packages/centos-gpg-keys-8-3.el8.noarch.rpm
  wget https://vault.centos.org/centos/8/BaseOS/x86_64/os/Packages/centos-linux-repos-8-3.el8.noarch.rpm
  
  dnf install -y centos-linux-release-8.5-1.2111.el8.noarch.rpm centos-gpg-keys-8-3.el8.noarch.rpm centos-linux-repos-8-3.el8.noarch.rpm
  
  msg "centos7: установка ядра centos8"
  wget http://vault.centos.org/8.5.2111/BaseOS/x86_64/os/Packages/linux-firmware-20210702-103.gitd79c2677.el8.noarch.rpm
  wget  http://vault.centos.org/8.5.2111/BaseOS/x86_64/os/Packages/kernel-core-4.18.0-348.7.1.el8_5.x86_64.rpm
  wget http://vault.centos.org/8.5.2111/BaseOS/x86_64/os/Packages/kernel-4.18.0-348.7.1.el8_5.x86_64.rpm
  wget http://vault.centos.org/8.5.2111/BaseOS/x86_64/os/Packages/kernel-modules-4.18.0-348.7.1.el8_5.x86_64.rpm
  wget http://vault.centos.org/8.5.2111/BaseOS/x86_64/os/Packages/kernel-tools-libs-4.18.0-348.7.1.el8_5.x86_64.rpm
  
  dnf install -y --allowerasing linux-firmware-20210702-103.gitd79c2677.el8.noarch.rpm kernel-4.18.0-348.7.1.el8_5.x86_64.rpm kernel-core-4.18.0-348.7.1.el8_5.x86_64.rpm kernel-modules-4.18.0-348.7.1.el8_5.x86_64.rpm kernel-tools-libs-4.18.0-348.7.1.el8_5.x86_64.rpm

  msg "centos7: фикс ошибки сборки ядра centos8"
  # появится ошибка Symvers dump file /boot/symvers-4.18.0-348.7.1.el8_5.x86_64.gz not found
  cp /lib/modules/4.18.0-348.7.1.el8_5.x86_64/symvers.gz /boot/symvers-4.18.0-348.7.1.el8_5.x86_64.gz
  dnf reinstall -y http://vault.centos.org/8.5.2111/BaseOS/x86_64/os/Packages/kernel-core-4.18.0-348.7.1.el8_5.x86_64.rpm
  ls -lhF /boot | grep --color "4.18.0-348.7.1.el8_5.x86_64"

  msg "centos7: подключение epel-8"
  dnf upgrade -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm

  msg "centos7: обновление grub"
  rpm -qa | grep --color kernel
  dracut --kver 4.18.0-348.7.1.el8_5.x86_64 --force
  grub2-mkconfig -o /boot/grub2/grub.cfg

  cat /etc/os-release
  uname -a
  
  msg s "centos7: сборка ядра centos8 завершена. требуется перезагрузка"
  touch STAGE2_DONE.flag
fi
