#!/bin/bash

export SLURMUSER=900
groupadd -g $SLURMUSER slurm
useradd  -m -c "SLURM workload manager" -d /var/lib/slurm -u $SLURMUSER -g slurm  -s /bin/bash slurm

mkdir -p /var/spool/slurm
chown slurm /var/spool/slurm
mkdir -p /var/log/slurm
chown slurm /var/log/slurm

ln -s /apps/slurm/slurm.conf /etc/slurm/slurm.conf
ln -s /apps/slurm/cgroup.conf /etc/slurm/cgroup.conf

systemctl enable slurmd
systemctl start slurmd

exit 0
