#!/bin/bash 
###################################################################
#Script Name	: values.sh                                                                                            
#Description	: This file is to be loaded by the main provisioner script                                                                                  
#Args          	: no args needed, but need to be filled in before hand                                                                                          
#Author       	: Everton Seiei Arakaki                                                
#Email         	: eveuca@gmail.com                                           
###################################################################

#### gcp_specific
PROJECT_ID="devops-trainee"
CLUSTER_NAME="devops-k8s-gitops-001"
# OPTIONS = {"lowest_price":["us-central1", "us-west1", "us-east1"], "lowest_latency":["southamerica-east1"]}
REGION="us-central1" 
CLUSTER_VERSION="1.13.7-gke.19"
VPC="devops-trainee-vpc-001"
KUB_SBN="devops-trainee-subnet-kub"
VM_SBN="devops-trainee-subnet-vm"
OWNER_EMAIL="eveuca@gmail.com"
SA_EMAIL="apiadmin@devops-trainee.iam.gserviceaccount.com"
DOMAIN="arakaki.in"
CLOUDDNS_ZONE="istio"

#### github
url_GIT="https://github.com/"
usr_GIT="evertonsa"

#### slack specific
SLACK_URL_WEBHOOK="https://hooks.slack.com/services/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"
SLACK_CHANNEL="canary-tester"
SLACK_USER="flagger"

#### do not modify bellow ####

#variable_completion
e_VPC="projects/$PROJECT_ID/global/networks/$VPC"
e_SBN="projects/$PROJECT_ID/regions/$REGION/subnetworks/$KUB_SBN"

#ip range for subnets
KUB_SBN_IP_RANGE="10.32.0.0/16"
VM_SBN_IP_RANGE="10.0.8.0/24"


# --- End Definitions Section ---    
# check if we are being sourced by another script or shell
[[ "${#BASH_SOURCE[@]}" -gt "1" ]] && { return 0; }