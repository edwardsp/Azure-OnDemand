#!/bin/bash
username=$1
password=$2
monitoring_server=$3

iptables -I INPUT -p tcp -m tcp --dport 80 -j ACCEPT
iptables -I INPUT -p tcp -m tcp --dport 443 -j ACCEPT
iptables-save > /etc/sysconfig/iptables

systemctl start httpd24-httpd

#systemctl start ondemand-dex

# enable basic auth
cat <<EOF >/etc/ood/config/ood_portal.yml 
auth:
  - 'AuthType Basic'
  - 'AuthName "private"'
  - 'AuthUserFile "/opt/rh/httpd24/root/etc/httpd/.htpasswd"'
  - 'RequestHeader unset Authorization'
  - 'Require valid-user'
EOF
scl enable ondemand -- htpasswd -b -c /opt/rh/httpd24/root/etc/httpd/.htpasswd $username $password

## add self signed https certificate
#cat <<EOF >>/etc/ood/config/ood_portal.yml
#ssl:
#  - 'SSLCertificateFile "/etc/pki/tls/certs/localhost.crt"'
#  - 'SSLCertificateKeyFile "/etc/pki/tls/private/localhost.key"'
#EOF

# add cluster
mkdir -p /etc/ood/config/clusters.d

cat <<EOF >/etc/ood/config/clusters.d/slurmcluster.yml
v2:
  metadata:
    title: "Slurm Cluster"
  login:
    host: "ood"
  job:
    adapter: "slurm"
    host: "ood"
    exec: "/usr/bin"
  batch_connect:
    basic:
      script_wrapper: |
        module purge
        %s
    vnc:
      script_wrapper: |
        module purge
        export PATH="/opt/TurboVNC/bin:$PATH"
        export WEBSOCKIFY_CMD="/usr/bin/websockify"
        %s
EOF

# reverse proxy (https://osc.github.io/ood-documentation/release-1.7/app-development/interactive/setup/enable-reverse-proxy.html)
cat <<EOF >>/etc/ood/config/ood_portal.yml

host_regex: '[^./]+'
node_uri: '/node'
rnode_uri: '/rnode'
EOF
sudo /opt/ood/ood-portal-generator/sbin/update_ood_portal

# submit desktop session
mkdir -p /etc/ood/config/apps/bc_desktop
cat <<EOF >/etc/ood/config/apps/bc_desktop/viz.yml 
---
title: "Desktop"
cluster: "slurmcluster"
form:
  - desktop
  - bc_num_hours
attributes:
  bc_num_hours:
    value: 1
  bc_job_name:
    value: "test"
  desktop: "xfce"
submit: "submit/my_submit.yml.erb"
EOF
# custom script
mkdir -p /etc/ood/config/apps/bc_desktop/submit
cat <<EOF >/etc/ood/config/apps/bc_desktop/submit/my_submit.yml.erb
---
script:
  native:
    - "--cpus-per-task=15"
    - "--partition=viz"
EOF

# submit 3d desktop session
cat <<EOF >/etc/ood/config/apps/bc_desktop/viz3d.yml
---
title: "3D Desktop"
cluster: "slurmcluster"
form:
  - desktop
  - bc_num_hours
attributes:
  bc_num_hours:
    value: 1
  bc_job_name:
    value: "test"
  desktop: "xfce"
submit: "submit/my_submit3d.yml.erb"
EOF
# custom script
cat <<EOF >/etc/ood/config/apps/bc_desktop/submit/my_submit3d.yml.erb
---
script:
  native:
    - "--cpus-per-task=6"
    - "--partition=viz3d"
EOF

# add jupyter app

mkdir -p /var/www/ood/apps/sys/jupyter 

pushd /var/www/ood/apps/sys/jupyter
git clone https://github.com/OSC/bc_example_jupyter.git
cp -r bc_example_jupyter/* .
SRC="c.NotebookApp.ip = '\*'"
DST="c.NotebookApp.ip = '0.0.0.0'"
sed -i "s/$SRC/$DST/g" template/before.sh.erb
rm -rf bc_example_jupyter
popd

cat <<EOF >/var/www/ood/apps/sys/jupyter/form.yml
---
cluster: "slurmcluster"
attributes:
  modules: "python"
  bc_num_hours:
    value: 1
  bc_job_name:
    value: "test"
form:
  - modules
  - extra_jupyter_args
  - bc_num_hours
EOF

# custom script
cat <<EOF >/var/www/ood/apps/sys/jupyter/submit.yml.erb
---
batch_connect:
  template: "basic"
  extra_jupyter_args: ""
  modules: ""
script:
  native:
    - "--cpus-per-task=4"
    - "--partition=interactive"
EOF

cat <<EOF >/var/www/ood/apps/sys/jupyter/template/script.sh.erb
#!/usr/bin/env bash

# Benchmark info
echo "TIMING - Starting main script at: \$(date)"

# Set working directory to home directory
cd "\${HOME}"

#
# Start Jupyter Notebook Server
#

<%- unless context.modules.blank? -%>
# Purge the module environment to avoid conflicts
module purge

# Load the require modules
#module load <%= context.modules %>

# List loaded modules
module list
<%- end -%>

conda init
source ~/.bashrc

conda activate tensorflow_env

pip install jupyter-tensorboard

# Benchmark info
echo "TIMING - Starting jupyter at: \$(date)"

# Launch the Jupyter Notebook Server
set -x
jupyter notebook --config="\${CONFIG_FILE}" <%= context.extra_jupyter_args %>
EOF

# change the branding
# and fix the qsub issue (https://osc.github.io/ood-documentation/release-1.7/release-notes/v1.7-release-notes.html#support-sanitizing-job-names)
cat <<EOF >>/etc/ood/config/nginx_stage.yml

pun_custom_env:
  OOD_DASHBOARD_TITLE: "AzureHPC OnDemand"
  OOD_DASHBOARD_LOGO: "/public/logo.png"
  OOD_BRAND_BG_COLOR: "#0078d4"
  OOD_BRAND_LINK_ACTIVE_BG_COLOR: "#fff"
  OOD_JOB_NAME_ILLEGAL_CHARS: "/"
EOF


git clone https://github.com/edwardsp/Azure-OnDemand.git
mv Azure-OnDemand/apps/theia /var/www/ood/apps/sys/.
cat <<EOF >/var/www/ood/apps/sys/theia/form.yml
---
cluster: "slurmcluster"
form:
  - bc_account
  - bc_num_hours
  - working_dir
attributes:
  working_dir:
    label: "Working Directory"
    data-filepicker: true
    data-target-file-type: dirs  # Valid values are: files, dirs, or both
    readonly: false
    help: "Select your project directory; defaults to $HOME"
EOF
cat <<EOF >/var/www/ood/apps/sys/theia/submit.yml.erb
---
batch_connect:
  template: "basic"
script:
  native:
    - "--cpus-per-task=2"
    - "--partition=interactive"
EOF

# Stage web resources for OOD UI customization
rsync -avuz Azure-OnDemand/ood/web/ /var/www/ood/public/

# Add the monitoring URL in the dashboard using the OOD proxy syntax
monitoring_url="http://${monitoring_server}/rnode/$(hostname)/3000/login"
sed -i "s|MONITORING_URI|$monitoring_url|g" Azure-OnDemand/ood/dashboard.yml

cp Azure-OnDemand/ood/dashboard.yml /var/www/ood/apps/sys/dashboard/config/locales/en.yml

rm -rf Azure-OnDemand

systemctl try-restart httpd24-httpd.service httpd24-htcacheclean.service

echo 'OnDemand Installation Complete'
