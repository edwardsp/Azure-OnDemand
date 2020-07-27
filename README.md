# Azure-OnDemand

Open OnDemand running on Azure

## Getting Started

These instructions will create a running setup of OOD using slurm and auto-scaling.  Features include:

* PBS Cluster
* Interactive Desktop (not accelerated)
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
    azhpc-init \
        -c Azure-OnDemand/azhpc-slurm \
        -d slurm-azure-ondemand \
        --vars ood_password="$password",resource_group=${USER}-azure-ondemand

This will create a new project in the `ood` directory that is ready to deploy.  Run the following to build (although feel free to adjust any of the variables in your config.json for you own setup, e.g. max instances, vm type, location etc):

    cd slurm-azure-ondemand
    azhpc-build

Once built you can access the ood VM in the browser on port 80.

> Note: to get the FQDN you can just run `azhpc-connect ood` and it will be output to the screen.

Browse to the OOD portal with the FQDN, logon with user `hpcuser` and the password defined above

### Build with images
To speed up node provisioning custom images can be built as part of the installation and used by SLURM. To do this, run the same init command as above, but the build is now split in two steps :

```
 $ azhpc-build -c ood.json
 $ azhpc-build --no-vnet -c create_images.json
```

There will be 3 images created into the resource group specified in the init command above.

## Feature-test example

Note: development is working with the azhpc-slurm example

These instructions will create a running setup of the feature test set-up.  Features include:

* PBS Cluster
* Interactive Desktop (not accelerated)
* Jupyter
* Theia

Clone the azurehpc repository and setup the environment:
 

    git clone https://github.com/Azure/azurehpc.git
    source azurehpc/install.sh

Check out this repository

    git clone https://github.com/edwardsp/Azure-OnDemand.git

Initialise a project from the feature-test example:

    password=SET-TOP-SECRET-PASSWORD
    azhpc-init \
        -c Azure-OnDemand/feature-test \
        -d ood \
        --vars resource_group=${USER}-ood,vm_type=Standard_HB60rs,ood_password="$password",location=westeurope

This will create a new project in the `ood` directory that is ready to deploy.

Build

    cd ood
    azhpc-build

Once built you can access the ood VM in the browser on port 80.
