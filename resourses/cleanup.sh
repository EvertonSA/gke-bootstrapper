###################################################################
#Script Name	: cleanup.sh                                                                                  
#Description	: cleanup                                                                             
#Args          	: no args needed, but need to edit values.sh file
#Author       	: Everton Seiei Arakaki                                                
#Email         	: eveuca@gmail.com                                           
###################################################################

# import variables in script context
source values.sh

# começar dos discos

# echo "deleting pool-horizontal-autoscaling"
# gcloud container node-pools delete "pool-horizontal-autoscaling" 
#     --cluster=$CLUSTER_NAME \
#     --region=$REGION

# echo "deleting cluster"
# gcloud container clusters delete $CLUSTER_NAME \
#     --region=$REGION

# echo "delete apiadmin service account"
# gcloud iam service-accounts delete $SA_EMAIL

# echo "delete kub subnet"
# gcloud compute networks subnets delete $e_SBN

# echo "delete vm subnet"
# gcloud compute networks subnets delete $e_SBN_VM

# echo "delete vpc"
# gcloud compute networks delete $e_VPC

