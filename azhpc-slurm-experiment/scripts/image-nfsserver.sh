#!/bin/bash

# install packages
yum -y install epel-release
yum -y install nfs-utils nfs-utils-lib

# setup services
systemctl enable rpcbind
systemctl enable nfs-server
systemctl enable nfs-lock
systemctl enable nfs-idmap
systemctl enable nfs

systemctl start rpcbind
systemctl start nfs-server
systemctl start nfs-lock
systemctl start nfs-idmap
systemctl start nfs

# tune nfs
cores=$(grep processor /proc/cpuinfo | wc -l)
nfs_proc=$(($cores * 4))
replace="s/#RPCNFSDCOUNT=16/RPCNFSDCOUNT=$nfs_proc/g"
sed -i -e "$replace" /etc/sysconfig/nfs
grep RPCNFSDCOUNT /etc/sysconfig/nfs
