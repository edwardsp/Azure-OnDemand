
import json
import sys

def create_image_config(config_fname, image_rg):

    with open(config_fname) as f:
        config = json.load(f)

    config["resource_group"] = image_rg

    rlist = []

    for r in config.get("resources", {}).keys():
        rlist.append(r)
        config["resources"][r]["type"] = "vm"
        config["resources"][r]["instances"] = 1
        config["resources"][r]["tags"].append("deprovision")

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
                r,
                f"variables.{r}_image_name",
                "variables.image_resource_group"
            ]
        })
    
    with open(config_fname[:-4]+"-image.json", "w") as f:
        json.dump(config, f, indent=4)

def create_deploy_config(config_fname, image_rg):

    with open(config_fname) as f:
        config = json.load(f)

    rlist = []

    for r in config.get("resources", {}).keys():
        config["resources"][r]["image"] = f"image.{image_rg}.{r}"

    config["install"] = [ step for step in config["install"] if not step["script"].startswith("image-") ]
    
    with open(config_fname[:-4]+"-deploy.json", "w") as f:
        json.dump(config, f, indent=4)


config_fname = sys.argv[1]
image_rg = sys.argv[2]

print(f"config={config_fname}")
print(f"image_rg={image_rg}")

create_image_config(config_fname, image_rg)
create_deploy_config(config_fname, image_rg)
