# Azure-OnDemand

Open OnDemand running on Azure


## Getting Started

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