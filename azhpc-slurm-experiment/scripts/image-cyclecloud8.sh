#!/bin/bash

rpm --import https://packages.microsoft.com/keys/microsoft.asc

# Install the product
sh -c 'echo -e "[cyclecloud]
name=cyclecloud
baseurl=https://packages.microsoft.com/yumrepos/cyclecloud
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/cyclecloud.repo'
yum -y update
yum install -y cyclecloud8

# Install the CLI
cd /tmp
unzip /opt/cycle_server/tools/cyclecloud-cli.zip
cd /tmp/cyclecloud-cli-installer
/tmp/cyclecloud-cli-installer/install.sh --system
rm -rf /tmp/cyclecloud-cli-installer

