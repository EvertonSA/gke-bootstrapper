#!/bin/bash
###################################################################
#Script Name	: values.sh
#Description	: This file is to be loaded by the main provisioner script
#Args          	: no args needed, but need to be filled in before hand
#Author       	: Everton Seiei Arakaki
#Email         	: eveuca@gmail.com
###################################################################

#### Modify bellow according to your project
PROJECT_ID="sre-birds"
CLUSTER_NAME="kub-cluster-001"
REGION="us-central1"
ZONE_POSFIX_1="a"
ZONE_POSFIX_2="b"
OWNER_EMAIL="eveuca@gmail.com"
DOMAIN="arakaki.in"

#### not needed to modify, but you can, at your own risk :) ####
SA_EMAIL="apiadmin@${PROJECT_ID}.iam.gserviceaccount.com"
CLUSTER_VERSION="1.13.11-gke.9"
ISTIO_VERSION="1.3.0"
VPC="vpc-001"
KUB_SBN="subnet-kub"
VM_SBN="subnet-vm"

#### do not modify bellow ####

# CloudDNS Zone Name
CLOUDDNS_ZONE="istio"

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
