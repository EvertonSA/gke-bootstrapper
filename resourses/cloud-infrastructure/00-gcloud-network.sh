# create VPC
gcloud compute 
    --project=$PROJECT_ID \
    networks create $VPC \
    --subnet-mode=custom

# create VM subnet 
gcloud compute \
    --project=$PROJECT_ID \
subnets create $VM_SBN \
    --network=$VPC \
    --region=$REGION \
    --range=$VM_SBN_IP_RANGE

# create k8s subnet 
gcloud compute \
    --project=$PROJECT_ID \
subnets create $KUB_SBN \
    --network=$VPC \
    --region=$REGION \
    --range=$KUB_SBN_IP_RANGE