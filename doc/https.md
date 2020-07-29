# Generating the certificate


Get `getssl`:

    curl --silent https://raw.githubusercontent.com/srvrco/getssl/master/getssl > getssl
    chmod 700 getssl

To use ACME we need to allow `.well-known/acme-challenge`:

    cp /etc/ood/config/ood_portal.yml /etc/ood/config/ood_portal_orig.yml
    cat <<EOF >>/etc/ood/config/ood_portal.yml
    public_uri: '/.well-known'
    public_root: '/var/www/ood/.well-known'
    EOF
    /opt/ood/ood-portal-generator/sbin/update_ood_portal
    sudo systemctl try-restart httpd24-httpd.service httpd24-htcacheclean.service

Generate the certificate

    DOMAIN=azurehpc-ondemand.westeurope.cloudapp.azure.com

    ./getssl -c $DOMAIN

    cat <<EOF > ${HOME}/.getssl/${DOMAIN}/getssl.cfg 
    CA="https://acme-v02.api.letsencrypt.org"
    SANS=""
    ACL=('/var/www/ood/.well-known/acme-challenge')
    EOF

    ./getssl $DOMAIN

Now, set the certificate

    cp /etc/ood/config/ood_portal_orig.yml /etc/ood/config/ood_portal.yml

    mkdir /etc/ssl/$DOMAIN
    cp ${HOME}/.getssl/${DOMAIN}/${DOMAIN}.crt /etc/ssl/${DOMAIN}
    cp ${HOME}/.getssl/${DOMAIN}/${DOMAIN}.key /etc/ssl/${DOMAIN}
    pushd /etc/ssl/$DOMAIN
    wget https://letsencrypt.org/certs/letsencryptauthorityx3.pem.txt
    popd
    cat <<EOF >>/etc/ood/config/ood_portal.yml
    ssl:
    - 'SSLCertificateFile "/etc/ssl/${DOMAIN}/${DOMAIN}.crt"'
    - 'SSLCertificateKeyFile "/etc/ssl/${DOMAIN}/${DOMAIN}.key"'
    - 'SSLCertificateChainFile "/etc/ssl/${DOMAIN}/letsencryptauthorityx3.pem.txt"'
    EOF

    /opt/ood/ood-portal-generator/sbin/update_ood_portal
    sudo systemctl try-restart httpd24-httpd.service httpd24-htcacheclean.service
