###################################################################
#Script Name	: 30-build-cid-objects.sh
#Description	: 
#Args          	: no args needed, but need to edit values.sh file
#Author       	: Everton Seiei Arakaki
#Email         	: eveuca@gmail.com
###################################################################

# import variables in script context
source values.sh

gcloud config set project $PROJECT_ID

echo "--- install flagger ---"
. gke-addons/install-flagger-gke.sh

kubectl apply -f ../template-manifests/prd-template-manifests/flagger-loadtest/
kubectl apply -f ../template-manifests/dev-template-manifests/flagger-loadtest/

echo "--- install cid objects ---"
. ../template-manifests/cid-template-manifests/99-psql/install-psql.sh ../template-manifests/cid-template-manifests/99-psql/pg-cid-values.yaml
. ../template-manifests/cid-template-manifests/98-redis/install-redis.sh
. ../template-manifests/cid-template-manifests/20-jenkins/install-jenkins.sh
. ../template-manifests/cid-template-manifests/30-sonarqube/install_sonarqube.sh
. ../template-manifests/cid-template-manifests/00-harbor/install-harbor-container-registry.sh