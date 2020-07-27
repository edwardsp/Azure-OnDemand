#!/bin/bash

wget https://repo.anaconda.com/archive/Anaconda3-2020.02-Linux-x86_64.sh -O /opt/anacondainstaller.sh
bash /opt/anacondainstaller.sh -b -p /opt/anaconda
export PATH=$PATH:/opt/anaconda/bin
conda init
conda config --set auto_activate_base true
ln -s /opt/anaconda/etc/profile.d/conda.sh /etc/profile.d/conda.sh
conda create -n tensorflow_env tensorflow jupyter
echo "Conda setup complete"


