gcloud beta compute disks create prometheus-volume \
    --project=$PROJECT_ID \
    --type=pd-ssd \
    --size=100GB \
    --zone=$REGION-a \
    --physical-block-size=4096