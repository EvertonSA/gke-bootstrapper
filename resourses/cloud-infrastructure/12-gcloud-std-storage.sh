###################################################################
#Script Name	: 11-gcloud-std-storage.sh                                                                                  
#Description	:                                                                          
#Args          	: no args needed, but env variables are a must 
#Author       	: Everton Seiei Arakaki                                                
#Email         	: eveuca@gmail.com                                           
###################################################################

gcloud beta compute disks create std-volume \
    --project=$PROJECT_ID \
    --region=$REGION \
    --type=pd-standard \
    --size=$STD_PV_SIZE \
    --replica-zones=${REGION}-${ZONE_POSFIX_1},${REGION}-${ZONE_POSFIX_2} \
    --physical-block-size=4096