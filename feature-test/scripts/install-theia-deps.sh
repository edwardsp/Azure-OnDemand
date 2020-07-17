# install nodejs
curl -sL https://rpm.nodesource.com/setup_10.x | sudo bash -
sudo yum install -y nodejs

# install yarn
curl --silent --location https://dl.yarnpkg.com/rpm/yarn.repo | sudo tee /etc/yum.repos.d/yarn.repo
sudo rpm --import https://dl.yarnpkg.com/rpm/pubkey.gpg
sudo yum -y install yarn

# theia dependencies
sudo yum groupinstall -y "Development Tools"
sudo yum install -y git libX11-devel libxkbfile-devel

git clone https://github.com/eclipse-theia/theia
sudo mv theia /opt
cd /opt/theia
yarn

cat <<EOF >launch.sh
#!/bin/bash

port=$1
workspace=$2

cd /opt/theia/examples/browser
yarn run start --port $port "$workspace"
EOF
chmod +x launch.sh

