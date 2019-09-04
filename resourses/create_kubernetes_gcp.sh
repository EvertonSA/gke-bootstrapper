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

echo "--- Provision network stuff ---"
. cloud-infrastructure/00-gcloud-network.sh

echo "--- Create service account ---"
. cloud-infrastructure/01-gcloud-apiadmin-sa.sh

echo "--- Create GKE cluster ---"
. cloud-infrastructure/10-gcloud-gke.sh

echo "--- create ssd storage for prometheus ---"
. cloud-infrastructure/11-gcloud-fst-storage.sh

echo "--- create dns entry ---"
. cloud-infrastructure/20-gcloud-clouddns.sh

echo "--- create dns service account"
. cloud-infrastructure/30-gcloud-dns-sa.sh

echo "--- configure cloud shell to kubernetes via clusterrolebinding ---"
kubectl create clusterrolebinding "cluster-admin-$(whoami)" \
   --clusterrole=cluster-admin \
   --user="$(gcloud config get-value core/account)"

echo "--- create storage classes and persistent volumes ---"
. gke-addons/fast-regional-storageclass.sh
. gke-addons/standard-regional-storageclass.sh
. gke-addons/persistent-volume-prom.sh

echo "--- kubectl apply standard namespaces ---"
kubectl apply -f ../template-manifests/00-namespaces

echo "--- enabling istio sidecar injection ---"
kubectl apply -f ../template-manifests/cid-template-manifests/istio-sidecar
kubectl apply -f ../template-manifests/log-template-manifests/istio-sidecar
kubectl apply -f ../template-manifests/mon-template-manifests/istio-sidecar
kubectl apply -f ../template-manifests/dev-template-manifests/istio-sidecar
kubectl apply -f ../template-manifests/ite-template-manifests/istio-sidecar
kubectl apply -f ../template-manifests/prd-template-manifests/istio-sidecar

echo "--- taint third machine ---"
. gke-addons/add-node-taint.sh

echo "--- install helm on gke ---"
. gke-addons/install-helm-gke.sh

echo "--- install cert-manager for TLS with letsencrypt ---"
. gke-addons/install-cert-manager-gke.sh

echo "--- install letsencrypt prod issuer ---"
. cert-manager-manifests/00-letsencrypt-prod-issuer.sh

echo "--- install flagger ---"
. gke-addons/install-flagger-gke.sh

echo "--- install mon objects ---"
. ../template-manifests/mon-template-manifests/00-alertmanager/00-alertmanager-configmap.sh
. ../template-manifests/mon-template-manifests/01-prometheus/03-prometheus-storage.sh
. gke-addons/install-mon-objects.sh

echo "--- install log objects ---"
. ../template-manifests/log-template-manifests/00-elasticsearch/es-ss.sh
kubectl apply -f ../template-manifests/log-template-manifests/00-elasticsearch
kubectl apply -f ../template-manifests/log-template-manifests/10-fluentd
kubectl apply -f ../template-manifests/log-template-manifests/20-kibana