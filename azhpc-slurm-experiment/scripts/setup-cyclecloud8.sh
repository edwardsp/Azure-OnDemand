#!/bin/bash

set -x
set -e

RESOURCE_GROUP=$1
if [ -z "${RESOURCE_GROUP}" ]; then
    echo "CycleCloud installation requires a Resource Group for compute clusters." >&2
    exit -1
fi

LOCATION=$2
if [ -z "${LOCATION}" ]; then
    echo "CycleCloud installation requires a Location (region) for compute clusters." >&2
    exit -1
fi

STORAGE_ACCOUNT_NAME=$3
if [ -z "${STORAGE_ACCOUNT_NAME}" ]; then
    echo "CycleCloud installation requires a Storage Account for configuration data." >&2
    exit -1
fi

INITIAL_USER_NAME=$4
if [ -z "${INITIAL_USER_NAME}" ]; then
    echo "CycleCloud installation requires an initial user name." >&2
    exit -1
fi

INITIAL_USER_PASSWORD=$5
if [ -z "${INITIAL_USER_PASSWORD}" ]; then
    # Use randomized passsword 
    INITIAL_USER_PASSWORD=$( tr -cd '[:alnum:]' < /dev/urandom | fold -w16 | head -n1 )
fi

INITIAL_USER_PUBKEY_FILE=$6
if [ -z "${INITIAL_USER_PUBKEY_FILE}" ]; then
    if [ -f "~${INITIAL_USER_NAME}/.ssh/id_rsa.pub" ]; then
        INITIAL_USER_PUBKEY=$( cat "~${INITIAL_USER_NAME}/.ssh/id_rsa.pub" )
    fi
else
    INITIAL_USER_PUBKEY=$( cat "${INITIAL_USER_PUBKEY_FILE}" )
fi

AZURE_CLOUD="public"  # [china|germany|public|usgov]
SUBSCRIPTION_ID=$( curl -H Metadata:true --noproxy "*" "http://169.254.169.254/metadata/instance/compute/subscriptionId?api-version=2019-06-01&format=text" )

# Currently port 80 and 443 are reserved for OoD
CYCLECLOUD_HTTP_PORT=8080
CYCLECLOUD_HTTPS_PORT=8443
iptables -I INPUT -p tcp -m tcp --dport ${CYCLECLOUD_HTTPS_PORT} -j ACCEPT
iptables-save > /etc/sysconfig/iptables

CS_ROOT=/opt/cycle_server
$CS_ROOT/cycle_server stop

# Update properties
sed -i 's/webServerMaxHeapSize\=2048M/webServerMaxHeapSize\=4096M/' $CS_ROOT/config/cycle_server.properties
sed -i "s/webServerPort\=8080/webServerPort\=${CYCLECLOUD_HTTP_PORT}/" $CS_ROOT/config/cycle_server.properties
sed -i "s/webServerSslPort\=8443/webServerSslPort\=${CYCLECLOUD_HTTPS_PORT}/" $CS_ROOT/config/cycle_server.properties
sed -i 's/webServerEnableHttps\=false/webServerEnableHttps=true/' $CS_ROOT/config/cycle_server.properties

ls -l $CS_ROOT/components

# Setup the azure storage share for logs and backups
if [ -d "$BACKUPS_DIRECTORY" ]; then
  mv $CS_ROOT/logs $BACKUPS_DIRECTORY/
  ln -s $BACKUPS_DIRECTORY/logs $CS_ROOT/
  chown cycle_server:cycle_server $CS_ROOT/logs
  mv $CS_ROOT/data/backups $BACKUPS_DIRECTORY/ || true
  mkdir $BACKUPS_DIRECTORY/backups || true
  ln -s $BACKUPS_DIRECTORY/backups $CS_ROOT/data/
  chown cycle_server:cycle_server $CS_ROOT/data/backups
fi

cat <<EOF > /tmp/initial_data.json
[
    {
        "AdType": "Application.Setting",
        "Name": "cycleserver.installation.complete",
        "Value": true
    },
    {
        "AdType": "Application.Setting",
        "Name": "cycleserver.installation.initial_user",
        "Value": "${INITIAL_USER_NAME}"
    },
    {
        "AdType": "AuthenticatedUser",
        "Name": "${INITIAL_USER_NAME}",
        "RawPassword": "${INITIAL_USER_PASSWORD}",
        "Superuser": true
    }
]
EOF
mv /tmp/initial_data.json $CS_ROOT/config/data/ 

if [ ! -z "${INITIAL_USER_PUBKEY}" ]; then
    cat <<EOF > /tmp/initial_user_cred.json
[
    {
        "PublicKey": "${INITIAL_USER_PUBKEY}",
        "AdType": "Credential",
        "CredentialType": "PublicKey",
        "Name": "${INITIAL_USER_NAME}/${INITIAL_USER_NAME}-publickey"
    }
]
EOF
    mv /tmp/initial_user_cred.json $CS_ROOT/config/data/ 
fi


$CS_ROOT/cycle_server start --wait

# If public FQDN provided, we can use LetsEncrypt
# TODO: we should figure out  a way to use letsEncrypt alongside OoD
#if  [ ! -z "${FQDN}" ] ; then
#  ${CS_ROOT}/cycle_server keystore automatic --accept-terms ${FQDN} 
#fi

# Configure the CLI for root as the initial user
/usr/bin/sleep 5
sudo /usr/local/bin/cyclecloud initialize --batch --url="https://localhost:${CYCLECLOUD_HTTPS_PORT}" --verify-ssl="false" \
                                     --username="${INITIAL_USER_NAME}" --password="${INITIAL_USER_PASSWORD}"

# Configure the initial subscription
cat <<EOF > /tmp/azure_data.json
{
    "Environment": "$AZURE_CLOUD",
    "AzureRMUseManagedIdentity": true,
    "AzureResourceGroup": "${RESOURCE_GROUP}",
    "AzureRMSubscriptionId": "${SUBSCRIPTION_ID}",
    "DefaultAccount": true,
    "Location": "${LOCATION}",
    "Name": "azure",
    "Provider": "azure",
    "ProviderId": "${SUBSCRIPTION_ID}",
    "RMStorageAccount": "${STORAGE_ACCOUNT_NAME}",
    "RMStorageContainer": "cyclecloud"
}
EOF

if /usr/local/bin/cyclecloud account show azure | grep -q 'Credentials: azure'; then
    echo "Account \"azure\" already exists.   Skipping account setup..."
else
    sudo /usr/local/bin/cyclecloud account create -f /tmp/azure_data.json
fi

echo 'Azure CycleCloud Installation Complete'
