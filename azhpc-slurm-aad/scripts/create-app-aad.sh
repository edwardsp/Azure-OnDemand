#!/bin/bash

fqdn=$1
password=$2

cat <<EOF >manifest.json
[{
"resourceAppId": "00000003-0000-0000-c000-000000000000",
"resourceAccess": [
	{
		"id": "37f7f235-527c-4136-accd-4a02d197296e",
		"type": "Scope"
	}
]
}]
EOF

appid=`az ad app create --display-name ondemand-20200727-02 --reply-urls https://${fqdn}/oidc --credential-description "ood" --key-type Password --password "12345654321abcdefg##" --required-resource-accesses @manifest.json | jq -r .appId`

echo $appid
