source values.sh

gcloud config set project $PROJECT_ID

echo "--- create gcs service account"
. cloud-infrastructure/31-gcloud-gcs-sa.sh

echo "--- provision gcs bucket for container registry ---"
. cloud-infrastructure/40-gcloud-create-bucket.sh

. ../template-manifests/cid-template-manifests/00-harbor/install-harbor-container-registry.sh