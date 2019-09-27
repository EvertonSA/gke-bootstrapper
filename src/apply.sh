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

echo "--- Enabling API ---"
. cloud-infrastructure/00-enable-gcloud-api.sh

echo "--- Provision network stuff ---"
. cloud-infrastructure/00-gcloud-network.sh

echo "--- Create service account ---"
. cloud-infrastructure/01-gcloud-apiadmin-sa.sh

echo "--- Create GKE cluster ---"
. cloud-infrastructure/10-gcloud-gke.shell

echo "--- create dns service account"
. cloud-infrastructure/30-gcloud-dns-sa.sh

echo "--- configure cloud shell to kubernetes via clusterrolebinding ---"
kubectl create clusterrolebinding "cluster-admin-$(whoami)" \
   --clusterrole=cluster-admin \
   --user="$(gcloud config get-value core/account)"

echo "--- install helm on gke ---"
. gke-addons/install-helm-gke.sh

echo "--- create dns entry, only after istio is ready ---"
. cloud-infrastructure/20-gcloud-clouddns.sh

echo "--- create storage classes ---"
. gke-addons/fast-regional-storageclass.sh
. gke-addons/standard-regional-storageclass.sh

echo "--- Last, but not least, install istio gateway ---"
. istio-gke-templates/install-public-gateway.sh