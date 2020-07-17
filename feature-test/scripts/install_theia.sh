#!/bin/bash

apps_dir=/apps

git clone https://github.com/eclipse-theia/theia.git

pushd theia

cp -r examples/browser examples/azure-ondemand
sed -i sed 's/example-browser/azure-ondemand/g;s/Theia Browser Example/Azure OnDemand Theia IDE/g;s/^.*api-sample.*$//g' examples/azure-ondemand/package.json

yarn

pushd examples/azure-ondemand
yarn build
popd

cat <<EOF >launch.sh
#!/bin/bash

port=\$1
workspace=\$2

cd $apps_dir/theia/examples/azure-ondemand
export THEIA_DEFAULT_PLUGINS=local-dir:$apps_dir/theia/plugins
yarn run start --hostname \$HOSTNAME --port \$port "\$workspace"
EOF
chmod +x launch.sh

popd

sudo mv theia /apps/.
