###################################################################
#Script Name	: create-kubernetes-gcp.sh                                                                                  
#Description	: state of art kub gcp provisioning with gcloud cli                                                                             
#Args          	: no args needed, but need to edit values.sh file
#Author       	: Everton Seiei Arakaki                                                
#Email         	: eveuca@gmail.com                                           
###################################################################

# import variables in script context
source values.sh

#
cloud-infrastructure/00-gcloud-network.sh

#
cloud-infrastructure/01-gcloud-apiadmin-sa.sh

#
cloud-infrastructure/10-gcloud-gke.sh

#
cloud-infrastructure/11-gcloud-prom-storage.sh

#
cloud-infrastructure/20-gcloud-clouddns.sh

# configure cloud shell to kubernetes via clusterrolebinding
kubectl create clusterrolebinding "cluster-admin-$(whoami)" \
--clusterrole=cluster-admin \
--user="$(gcloud config get-value core/account)"

#
gke-addons/install-helm-gke.sh


