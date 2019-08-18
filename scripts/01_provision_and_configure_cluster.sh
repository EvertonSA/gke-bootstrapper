PROJECT_ID="devops-trainee"
CLUSTER_NAME="devops-k8s-gitops-001"
REGION="us-central1" # OPTIONS = {"lowest_price":["us-central1", "us-west1", "us-east1"], "lowest_latency":["southamerica-east1"]}
CLUSTER_VERSION="1.13.7-gke.19"
VPC="devops-trainee-vpc-001"
SBN="devops-trainee-subnet-kub"
SA_EMAIL="apiadmin@devops-trainee.iam.gserviceaccount.com"

#github
url_GIT="https://github.com/"
usr_GIT="evertonsa"




e_VPC="projects/$PROJECT_ID/global/networks/$VPC"
e_SBN="projects/$PROJECT_ID/regions/$REGION/subnetworks/$SBN"


# create GKE production ready cluster
gcloud beta container \
    --project $PROJECT_ID \
clusters create $CLUSTER_NAME \
    --region $REGION \
    --no-enable-basic-auth \
    --cluster-version $CLUSTER_VERSION \
    --machine-type "n1-standard-1" \
    --image-type "COS" \ 
    --disk-type "pd-standard" \
    --disk-size "100" \
    --metadata disable-legacy-endpoints=true \ #security best practice
    --service-account $SA_EMAIL \ #  to be checked best practices for IAM GKE roles
    --num-nodes "1" \ #1 node per zone = 3 instances
    --enable-stackdriver-kubernetes \ # can be disabled, but not advisable
    --enable-ip-alias \ 
    --network $e_VPC \
    --subnetwork $e_SBN \
    --enable-intra-node-visibility \ 
    --default-max-pods-per-node "110" \ # can be extended but not so simple
    --addons HorizontalPodAutoscaling,HttpLoadBalancing,Istio --istio-config auth=MTLS_PERMISSIVE \
    --enable-autoupgrade \ # for critical services, I would disable it
    --enable-autorepair \
    --maintenance-window "06:00" \ # for critical services, I would disable it
#    --identity-namespace "devops-trainee.svc.id.goog"  disabled due to beta, but duable in the future 

# add extra preemtible node pool for horizontal autoscaling
gcloud beta container \
    --project $PROJECT_ID \
node-pools create "pool-horizontal-autoscaling" \
    --cluster $CLUSTER_NAME \
    --region $REGION \ # can be --zone specific if traffic is higher in one zone. Probably not applicable for Brazil  
    --node-version $CLUSTER_VERSION \
    --machine-type "n1-standard-1" \
    --image-type "COS" \
    --disk-type "pd-standard" \
    --disk-size "100" \
    --metadata disable-legacy-endpoints=true \
    --scopes "https://www.googleapis.com/auth/devstorage.read_only","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring","https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly","https://www.googleapis.com/auth/trace.append" \
    --preemptible \
    --enable-autoscaling \
    --min-nodes "0" \
    --max-nodes "2" \
    --enable-autoupgrade \
    --enable-autorepair

## Authenticate to new cluster with:
# 

# Install Helm

kubectl -n kube-system create sa tiller

kubectl create clusterrolebinding tiller-cluster-rule \
--clusterrole=cluster-admin \
--serviceaccount=kube-system:tiller

helm init --service-account tiller --wait

# clone botstrapper
git clone https://source.developers.google.com/p/devops-trainee/r/github_evehawas_gitops-istio
# might also work with
#gcloud source repos clone github_evehawas_gitops-istio --project=$PROJECT_ID
cd gitops-istio