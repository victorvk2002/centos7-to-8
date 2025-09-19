#!/bin/bash

# msg <LEVEL> <MESSAGE>
msg() {
  RESET=$(tput sgr0)
  WIDTH=100

  COLOR_INFO=$(tput setaf 6)   # cyan
  COLOR_WARN=$(tput setaf 3)   # yellow
  COLOR_ERROR=$(tput setaf 1)   # red
  COLOR_SUCCESS=$(tput setaf 2)   # green
  COLOR_DEBUG=$(tput setaf 5)   # magenta

  if [[ $2 != "" ]]
  then
    local level=$1
    shift
  fi
  local msg="$*"

  # Выбираем цвет по уровню
  local color=$COLOR_INFO  # по умолчанию
  case "$level" in
    info|i)    color=$COLOR_INFO;level=info       ;;
    warn|w)    color=$COLOR_WARN;level=warn       ;;
    error|e)   color=$COLOR_ERROR;level=error     ;;
    success|s) color=$COLOR_SUCCESS;level=success ;;
    debug|d)   color=$COLOR_DEBUG;level=debug     ;;
    *)         color=$COLOR_INFO;level=info       ;;
  esac

  local ts=$(date '+%Y-%m-%d %H:%M:%S')
  local prefix="[${ts}] ${level^^}"

  body="| $prefix $msg"
  len=$(($WIDTH - ${#body}))
  closer="$(printf '%0.s ' $(seq $len))|"
  printf "%b%-30s%b %s%b\n" "$color" "+$(printf '%0.s-' $(seq $WIDTH))+"
  printf "%b%-30s%b %s%b\n" "$color" "$body" "$color" "$closer" "$RESET"
  printf "%b%-30s%b %s%b\n" "$color" "+$(printf '%0.s-' $(seq $WIDTH))+"
}


if [ ! -f "STAGE1_DONE.flag" ]
then
  msg 'Локаль'
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

  msg 'замена резозитариев'
  sed -i s/mirror.centos.org/vault.centos.org/g /etc/yum.repos.d/*.repo
  sed -i s/^#.*baseurl=http/baseurl=https/g /etc/yum.repos.d/*.repo
  sed -i s/^mirrorlist=http/#mirrorlist=https/g /etc/yum.repos.d/*.repo
  sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
  sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*

  echo "sslverify=false" >> /etc/yum.conf

  msg 'обновление пакетов'
  yum upgrade -y
  
  msg 'установка epel через метапакет'
  yum install -y epel-release

  msg 'установка дополнительных пакетов'
  yum install -y yum-utils rpmconf mc nano

  msg 'очистка старых пакетов'
  rpmconf -a

  for pkg in $(package-cleanup --leaves -q)
  do
    yum remove -y $pkg
  done

  for pkg in $(package-cleanup --orphans -q)
  do
    yum remove -y $pkg
  done

  msg 'замена yam на dnf'
  yum install -y dnf
  dnf -y remove yum yum-metadata-parser
  rm -Rf /etc/yum
  dnf upgrade -y

  cat /etc/os-release
  uname -a

  touch STAGE1_DONE.flag
fi

if [ ! -f "STAGE2_DONE.flag" ]
then
  # dnf install -y https://vault.centos.org/centos/8/BaseOS/x86_64/os/Packages/centos-linux-release-8.5-1.2111.el8.noarch.rpm
  # dnf install -y https://vault.centos.org/centos/8/BaseOS/x86_64/os/Packages/centos-gpg-keys-8-3.el8.noarch.rpm
  # dnf install -y https://vault.centos.org/centos/8/BaseOS/x86_64/os/Packages/centos-linux-repos-8-3.el8.noarch.rpm
  # # epel
  # dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
  # dnf -y upgrade https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm

  rm -rf /etc/yum.repos.d/CentOS*
  rm -rf /etc/yum.repos.d/epel*

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
  dnf makecache
  dnf update -y --best --allowerasing
  dnf repolist
  dnf upgrade -y 1>>error.log 2>>error.log

  for pkg in $(cat error.txt | awk -F"from package" '{print $2 }' | uniq)
  do
    rpm -e --nodeps $pkg
  done

  rm -f /var/lib/rpm/__db*
  rpm --rebuilddb
  dnf distro-sync -y --allowerasing
  rpm --rebuilddb
  dnf clean packages

  dnf install -y epel-release

  dnf makecache
  dnf upgrade -y

  # rpm -e `rpm -q kernel`
  # rpm -e --nodeps sysvinit-tools

  dnf -y --releasever=8 --allowerasing --setopt=deltarpm=false distro-sync
  dnf -y install kernel-core
  dnf -y groupupdate "Core" "Minimal Install"

  cat /etc/os-release
  uname -a
  ls -lhF /boot

  touch STAGE2_DONE.flag
fi
