
import json
import sys

config_fname = sys.argv[1]
image_rg = sys.argv[2]

print(f"config={config_fname}")
print(f"image_rg={image_rg}")

with open(config_fname) as f:
    config = json.load(f)

rlist = []

for r in config.get("resources", {}).keys():
    rlist.append(r)
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
    
print(json.dumps(config, indent=4))
