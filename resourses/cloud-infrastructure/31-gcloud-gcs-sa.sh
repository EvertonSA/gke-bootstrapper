###################################################################
#Script Name	: 30-gcloud-dns-sa.sh
#Description	: Provision Service Account with DNS admin rights for
#                 certmanager do its magic with letsencrypt certificates
#Args          	: no args needed, but env variables are a must
#Author       	: Everton Seiei Arakaki
#Email         	: eveuca@gmail.com
###################################################################

# create and bind GCP SA to k8s SA
gcloud iam service-accounts create gcs-admin \
--display-name=gcs-admin \
--project=${PROJECT_ID}

gcloud iam service-accounts keys create ./gcp-gcs-admin.json \
--iam-account=gcs-admin@${PROJECT_ID}.iam.gserviceaccount.com \
--project=${PROJECT_ID}

gcloud projects add-iam-policy-binding ${PROJECT_ID} \
--member=serviceAccount:gcs-admin@${PROJECT_ID}.iam.gserviceaccount.com \
--role=roles/storage.objectAdmin

gsutil hmac create gcs-admin@${PROJECT_ID}.iam.gserviceaccount.com > ./gcp-gcs-admin.json

base64 ./gcp-gcs-admin.json -w 0 > ./gcp-gcs-hmac-admin-base64.json
#rm -rf ./gcp-gcs-admin.json