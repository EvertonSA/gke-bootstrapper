###################################################################
#Script Name	: 10-gcloud-gke.sh                                                                                  
#Description	: Provision GKE cluster with default node pool + autoscaling pool                                                                               
#Args          	: no args needed, but env variables are a must 
#Author       	: Everton Seiei Arakaki                                                
#Email         	: eveuca@gmail.com                                           
###################################################################

# create GKE production ready cluster
gcloud beta container \
    --project $PROJECT_ID \
clusters create $CLUSTER_NAME \
    --region $REGION \
# disable basic-auth is best practice!
    --no-enable-basic-auth \
    --cluster-version $CLUSTER_VERSION \
    --machine-type "n1-standard-1" \
    --image-type "COS"  \
    --disk-type "pd-standard" \
    --disk-size "30" \
# disable legacy-endpoints is best practice!
    --metadata disable-legacy-endpoints=true \
    --service-account $SA_EMAIL \
    --num-nodes "1" \
# stackdriver is disabled, to enable, uncomment bellow 
#    --enable-stackdriver-kubernetes \
    --enable-ip-alias \
    --network $e_VPC \
    --subnetwork $e_SBN \
# When enabled, a Pod sends a packet to another Pod on the same node, the packet leaves the node and is processed by the GCP network.
    --enable-intra-node-visibility \
    --default-max-pods-per-node "110" \
# istio is the google choice for service mesh
    --addons HorizontalPodAutoscaling,HttpLoadBalancing,Istio \
    --istio-config=auth=MTLS_PERMISSIVE \
    --enable-autoupgrade \
    --enable-autorepair \
# auto-upgrade will only happen at 3am
    --maintenance-window "03:00" 

# add extra preemtible node pool for horizontal autoscaling
gcloud beta container \
    --project $PROJECT_ID \
node-pools create "pool-horizontal-autoscaling" \
    --cluster $CLUSTER_NAME \
    --region $REGION \
    --node-version $CLUSTER_VERSION \
    --machine-type "n1-standard-4" \
    --image-type "COS" \
    --disk-type "pd-standard" \
    --disk-size "100" \
    --metadata disable-legacy-endpoints=true \
    --scopes "https://www.googleapis.com/auth/devstorage.read_only","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring","https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly","https://www.googleapis.com/auth/trace.append" \
    --preemptible \
    --enable-autoscaling \
    --num-nodes "0" \
    --min-nodes "0" \
    --max-nodes "2" \
    --enable-autoupgrade \
    --enable-autorepair