###################################################################
#Script Name	: create-kubernetes-gcp.sh                                                                                  
#Description	: state of art kub gcp provisioning with gcloud cli                                                                             
#Args          	: no args needed, but need to edit values.sh file
#Author       	: Everton Seiei Arakaki                                                
#Email         	: eveuca@gmail.com                                           
###################################################################

# import variables in script context
source values.sh

gcloud config set project $PROJECT_ID

# #echo "Provision network stuff"
# . cloud-infrastructure/00-gcloud-network.sh

# #echo "Create service account"
# . cloud-infrastructure/01-gcloud-apiadmin-sa.sh

# # echo "Create GKE cluster"
#. cloud-infrastructure/10-gcloud-gke.sh

# create ssd storage for applications that need fast io 
#. cloud-infrastructure/11-gcloud-fst-storage.sh

# create standart storage for applications
#. cloud-infrastructure/12-gcloud-std-storage.sh

# # # create dns entry
#. cloud-infrastructure/20-gcloud-clouddns.sh

# # create dns service account
#. cloud-infrastructure/30-gcloud-dns-sa.sh

# configure cloud shell to kubernetes via clusterrolebinding
#kubectl create clusterrolebinding "cluster-admin-$(whoami)" \
#   --clusterrole=cluster-admin \
#   --user="$(gcloud config get-value core/account)"

# create storage classes and persistent volumes
#. gke-addons/fast-regional-storageclass.sh
#. gke-addons/standard-regional-storageclass.sh
#. gke-addons/persistent-volume-regional.sh

# # taint third machine
#. gke-addons/add-node-taint.sh

# # install helm on gke
#. gke-addons/install-helm-gke.sh

# # # install cert-manager for TLS with letsencrypt, if dottk see script
#. gke-addons/install-cert-manager-gke.sh

#sleep 10s
. cert-manager-manifests/00-letsencrypt-prod-issuer.sh
# #kubectl apply -f cert-manager-manifests/10-istio-gateway-cert.yaml

# # # install flagger 
#. gke-addons/install-flagger-gke.sh

kubectl apply -f ../template-manifests/00-namespaces



# # # install mon objects
. ../template-manifests/mon-template-manifests/00-alertmanager/00-alertmanager-configmap.sh
. ../template-manifests/mon-template-manifests/01-prometheus/03-prometheus-storage.sh
. gke-addons/install-mon-objects.sh
