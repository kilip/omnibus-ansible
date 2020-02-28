#!/bin/sh

if [ "$1" = "-v" ]; then
  ANSIBLE_VERSION="${2}"
fi

apt_install() {
  dpkg_check_lock && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    -o DPkg::Options::=--force-confold -o DPkg::Options::=--force-confdef "$@"
}

redhat_install() {
  yum -y install ca-certificate nss epel-release
  yum -y install ansible
}

ubuntu_install() {
  apt update
  apt install software-properties-common
  apt-add-repository --yes ppa:ansible/ansible
  apt install ansible
}

debian_install() {
  apt update
  apt install ansible
}

if [ "x$KITCHEN_LOG" = "xDEBUG" ] || [ "x$OMNIBUS_ANSIBLE_LOG" = "xDEBUG" ]; then
  export PS4='(${BASH_SOURCE}:${LINENO}): - [${SHLVL},${BASH_SUBSHELL},$?] $ '
  set -x
fi

if [ ! "$(which ansible-playbook)" ]; then
  if [ -f /etc/centos-release ] || [ -f /etc/redhat-release ] || [ -f /etc/oracle-release ] || [ -f /etc/system-release ]; then
    redhat_install
  elif grep -qi ubuntu /etc/lsb-release || grep -qi ubuntu /etc/os-release; then
    ubuntu_install
  elif [ -f /etc/debian_version ]; then
    debian_install
  fi
fi
