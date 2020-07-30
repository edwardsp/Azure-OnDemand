#!/bin/bash

# Add the cluster creation icon (for convenience)
sudo /usr/local/bin/cyclecloud import_template Slurm-Headless -c slurm -f scripts/cyclecloud-slurm-headless.txt --force

RESOURCE_GROUP=$1
LOCATION=$2
VNET_NAME=$3
SUBNET_NAME=$4
MAX_HPC_VM_COUNT=$5
HPC_IMAGE_ID=$6
HPC_MACHINE_TYPE=$7

NFS_SERVER=$8
NFS_EXPORT=${9-/share}
if [ -z "$NFS_SERVER" ]; then
    echo "The NFS server address is required"
    exit 1
fi

# Account name currently hard-coded in setup-cyclecloud8.sh
CC_ACCOUNT=azure
SLURM_VERSION="19.05.5-1"
#SUBNET_ID="/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RESOURCE_GROUP}/providers/Microsoft.Network/virtualNetworks/${VNET_NAME}/subnets/${SUBNET_NAME}"

cat <<EOF > scripts/azurehpcood-slurm.json
{
  "Credentials" : "${CC_ACCOUNT}",
  "Autoscale" : true,
  "SubnetId" : "${RESOURCE_GROUP}/${VNET_NAME}/${SUBNET_NAME}",
  "slurm" : null,
  "NFSAddress" : "${NFS_SERVER}",
  "NFSExport" : "${NFS_EXPORT}",
  "Region" : "${LOCATION}",
  "MaxHPCExecuteCount" : ${MAX_HPC_VM_COUNT},
  "HPCImageName" : "${HPC_IMAGE_ID}",
  "HPCClusterInitSpecs" : null,
  "configuration_slurm_version" : "${SLURM_VERSION}",
  "HPCMachineType" : "${HPC_MACHINE_TYPE}",
  "HPCMaxScalesetSize" : 100
}
EOF

sudo /usr/local/bin/cyclecloud import_cluster azurehpcood-slurm -c slurm -f scripts/cyclecloud-slurm-headless.txt -p scripts/azurehpcood-slurm.json --force
sudo /usr/local/bin/cyclecloud start_cluster azurehpcood-slurm

# Cyclecloud's Slurm cluster expects the munge key to be at /sched/munge/munge.key
# (We'll mount /sched at /share/apps)
mkdir -p /apps/munge/
chmod 700 /apps/munge/
cp -a /etc/munge/munge.key /apps/munge/