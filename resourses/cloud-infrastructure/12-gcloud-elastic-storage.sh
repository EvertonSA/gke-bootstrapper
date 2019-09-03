###################################################################
#Script Name	: 11-gcloud-prom-storage.sh                                                                                  
#Description	: Provision persistent disk for prometheus metrics. 
#                 Disk is provisioned under $REGION zone ending with a.                                                                                  
#Args          	: no args needed, but env variables are a must 
#Author       	: Everton Seiei Arakaki                                                
#Email         	: eveuca@gmail.com                                           
###################################################################

gcloud beta compute disks create elasticsearch-volume \
    --project=$PROJECT_ID \
    --type=pd-ssd \
    --size=15GB \
    --zone=$REGION-ZONE_POSFIX_1 \
    --physical-block-size=4096