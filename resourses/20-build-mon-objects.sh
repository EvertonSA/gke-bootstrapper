###################################################################
#Script Name	: 20-build-mon-objects.sh
#Description	: 
#Args          	: no args needed, but need to edit values.sh file
#Author       	: Everton Seiei Arakaki
#Email         	: eveuca@gmail.com
###################################################################

# import variables in script context
source values.sh

gcloud config set project $PROJECT_ID

echo "--- install mon objects ---"
. ../template-manifests/mon-template-manifests/00-alertmanager/00-alertmanager-configmap.sh
. ../template-manifests/mon-template-manifests/01-prometheus/03-prometheus-storage.sh
. gke-addons/install-mon-objects.sh