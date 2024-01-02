#! /bin/sh

export DOMAIN_NAME_AKS_BASELINE="contoso.com"

# Create the certificate that will be presented to web clients by Azure Application Gateway for your domain
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -out appgw.crt -keyout appgw.key -subj "/CN=bicycle.${DOMAIN_NAME_AKS_BASELINE}/O=Contoso Bicycle" -addext "subjectAltName = DNS:bicycle.${DOMAIN_NAME_AKS_BASELINE}" -addext "keyUsage = digitalSignature" -addext "extendedKeyUsage = serverAuth"
openssl pkcs12 -export -out appgw.pfx -in appgw.crt -inkey appgw.key -passout pass:

# Base64 encode the client-facing certificate
export APP_GATEWAY_LISTENER_CERTIFICATE_AKS_BASELINE=$(cat appgw.pfx | base64 | tr -d '\n')
echo APP_GATEWAY_LISTENER_CERTIFICATE_AKS_BASELINE: $APP_GATEWAY_LISTENER_CERTIFICATE_AKS_BASELINE

# Generate the wildcard certificate for the AKS ingress controller
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -out traefik-ingress-internal-aks-ingress-tls.crt -keyout traefik-ingress-internal-aks-ingress-tls.key -subj "/CN=*.aks-ingress.${DOMAIN_NAME_AKS_BASELINE}/O=Contoso AKS Ingress"

# Base64 encode the AKS ingress controller certificate
export AKS_INGRESS_CONTROLLER_CERTIFICATE_BASE64_AKS_BASELINE=$(cat traefik-ingress-internal-aks-ingress-tls.crt | base64 | tr -d '\n')
echo AKS_INGRESS_CONTROLLER_CERTIFICATE_BASE64_AKS_BASELINE: $AKS_INGRESS_CONTROLLER_CERTIFICATE_BASE64_AKS_BASELINE

# run the saveenv.sh script at any time to save environment variables created above to aks_baseline.env
../saveenv.sh

# if your terminal session gets reset, you can source the file to reload the environment variables
# source aks_baseline.env