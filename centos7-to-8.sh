#!/bin/bash

source msg.sh

if [ ! -f "STAGE2_DONE.flag" ]
then
  dnf install -y https://vault.centos.org/centos/8/BaseOS/x86_64/os/Packages/{centos-linux-release-8.5-1.2111.el8.noarch.rpm,centos-gpg-keys-8-3.el8.noarch.rpm,centos-linux-repos-8-3.el8.noarch.rpm}
  dnf upgrade -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm

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

  dnf repolist
  dnf clean all
  dnf makecache
  dnf install -y https://vault.centos.org/8.5.2111/BaseOS/x86_64/os/Packages/kernel-core-4.18.0-348.7.1.el8_5.x86_64.rpm
  dnf install -y http://vault.centos.org/8.5.2111/BaseOS/x86_64/os/Packages/kernel-4.18.0-348.7.1.el8_5.x86_64.rpm
  dnf install -y http://vault.centos.org/8.5.2111/BaseOS/x86_64/os/Packages/kernel-tools-4.18.0-348.7.1.el8_5.x86_64.rpm
  dnf install -y https://vault.centos.org/8.5.2111/BaseOS/x86_64/os/Packages/kernel-modules-4.18.0-348.7.1.el8_5.x86_64.rpm

  #dnf install -y --allowerasing kernel-core kernel-modules


  rpm -qa | grep kernel
  dracut --kver 4.18.0-348.7.1.el8_5.x86_64 --force
  #dracut --regenerate-all --force
  grub2-mkconfig -o /boot/grub2/grub.cfg



  rpm -e --nodeps kernel-3.*
  rpm -qa | grep kernel
  dnf distro-sync -y


  dnf upgrade -y --allowerasing  --best

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
