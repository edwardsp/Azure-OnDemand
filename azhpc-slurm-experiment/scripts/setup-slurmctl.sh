#!/bin/bash
AZHPC_CONFIG=${1-config.json}
export SLURMUSER=900
groupadd -g $SLURMUSER slurm
useradd  -m -c "SLURM workload manager" -d /var/lib/slurm -u $SLURMUSER -g slurm  -s /bin/bash slurm
mkdir -p /var/spool/slurm
chown slurm /var/spool/slurm
mkdir -p /var/log/slurm
chown slurm /var/log/slurm

SLURM_SHARE=/apps/slurm
SLURM_CONF=$SLURM_SHARE/slurm.conf
mkdir -p $SLURM_SHARE
cp /etc/slurm/slurm.conf.example $SLURM_CONF
ln -s $SLURM_CONF /etc/slurm/slurm.conf
sed -i "s/ControlMachine=.*/ControlMachine=`hostname -s`/g" $SLURM_CONF
sed -i "s/SlurmctldLogFile=.*/SlurmctldLogFile=\/var\/log\/slurm\/slurmctld.log/" $SLURM_CONF
sed -i "s/NodeName=linux.*/include \/apps\/slurm\/nodes.conf/g" $SLURM_CONF
echo "# NODES" > $SLURM_SHARE/nodes.conf
sed -i "s/PartitionName=debug.*/include \/apps\/slurm\/partition.conf/g" $SLURM_CONF
echo "#PARTITIONS" > $SLURM_SHARE/partition.conf

cat <<EOF >> /etc/slurm/slurm.conf

# POWER SAVE SUPPORT FOR IDLE NODES (optional)
SuspendProgram=/apps/slurm/scripts/suspend.sh
ResumeProgram=/apps/slurm/scripts/resume.sh
ResumeFailProgram=/apps/slurm/scripts/suspend.sh
SuspendTimeout=1200
ResumeTimeout=600
ResumeRate=0
#SuspendExcNodes=
#SuspendExcParts=
SuspendRate=0
SuspendTime=1800
SchedulerParameters=salloc_wait_nodes
SlurmctldParameters=cloud_dns,idle_on_node_suspend
CommunicationParameters=NoAddrCache
DebugFlags=PowerSave
PrivateData=cloud

EOF

mkdir -p $SLURM_SHARE/scripts
chown slurm $SLURM_SHARE/scripts

cp scripts/suspend.sh $SLURM_SHARE/scripts/
cp scripts/resume.sh $SLURM_SHARE/scripts/

chmod +x $SLURM_SHARE/scripts/*.sh
ls -alh $SLURM_SHARE/scripts

mkdir -p $SLURM_SHARE/azscale/scripts
cp scripts/$AZHPC_CONFIG $SLURM_SHARE/azscale/config.json
cp scripts/*_id_rsa* $SLURM_SHARE/azscale
chmod 600 $SLURM_SHARE/azscale/*_id_rsa
chmod 644 $SLURM_SHARE/azscale/*_id_rsa.pub
cp -r scripts $SLURM_SHARE/azscale/.
pushd $SLURM_SHARE
git clone https://github.com/Azure/azurehpc.git
popd
chown slurm.slurm -R $SLURM_SHARE

systemctl enable slurmctld

exit 0
