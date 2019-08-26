###################################################################
#Script Name	: create-kubernetes-gcp.sh                                                                                  
#Description	: state of art kub gcp provisioning with gcloud cli                                                                             
#Args          	: no args needed, but need to edit values.sh file
#Author       	: Everton Seiei Arakaki                                                
#Email         	: eveuca@gmail.com                                           
###################################################################

# import variables in script context
source values.sh

# provision network stuff
cloud-infrastructure/00-gcloud-network.sh

# create service account
cloud-infrastructure/01-gcloud-apiadmin-sa.sh

# create GKE cluster
cloud-infrastructure/10-gcloud-gke.sh

# create storage 
cloud-infrastructure/11-gcloud-prom-storage.sh

# create dns entry
cloud-infrastructure/20-gcloud-clouddns.sh

# configure cloud shell to kubernetes via clusterrolebinding
kubectl create clusterrolebinding "cluster-admin-$(whoami)" \
--clusterrole=cluster-admin \
--user="$(gcloud config get-value core/account)"

# install helm on gke
gke-addons/install-helm-gke.sh

# install cert-manager for TLS with letsencrypt
gke-addons/install-cert-manager-gke.sh

# bellow is necessary to renew istio gateway pod certificate
kubectl -n istio-system delete pods -l istio=ingressgateway

# install flagger 
gke-addons/install-flagger-gke.sh
