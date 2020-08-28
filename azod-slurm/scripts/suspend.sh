#!/bin/bash

NODES=$1

AZLOG=$(uuidgen)

echo "$(date) # begin suspend # $NODES # $AZLOG" >> /var/log/slurm/autoscale.log

az login --identity

source /apps/slurm/azurehpc/install.sh

cd /apps/slurm/azscale
azhpc slurm_suspend --no-color "$NODES" >> /var/log/slurm/suspend_${AZLOG}.log 2>&1

echo "$(date) # end suspend # $NODES # $AZLOG" >> /var/log/slurm/autoscale.log

