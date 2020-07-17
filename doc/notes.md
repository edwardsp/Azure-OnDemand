
[root@ood bc_desktop]# cat /etc/ood/config/clusters.d/pbscluster.yml 
---
v2:
  metadata:
    title: "PBS Cluster"
  login:
    host: "headnode"
  job:
    adapter: "pbspro"
    host: "headnode"
    exec: "/opt/pbs"
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


Add lines to /etc/ood/config/ood_portal.yml:

    host_regex: '[^/]+'
    node_uri: '/node'
    rnode_uri: '/rnode'


Update:

    sudo /opt/ood/ood-portal-generator/sbin/update_ood_portal


/etc/ood/config/apps/bc_desktop

[root@ood bc_desktop]# cat pbscluster.yml 
---
title: "PBS Cluster"
cluster: "pbscluster"
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

[root@ood bc_desktop]# cat submit/my_submit.yml.erb 
---
script:
  native:
    - "-l"
    - "select=1:ncpus=30"
    - "-N"
    - "foo"