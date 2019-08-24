###################################################################
#Script Name	: install-cert-manager.sh                                                                                  
#Description	: install cert manager                                                                                  
#Args          	: no args needed, but env variables are a must 
#Author       	: Everton Seiei Arakaki                                                
#Email         	: eveuca@gmail.com                                           
###################################################################

CERT_REPO=https://raw.githubusercontent.com/jetstack/cert-manager
# apply custom resources definition, REALLY important
kubectl apply -f ${CERT_REPO}/release-0.7/deploy/manifests/00-crds.yaml

# create ns
kubectl create namespace cert-manager
kubectl label namespace cert-manager certmanager.k8s.io/disable-validation=true
helm repo add jetstack https://charts.jetstack.io && \
helm repo update && \
helm upgrade -i cert-manager \
--namespace cert-manager \
--version v0.9.0 \
jetstack/cert-manager