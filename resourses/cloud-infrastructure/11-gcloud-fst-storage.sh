###################################################################
#Script Name	: 11-gcloud-fst-storage.sh
#Description	:
#Args          	: no args needed, but env variables are a must
#Author       	: Everton Seiei Arakaki
#Email         	: eveuca@gmail.com
###################################################################

gcloud beta compute disks create fst-volume \
    --project=$PROJECT_ID \
    --region=$REGION \
    --type=pd-ssd \
    --size=$PROM_PV_SIZE \
    --replica-zones=${REGION}-${ZONE_POSFIX_1},${REGION}-${ZONE_POSFIX_2} \
    --physical-block-size=4096