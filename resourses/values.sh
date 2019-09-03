#!/bin/bash 
###################################################################
#Script Name	: values.sh                                                                                            
#Description	: This file is to be loaded by the main provisioner script                                                                                  
#Args          	: no args needed, but need to be filled in before hand                                                                                          
#Author       	: Everton Seiei Arakaki                                                
#Email         	: eveuca@gmail.com                                           
###################################################################

#### gcp_specific
PROJECT_ID="sandbox-251021"
CLUSTER_NAME="sciensa-kub-cluster-001"
REGION="us-central1" 
CLUSTER_VERSION="1.13.7-gke.19"
VPC="sciensa-vpc-001"
KUB_SBN="sciensa-subnet-kub"
VM_SBN="sciensa-subnet-vm"
OWNER_EMAIL="everton.arakaki@soaexpert.com.br"
SA_EMAIL="apiadmin@sandbox-251021.iam.gserviceaccount.com"
DOMAIN="evertonarakaki.tk"
CLOUDDNS_ZONE="istio"
ZONE_POSFIX_1="c"
ZONE_POSFIX_2="f"


# DNS settings:
#CERTMANAGER_DNS='--dns01-recursive-nameservers "80.80.80.80:53,80.80.81.81:53"'

#TODO, find a way to pass as intreger..
PROMETHEUS_SSD_SIZE="50" # In GB. Free account only have 100 max ssd per region
ELASTICSEARCH_SSD_SIZE="50" # In GB. Free account only have 100 max ssd per region

#### slack specific
SLACK_URL_WEBHOOK="https://hooks.slack.com/services/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"
SLACK_CHANNEL="canary-tester"
SLACK_USER="flagger"

#### do not modify bellow ####

#variable_completion
e_VPC="projects/$PROJECT_ID/global/networks/$VPC"
e_SBN="projects/$PROJECT_ID/regions/$REGION/subnetworks/$KUB_SBN"
e_SBN_VM="projects/$PROJECT_ID/regions/$REGION/subnetworks/$VM_SBN"

#ip range for subnets
KUB_SBN_IP_RANGE="10.32.0.0/16"
VM_SBN_IP_RANGE="10.0.8.0/24"


# --- End Definitions Section ---    
# check if we are being sourced by another script or shell
[[ "${#BASH_SOURCE[@]}" -gt "1" ]] && { return 0; }