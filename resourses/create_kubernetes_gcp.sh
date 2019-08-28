###################################################################
#Script Name	: create-kubernetes-gcp.sh                                                                                  
#Description	: state of art kub gcp provisioning with gcloud cli                                                                             
#Args          	: no args needed, but need to edit values.sh file
#Author       	: Everton Seiei Arakaki                                                
#Email         	: eveuca@gmail.com                                           
###################################################################

# import variables in script context
source values.sh

#echo "Provision network stuff"
. cloud-infrastructure/00-gcloud-network.sh

#echo "Create service account"
. cloud-infrastructure/01-gcloud-apiadmin-sa.sh

# echo "Create GKE cluster"
. cloud-infrastructure/10-gcloud-gke.sh

# create storage for prometheus 
# for free accounts, limit is 50GB per region. ideal 250 each ...
. cloud-infrastructure/11-gcloud-prom-storage.sh

# elastic is provisioned using helm, do not apply bellow line
. cloud-infrastructure/12-gcloud-elastic-storage.sh

# # create dns entry
. cloud-infrastructure/20-gcloud-clouddns.sh

# create dns service account
. cloud-infrastructure/30-gcloud-dns-sa.sh

# configure cloud shell to kubernetes via clusterrolebinding
kubectl create clusterrolebinding "cluster-admin-$(whoami)" \
   --clusterrole=cluster-admin \
   --user="$(gcloud config get-value core/account)"

# install helm on gke
. gke-addons/install-helm-gke.sh

# # install cert-manager for TLS with letsencrypt, if dottk see script
. gke-addons/install-cert-manager-gke.sh

# TODO install issuer and certificate

kubectl apply -f cert-manager-manifests/00-letsencrypt-prod-issuer.yaml
#kubectl apply -f cert-manager-manifests/10-istio-gateway-cert.yaml

# # bellow is necessary to renew istio gateway pod certificate
#kubectl -n istio-system delete pods -l istio=ingressgateway

# # install flagger 
. gke-addons/install-flagger-gke.sh
