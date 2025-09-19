#!/bin/bash

stage() {
    local msg="$1"
    local width=60
    local border="─"

    # цветовые коды (можно убрать, если не нужно)
    local COLOR_BLUE="\e[34m"
    local COLOR_RESET="\e[0m"
    local COLOR_BOLD="\e[1m"

    # рамка сверху
    printf "\n${COLOR_BLUE}┌%*s┐${COLOR_RESET}\n" $width | tr ' ' "$border"
    # текст по центру
    printf "${COLOR_BLUE}│${COLOR_RESET} ${COLOR_BOLD}%-*s${COLOR_RESET}${COLOR_BLUE}│${COLOR_RESET}\n" $((width-2)) "$msg"
    # рамка снизу
    printf "${COLOR_BLUE}└%*s┘${COLOR_RESET}\n\n" $width | tr ' ' "$border"
}

stage 'STAGE 1'

if [ ! -f "STAGE1_DONE.flag" ]
then
  stage 'Локаль'
  export LANG=en_US.UTF-8
  export LC_ALL=en_US.UTF-8
  export PYTHONIOENCODING=UTF-8
  localedef -i en_US -f ISO-8859-1 en_US
  localedef -i en_US -f UTF-8 en_US.UTF-8
  locale -a | grep -E "(en_US|ru_RU)"
  echo 'export LANG=en_US.UTF-8' >> /etc/profile
  echo 'export LC_ALL=en_US.UTF-8' >> /etc/profile
  source /etc/profile
  locale

  stage 'замена резозитариев'
  sed -i s/mirror.centos.org/vault.centos.org/g /etc/yum.repos.d/*.repo
  sed -i s/^#.*baseurl=http/baseurl=https/g /etc/yum.repos.d/*.repo
  sed -i s/^mirrorlist=http/#mirrorlist=https/g /etc/yum.repos.d/*.repo
  sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
  sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*

  echo "sslverify=false" >> /etc/yum.conf

  stage 'обновление пакетов'
  yum upgrade -y
  
  stage 'установка epel через метапакет'
  yum install -y epel-release

  stage 'установка дополнительных пакетов'
  yum install -y yum-utils rpmconf mc

  stage 'очистка старых пакетов'
  rpmconf -a

  for pkg in $(package-cleanup --leaves -q)
  do
    yum remove -y $pkg
  done

  for pkg in $(package-cleanup --orphans -q)
  do
    yum remove -y $pkg
  done

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

  touch STAGE1_DONE.flag
fi

stage 'STAGE 2'

if [ ! -f "STAGE2_DONE.flag" ]
then
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

  touch STAGE2_DONE.flag
fi
