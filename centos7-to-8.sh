#!/bin/bash

if [ ! -f "PHASE1_DONE.flag" ]; then

  sed -i s/mirror.centos.org/vault.centos.org/g /etc/yum.repos.d/*.repo
  sed -i s/^#.*baseurl=http/baseurl=https/g /etc/yum.repos.d/*.repo
  sed -i s/^mirrorlist=http/#mirrorlist=https/g /etc/yum.repos.d/*.repo
  sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
  sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*

  echo "sslverify=false" >> /etc/yum.conf

  yum update -y
  yum upgrade -y

  yum install -y epel-release
  yum install -y yum-utils rpmconf kernel mc

  export LANG=en_US.UTF-8
  export LC_ALL=en_US.UTF-8
  export PYTHONIOENCODING=UTF-8
  locale


  rpmconf -a
  package-cleanup --leaves
  package-cleanup --orphans

  yum install -y dnf
  dnf -y remove yum yum-metadata-parser
  rm -Rf /etc/yum
  dnf upgrade -y
  dnf install -y NetworkManager

  systemctl enable NetworkManager
  systemctl start NetworkManager
  systemctl status NetworkManager

  cat /etc/os-release
  rpm -q kernel

  touch PHASE1_DONE.flag
fi
