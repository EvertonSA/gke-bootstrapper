###################################################################
#Script Name	: cleanup.sh                                                                                  
#Description	: cleanup                                                                             
#Args          	: no args needed, but need to edit values.sh file
#Author       	: Everton Seiei Arakaki                                                
#Email         	: eveuca@gmail.com                                           
###################################################################

# import variables in script context
source values.sh

gcloud config set project $PROJECT_ID

echo "delete CloudDNS Entry" 
GATEWAY_IP=$(kubectl -n istio-system get svc/istio-ingressgateway -ojson | jq -r .status.loadBalancer.ingress[0].ip)
gcloud dns record-sets transaction start --zone=$CLOUDDNS_ZONE
gcloud dns record-sets transaction remove ${GATEWAY_IP} --name="${DOMAIN}"     --ttl=300 --type=A --zone=$CLOUDDNS_ZONE 
gcloud dns record-sets transaction remove ${GATEWAY_IP} --name="www.${DOMAIN}" --ttl=300 --type=A --zone=$CLOUDDNS_ZONE 
gcloud dns record-sets transaction remove ${GATEWAY_IP} --name="*.${DOMAIN}"   --ttl=300 --type=A --zone=$CLOUDDNS_ZONE 
gcloud dns record-sets transaction execute --zone $CLOUDDNS_ZONE
gcloud dns managed-zones delete $CLOUDDNS_ZONE

echo "deleting pool-horizontal-autoscaling"
gcloud container node-pools delete "pool-horizontal-autoscaling" \
    --cluster=$CLUSTER_NAME \
    --zone=$REGION-$ZONE_POSFIX_1  --quiet 

echo "deleting cluster"
gcloud container clusters delete $CLUSTER_NAME \
    --zone=$REGION-$ZONE_POSFIX_1  --quiet 

echo "delete apiadmin service account"
gcloud iam service-accounts delete $SA_EMAIL  --quiet 

echo "delete kub subnet"
gcloud compute networks subnets delete $e_SBN  --quiet 

echo "delete vm subnet"
gcloud compute networks subnets delete $e_SBN_VM --quiet

echo "deleting remaning istio firewall rules"
for fwrule in $(gcloud compute firewall-rules list --filter "name:k8s*" --format="value("name")"); do
  gcloud compute firewall-rules delete $fwrule --quiet
done

echo "delete vpc"
gcloud compute networks delete $e_VPC --quiet 

echo "delete disks created by pvc objects"
for disk in $(gcloud compute disks list --filter="name:gke-$CLUSTER_NAME*" --format="value("name")"); do
  disk_location_scope=$(gcloud compute disks list --filter="name:$disk" --format="value("LOCATION_SCOPE")")
  disk_location=$(gcloud compute disks list --filter="name:$disk" --format="value("LOCATION")")
  if [ $disk_location_scope = "region" ]; then
    gcloud compute disks delete $disk --region $disk_location --quiet
  else
    gcloud compute disks delete $disk --zone $disk_location --quiet
  fi 
done

echo "delete apiadmin service account"
gcloud iam service-accounts delete $SA_EMAIL  --quiet 

echo "delete gcp apiadminadmin json file"
rm -f apiadmin.json
