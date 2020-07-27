# Setting up Azure Active Directory as authentication back-end

For Apache we are using the httpd24-mod_auth_openidc module.
This requires some small changes to the ood_portal.yml file:

```
auth:
  - 'AuthType openid-connect'
  - 'Require valid-user'
logout_redirect: '/oidc?logout=https%3A%2F%2F<dns name>'
oidc_uri: '/oidc'
```

OpenID is being configured in the auth_openidc.conf file:

```
OIDCProviderMetadataURL https://login.microsoftonline.com/<tenant-id from azure portal>/.well-known/openid-configuration
OIDCClientID        "<client-id from azure portal>"
OIDCClientSecret    "<client-secret from azure portal>"
OIDCRedirectURI      https://<dns name>/oidc
OIDCCryptoPassphrase "someverysecretpassphrasetodosessionencoding"

# Keep sessions alive for 8 hours
OIDCSessionInactivityTimeout 28800
OIDCSessionMaxDuration 28800

# Set REMOTE_USER
OIDCRemoteUserClaim unique_name

# Don't pass claims to backend servers
OIDCPassClaimsAs environment

# Strip out session cookies before passing to backend
OIDCStripCookies mod_auth_openidc_session mod_auth_openidc_session_chunks mod_auth_openidc_session_0 mod_auth_openidc_session_1
```

