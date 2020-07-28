# install nodejs
curl -sL https://rpm.nodesource.com/setup_10.x | bash -
yum install -y nodejs

# install yarn
curl --silent --location https://dl.yarnpkg.com/rpm/yarn.repo | tee /etc/yum.repos.d/yarn.repo
rpm --import https://dl.yarnpkg.com/rpm/pubkey.gpg
yum -y install yarn

# theia dependencies
yum groupinstall -y "Development Tools"
yum install -y git libX11-devel libxkbfile-devel
