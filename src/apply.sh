###################################################################
#Script Name	: create-kubernetes-gcp.sh
#Description	: state of art kub gcp provisioning with gcloud cli
#Note           : some lines stars with "." because need values.sh
#Args          	: no args needed, but need to edit values.sh file
#Author       	: Everton Seiei Arakaki
#Email         	: eveuca@gmail.com
###################################################################

# import variables in script context
source values.sh

gcloud config set project $PROJECT_ID

echo "--- Enabling API ---"
. cloud-infrastructure/00-enable-gcloud-api.sh

echo "--- Create service account ---"
. cloud-infrastructure/01-gcloud-apiadmin-sa.sh

echo "--- create dns service account"
. cloud-infrastructure/30-gcloud-dns-sa.sh

echo "--- Provision network stuff ---"
. cloud-infrastructure/00-gcloud-network.sh

echo "--- Create GKE cluster ---"
. cloud-infrastructure/10-gcloud-gke.sh

echo "--- configure cloud shell to kubernetes via clusterrolebinding ---"
kubectl create clusterrolebinding "cluster-admin-$(whoami)" \
   --clusterrole=cluster-admin \
   --user="$(gcloud config get-value core/account)"

echo "--- install helm on gke ---"
gke-addons/install-helm-gke.sh

echo "--- Install Istio 1.3.0 ---"
gke-addons/install-istio-gke.sh

echo "--- create HA storage classes ---"
. gke-addons/00-fast-regional-storageclass.sh
. gke-addons/01-standard-regional-storageclass.sh

echo "--- create CloudDNS entry ---"
. cloud-infrastructure/20-gcloud-clouddns.sh
