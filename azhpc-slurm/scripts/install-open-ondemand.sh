#!/bin/bash

username=$1
password=$2

yum -y install centos-release-scl
yum -y install https://yum.osc.edu/ondemand/1.7/ondemand-release-web-1.7-1.noarch.rpm
yum -y install ondemand

iptables -I INPUT -p tcp -m tcp --dport 80 -j ACCEPT
iptables -I INPUT -p tcp -m tcp --dport 443 -j ACCEPT
iptables-save > /etc/sysconfig/iptables

systemctl start httpd24-httpd

scl enable ondemand -- htpasswd -b -c /opt/rh/httpd24/root/etc/httpd/.htpasswd $username $password

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
  custom:
    grafana:
      host: "http://monitor:3000"
        orgId: 1
          dashboard:
            name: "telegraf-system-dashboard"
            uid: "000000127"
            panels:
              cpu: 8
              memory: 16
          labels:
            cluster: "cluster"
            host: "host"
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

### <iframe src="http://localhost:8080/d-solo/000000127/telegraf-system-dashboard?orgId=1&refresh=10s&var-datasource=azhpc&var-inter=10s&var-ncores=8&var-server=All&var-mountpoint=All&var-cpu=All&var-disk=All&var-netif=All&from=1595852523820&to=1595856123820&panelId=28239" width="450" height="200" frameborder="0"></iframe>


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
script:
  native:
    - "--cpus-per-task=4"
    - "--partition=interactive"
EOF

# change the branding
# and fix the qsub issue (https://osc.github.io/ood-documentation/release-1.7/release-notes/v1.7-release-notes.html#support-sanitizing-job-names)
cat <<EOF >>/etc/ood/config/nginx_stage.yml

pun_custom_env:
  OOD_DASHBOARD_TITLE: "Azure OnDemand"
  OOD_BRAND_BG_COLOR: "#53565a"
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
rm -rf Azure-OnDemand

systemctl try-restart httpd24-httpd.service httpd24-htcacheclean.service

echo 'OnDemand Installation Complete'
