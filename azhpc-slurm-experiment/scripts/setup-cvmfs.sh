#!/bin/bash

cvmfs_config setup
curl https://cvmfs.blob.core.windows.net/demo/public_keys/demo.azure.pub -o /etc/cvmfs/keys/demo.azure.pub
curl https://cvmfs.blob.core.windows.net/demo/public_keys/demo.azure.conf -o /etc/cvmfs/config.d/demo.azure.conf

