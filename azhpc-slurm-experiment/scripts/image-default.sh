#!/bin/bash

# Disable requiretty to allow run sudo within scripts
sed -i -e 's/Defaults    requiretty.*/ #Defaults    requiretty/g' /etc/sudoers

# disable selinux
setenforce 0
sed -i 's/SELINUX=.*$/SELINUX=disabled/g' /etc/selinux/config

# install packages
yum -y install epel-release
yum -y install git jq htop screen wget



