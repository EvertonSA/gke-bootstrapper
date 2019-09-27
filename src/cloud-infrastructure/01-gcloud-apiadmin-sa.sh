###################################################################
#Script Name	: install-flagger-gke.sh                                                                                  
#Description	: install flagger and configure it to manage istio gateway 
#                 and also install prometheus and grafana for canary analisys                                                                                  
#Args          	: no args needed, but env variables are a must 
#Author       	: Everton Seiei Arakaki                                                
#Email         	: eveuca@gmail.com                                           
###################################################################


# create and bind GCP SA to k8s SA
gcloud iam service-accounts create apiadmin \
--display-name=apiadmin \
--project=${PROJECT_ID}

gcloud iam service-accounts keys create ./apiadmin.json \
--iam-account=apiadmin@${PROJECT_ID}.iam.gserviceaccount.com \
--project=${PROJECT_ID}

# need deeper granularity here... 
gcloud projects add-iam-policy-binding ${PROJECT_ID} \
--member=serviceAccount:apiadmin@${PROJECT_ID}.iam.gserviceaccount.com \
--role=roles/editor