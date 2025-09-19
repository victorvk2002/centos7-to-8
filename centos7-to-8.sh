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

if [ ! -f "PHASE2_DONE.flag" ]; then
  dnf install -y https://vault.centos.org/centos/8/BaseOS/x86_64/os/Packages/centos-linux-release-8.5-1.2111.el8.noarch.rpm
  dnf install -y https://vault.centos.org/centos/8/BaseOS/x86_64/os/Packages/centos-gpg-keys-8-3.el8.noarch.rpm
  dnf install -y https://vault.centos.org/centos/8/BaseOS/x86_64/os/Packages/centos-linux-repos-8-3.el8.noarch.rpm
  # epel
  dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
  dnf -y upgrade https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm

  # Repo
  cat > /etc/yum.repos.d/CentOS-Base.repo << EOF
# CentOS-Base.repo for CentOS 8 (EOL - using vault repositories)
#
# Note: After CentOS 8 EOL (Dec 2021), mirrorlist URLs are no longer available.
# Using vault.centos.org for archived repositories.

[baseos]
name=CentOS-8 - BaseOS
baseurl=http://vault.centos.org/8.5.2111/BaseOS/$basearch/os/
gpgcheck=1
enabled=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial

[appstream]
name=CentOS-8 - AppStream
baseurl=http://vault.centos.org/8.5.2111/AppStream/$basearch/os/
gpgcheck=1
enabled=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial

[extras]
name=CentOS-8 - Extras
baseurl=http://vault.centos.org/8.5.2111/extras/$basearch/os/
gpgcheck=1
enabled=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial

[powertools]
name=CentOS-8 - PowerTools
baseurl=http://vault.centos.org/8.5.2111/PowerTools/$basearch/os/
gpgcheck=1
enabled=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial

[centosplus]
name=CentOS-8 - Plus
baseurl=http://vault.centos.org/8.5.2111/centosplus/$basearch/os/
gpgcheck=1
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial
EOF

  dnf clean all
  rm -rf /var/cache/dnf/*
  rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial
  dnf makecache
  dnf repolist

  dnf update -y
  dnf upgrade -y

  touch PHASE2_DONE.flag
fi
