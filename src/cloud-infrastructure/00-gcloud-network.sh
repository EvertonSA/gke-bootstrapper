###################################################################
#Script Name	: 00-gcloud-network.sh                                                                                  
#Description	: Provision VPC and subnets under GCP                                                                                  
#Args          	: no args needed, but env variables are a must 
#Author       	: Everton Seiei Arakaki                                                
#Email         	: eveuca@gmail.com                                           
###################################################################

# create VPC
gcloud compute \
    --project=$PROJECT_ID \
    networks create $VPC \
    --subnet-mode=custom

# create VM subnet 
gcloud compute \
    --project=$PROJECT_ID \
networks subnets create $VM_SBN \
    --network=$VPC \
    --region=$REGION \
    --range=$VM_SBN_IP_RANGE

# create k8s subnet 
gcloud compute \
    --project=$PROJECT_ID \
networks subnets create $KUB_SBN \
    --network=$VPC \
    --region=$REGION \
    --range=$KUB_SBN_IP_RANGE