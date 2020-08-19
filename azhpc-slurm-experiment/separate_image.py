
import json
import sys

def create_image_config(config_fname, image_rg):

    with open(config_fname) as f:
        config = json.load(f)

    rlist = []

    for r in list(config.get("resources", {}).keys()):
        res = config["resources"].pop(r)
        
        res["type"] = "vm"
        res["instances"] = 1
        res["tags"].append("deprovision")
        res.pop("public_ip", None)
        res.pop("managed_identity", None)
        res.pop("dns_name", None)
        res.pop("nsg_allow", None)
        res.pop("availability_set", None)
        res.pop("data_disks", None)

        config["resources"][f"master-{r}"] = res
        rlist.append(r)

    config["install"] = [ step for step in config["install"] if step["script"].startswith("image-") ]

    config["install"].append({
        "script": "deprovision.sh",
        "tag": "deprovision",
        "sudo": True
    })

    for r in rlist:
        config["install"].append({
            "type": "local_script",
            "script": "create_image.sh",
            "args": [
                "variables.resource_group",
                f"master-{r}",
                r,
                image_rg
            ]
        })
    
    config["install_from"] = "imagecreatorjb"
    config["resources"]["imagecreatorjb"] = {
        "type": "vm",
        "public_ip": "true",
        "nsg_allow": ["ssh"],
        "vm_type": "Standard_D4s_v3",
        "image": "OpenLogic:CentOS:7.7:latest",
        "subnet": "hpc"
    }
    
    with open(config_fname[:-5]+"-image.json", "w") as f:
        json.dump(config, f, indent=4)

def create_deploy_config(config_fname, image_rg):

    with open(config_fname) as f:
        config = json.load(f)

    rlist = []

    for r in config.get("resources", {}).keys():
        config["resources"][r]["image"] = f"image.{image_rg}.{r}"

    config["install"] = [ step for step in config["install"] if not step["script"].startswith("image-") ]
    
    with open(config_fname[:-5]+"-deploy.json", "w") as f:
        json.dump(config, f, indent=4)


config_fname = sys.argv[1]
image_rg = sys.argv[2]

print(f"config={config_fname}")
print(f"image_rg={image_rg}")

create_image_config(config_fname, image_rg)
create_deploy_config(config_fname, image_rg)
