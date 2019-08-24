###################################################################
#Script Name	: 20-gcloud-clouddns.sh                                                                                  
#Description	: Provision and configure CloudDNS specific resources                                                                                  
#Args          	: no args needed, but env variables are a must 
#Author       	: Everton Seiei Arakaki                                                
#Email         	: eveuca@gmail.com                                           
###################################################################

# create a DNS zone under cloud DNS named istio
gcloud dns managed-zones create \
--dns-name=$DOMAIN \
--description="Istio zone" "istio"

# get istio ingress gateway
export GATEWAY_IP=$(kubectl -n istio-system get svc/istio-ingressgateway -ojson \
| jq -r .status.loadBalancer.ingress[0].ip)

########## start clouddns transaction ##########
gcloud dns record-sets transaction start --zone=$CLOUDDNS_ZONE
# add A record to $domain
gcloud dns record-sets transaction add --zone=$CLOUDDNS_ZONE \
--name="${DOMAIN}" --ttl=300 --type=A ${GATEWAY_IP}
# add A record to www.$domain
gcloud dns record-sets transaction add --zone=$CLOUDDNS_ZONE \
--name="www.${DOMAIN}" --ttl=300 --type=A ${GATEWAY_IP}
# add A recort to *.$domain (grafana.arakaki.in, prometheus.arakaki.in and so on)
gcloud dns record-sets transaction add --zone=$CLOUDDNS_ZONE \
--name="*.${DOMAIN}" --ttl=300 --type=A ${GATEWAY_IP}
gcloud dns record-sets transaction execute --zone $CLOUDDNS_ZONE
########## finish clouddns transaction ##########