#!/bin/bash

export PATH=$PATH:/opt/anaconda/bin
conda init
conda config --set auto_activate_base true
ln -s /opt/anaconda/etc/profile.d/conda.sh /etc/profile.d/conda.sh
conda create -n tensorflow_env tensorflow tensorflow-gpu jupyter pip numpy pillow matplotlib
echo "Conda setup complete"
