#!/bin/bash

export PATH=$PATH:/opt/anaconda/bin
conda init
conda config --set auto_activate_base true
ln -s /opt/anaconda/etc/profile.d/conda.sh /etc/profile.d/conda.sh
conda create -n tensorflow_env tensorflow jupyter
echo "Conda setup complete"
