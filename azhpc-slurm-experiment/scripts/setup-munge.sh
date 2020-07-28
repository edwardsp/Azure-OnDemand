#!/bin/bash

MUNGEKEY=$1

echo ${MUNGEKEY} > /etc/munge/munge.key
chown munge /etc/munge/munge.key
chmod 600 /etc/munge/munge.key
systemctl enable munge
systemctl start munge

