#!/bin/bash

NODES=$1

AZLOG=$(uuidgen)

echo "$(date) # begin resume # $NODES # $AZLOG" >> /var/log/slurm/autoscale.log

cd /var/lib/slurm

az login --identity -o table

source /apps/slurm/azurehpc/install.sh

cd /apps/slurm/azscale
azhpc slurm_resume --no-color "$NODES" >> /var/log/slurm/resume_${AZLOG}.log 2>&1

resource_group=$(azhpc-get resource_group | tr ' ' '\n' | tail -n 1)

for host in $(scontrol show hostnames $NODES)
do
   NODEIP=$(az vm list-ip-addresses -g $resource_group -n $host | jq -r '.[].virtualMachine.network.privateIpAddresses[0]')
   scontrol update nodename=$host nodeaddr=$NODEIP
done

echo "$(date) # end resume # $NODES # $AZLOG" >> /var/log/slurm/autoscale.log
