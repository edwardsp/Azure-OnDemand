#!/bin/bash

# install nodejs
curl -sL https://rpm.nodesource.com/setup_lts.x | bash -
yum install -y nodejs || exit 1

# install yarn
curl --silent --location https://dl.yarnpkg.com/rpm/yarn.repo | tee /etc/yum.repos.d/yarn.repo
rpm --import https://dl.yarnpkg.com/rpm/pubkey.gpg
yum -y install yarn || exit 1

# theia dependencies
yum groupinstall -y "Development Tools"
yum install -y git libX11-devel libxkbfile-devel || exit 1
