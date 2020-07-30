#!/bin/bash

mount_point=${1-/share}

# Shares
NFS_MOUNT_POINT=$mount_point
NFS_APPS=$NFS_MOUNT_POINT/apps
NFS_DATA=$NFS_MOUNT_POINT/data
NFS_HOME=$NFS_MOUNT_POINT/home
NFS_SCRATCH=/mnt/resource/scratch

mkdir -p $NFS_MOUNT_POINT
mkdir -p $NFS_APPS
mkdir -p $NFS_DATA
mkdir -p $NFS_HOME
mkdir -p $NFS_SCRATCH
chmod 777 $NFS_MOUNT_POINT
chmod 777 $NFS_APPS
chmod 777 $NFS_DATA
chmod 777 $NFS_HOME
chmod 777 $NFS_SCRATCH

ln -s $NFS_SCRATCH /scratch
ln -s /share/apps /apps
ln -s /share/data /data

echo "$NFS_MOUNT_POINT *(rw,sync,no_root_squash)" >> /etc/exports
echo "$NFS_APPS        *(rw,sync,no_root_squash)" >> /etc/exports
echo "$NFS_DATA        *(rw,sync,no_root_squash)" >> /etc/exports
echo "$NFS_HOME        *(rw,sync,no_root_squash)" >> /etc/exports
echo "$NFS_SCRATCH     *(rw,sync,no_root_squash)" >> /etc/exports

systemctl restart nfs-server

