###################################################################
#Script Name	: 30-gcloud-dns-sa.sh                                                                                  
#Description	: Provision Service Account with DNS admin rights for 
#                 certmanager do its magic with letsencrypt certificates                                                                                  
#Args          	: no args needed, but env variables are a must 
#Author       	: Everton Seiei Arakaki                                                
#Email         	: eveuca@gmail.com                                           
###################################################################

# create and bind GCP SA to k8s SA
gcloud iam service-accounts create dns-admin \
--display-name=dns-admin \
--project=${PROJECT_ID}

gcloud iam service-accounts keys create ./gcp-dns-admin.json \
--iam-account=dns-admin@${PROJECT_ID}.iam.gserviceaccount.com \
--project=${PROJECT_ID}

gcloud projects add-iam-policy-binding ${PROJECT_ID} \
--member=serviceAccount:dns-admin@${PROJECT_ID}.iam.gserviceaccount.com \
--role=roles/dns.admin

# bind service account created previously to kub secret
kubectl create secret generic cert-manager-credentials \
--from-file=./gcp-dns-admin.json \
--namespace=istio-system

#might be a good idea to delete gcp-dns-admin.json