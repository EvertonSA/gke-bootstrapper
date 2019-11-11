###################################################################
#Script Name	: 10-gcloud-gke.sh
#Description	: Provision GKE cluster with default node pool + autoscaling pool
#Args          	: no args needed, but env variables are a must
#Author       	: Everton Seiei Arakaki
#Email         	: eveuca@gmail.com
###################################################################

# create GKE production ready cluster
# disable basic-auth is best practice!
# disable legacy-endpoints is best practice!
# stackdriver is disabled, to enable, uncomment bellow
#    --enable-stackdriver-kubernetes \
# When enabled, a Pod sends a packet to another Pod on the same node, the packet leaves the node and is processed by the GCP network.
# istio is the google choice for service mesh
# auto-upgrade will only happen at 3am

gcloud beta container \
    --project $PROJECT_ID \
clusters create $CLUSTER_NAME \
    --zone=$REGION-$ZONE_POSFIX_1 \
    --node-locations=$REGION-$ZONE_POSFIX_1,$REGION-$ZONE_POSFIX_2 \
    --network $e_VPC \
    --subnetwork $e_SBN \
    --no-enable-basic-auth \
    --metadata disable-legacy-endpoints=true \
    --cluster-version $CLUSTER_VERSION \
    --machine-type "n1-standard-2" \
    --num-nodes "2" \
    --disk-type "pd-standard" \
    --disk-size "30" \
    --image-type "COS"  \
    --service-account $SA_EMAIL \
    --default-max-pods-per-node "110" \
    --maintenance-window "03:00" \
    --enable-stackdriver-kubernetes \
    --enable-intra-node-visibility \
    --enable-autoupgrade \
    --enable-autorepair \
    --enable-ip-alias \
    --addons HorizontalPodAutoscaling,HttpLoadBalancing
#    --addons HorizontalPodAutoscaling,HttpLoadBalancing,Istio \
#    --istio-config=auth=MTLS_PERMISSIVE 
    
# add extra preemtible node pool for horizontal autoscaling
gcloud beta container \
    --project $PROJECT_ID \
node-pools create "pool-horizontal-autoscaling" \
    --cluster $CLUSTER_NAME \
    --zone=$REGION-$ZONE_POSFIX_1 \
    --node-locations=$REGION-$ZONE_POSFIX_1,$REGION-$ZONE_POSFIX_2 \
    --node-version $CLUSTER_VERSION \
    --machine-type "n1-highcpu-4" \
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