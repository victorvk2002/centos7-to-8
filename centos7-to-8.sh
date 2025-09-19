#!/bin/bash

if [ ! -f "PHASE1_DONE.flag" ]; then

  sed -i s/mirror.centos.org/vault.centos.org/g /etc/yum.repos.d/*.repo
  sed -i s/^#.*baseurl=http/baseurl=https/g /etc/yum.repos.d/*.repo
  sed -i s/^mirrorlist=http/#mirrorlist=https/g /etc/yum.repos.d/*.repo
  sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
  sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*

  echo "sslverify=false" >> /etc/yum.conf

  yum upgrade -y
  ----


  теперь у нас работает пакетный менеджер

  ----
  https://www.joe0.com/2020/04/09/how-to-easily-upgrade-from-centos-7-to-centos-8-1-x/
  ----

  yum upgrade -y
  yum update -y

  # epel
  # через метапакет
  yum install -y epel-release

  yum install -y yum-utils rpmconf mc

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
  uname -a

  touch PHASE1_DONE.flag
fi

if [ ! -f "PHASE2_DONE.flag" ]; then
  dnf install -y https://vault.centos.org/centos/8/BaseOS/x86_64/os/Packages/centos-linux-release-8.5-1.2111.el8.noarch.rpm
  dnf install -y https://vault.centos.org/centos/8/BaseOS/x86_64/os/Packages/centos-gpg-keys-8-3.el8.noarch.rpm
  dnf install -y https://vault.centos.org/centos/8/BaseOS/x86_64/os/Packages/centos-linux-repos-8-3.el8.noarch.rpm
  # epel
  dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
  dnf -y upgrade https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm

  # Repo
  cat > /etc/yum.repos.d/centos-vault.repo << 'EOF'
[BaseOS]
name=CentOS-8 - Base
baseurl=http://vault.centos.org/centos/8/BaseOS/x86_64/os/
enabled=1
gpgcheck=0

[AppStream]
name=CentOS-8 - AppStream
baseurl=http://vault.centos.org/centos/8/AppStream/x86_64/os/
enabled=1
gpgcheck=0

[extras]
name=CentOS-8 - Extras
baseurl=http://vault.centos.org/centos/8/extras/x86_64/os/
enabled=1
gpgcheck=0
EOF

  dnf clean all
  rm -rf /var/cache/dnf/*
  rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial

  dnf clean all
  dnf makecache
  dnf update --best --allowerasing
  dnf repolist

  dnf upgrade -y


  rpm -e `rpm -q kernel`
  rpm -e --nodeps sysvinit-tools

  dnf -y --releasever=8 --allowerasing --setopt=deltarpm=false distro-sync
  dnf -y install kernel-core
  dnf -y groupupdate "Core" "Minimal Install"

  cat /etc/os-release

  touch PHASE2_DONE.flag
fi
