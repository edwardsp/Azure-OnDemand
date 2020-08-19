# Azure-OnDemand

Open OnDemand running on Azure

## Getting Started

These instructions will create a running setup of OOD using slurm and auto-scaling.  Features include:

* Slurm Cluster
* Interactive Desktop
* Jupyter
* Theia

The autoscale will install a complete VM and can take some time for all the package dependencies (expect 10 mins for interactive/desktop).

Clone the azurehpc repository and setup the environment:

    git clone https://github.com/Azure/azurehpc.git
    source azurehpc/install.sh

Check out this repository

    git clone https://github.com/edwardsp/Azure-OnDemand.git

Initialise a project from the feature-test example:

    password=SET-TOP-SECRET-PASSWORD
    resource_group=${USER}-azure-ondemand
    azhpc-init \
        -c Azure-OnDemand/azod-slurm \
        -d slurm-azure-ondemand \
        --vars ood_password="$password",resource_group=$resource_group

This will create a new project in the `ood` directory that is ready to deploy.  Run the following to build (although feel free to adjust any of the variables in your config.json for you own setup, e.g. max instances, vm type, location etc):

    cd slurm-azure-ondemand
    azhpc-build

Once built you can access the ood VM in the browser.

> Note: to get the FQDN you can just run `azhpc-connect ood` and it will be output to the screen.

Browse to the OOD portal with the FQDN, logon with user `hpcuser` and the password defined above

> Note: to connect to the grafana monitoring page, use `admin` as a user and the password defined above

### Build with images

To speed up node provisioning custom images can be built as part of the installation and used by SLURM. To do this, run the same init command as above, but the build is now split in two steps :

    python3 separate_image.py config.json $resource_group

> Note: the resource group needs to be the same here as the managed identity needs to access the image

This will split the config into `config-image.json` and `config-deploy.json`.  First create the images:

    azhpc-build -c config-image.json

Now, you must copy the `config-deploy.json` over the `config.json` this is the config file copied onto the `ood` VM to do the autoscale.

    cp config-deploy.json config.json

Finally, deploy AzureHPC OnDemand:

    azhpc-build

> Note: you can delete the `imagecreatorjb` VM and associated resources.  This is not cleared up from the image building step.
