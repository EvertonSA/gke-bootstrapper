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

echo "--- install cid objects ---"
. ../template-manifests/cid-template-manifests/99-psql/install-psql.sh
. ../template-manifests/cid-template-manifests/98-redis/install-redis.sh
. ../template-manifests/cid-template-manifests/20-jenkins/install-jenkins.sh
. ../template-manifests/cid-template-manifests/30-jenkins/install-sonarqube.sh