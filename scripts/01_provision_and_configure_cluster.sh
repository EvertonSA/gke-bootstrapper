## Template for GKE boostrapping

##########################################################################################
## necessary variables
##########################################################################################

#gcp_specific
PROJECT_ID="devops-trainee"
CLUSTER_NAME="devops-k8s-gitops-001"
REGION="us-central1" # OPTIONS = {"lowest_price":["us-central1", "us-west1", "us-east1"], "lowest_latency":["southamerica-east1"]}
CLUSTER_VERSION="1.13.7-gke.19"
VPC="devops-trainee-vpc-001"
KUB_SBN="devops-trainee-subnet-kub"
VM_SBN="devops-trainee-subnet-vm"
OWNER_EMAIL="eveuca@gmail.com"
SA_EMAIL="apiadmin@devops-trainee.iam.gserviceaccount.com"
DOMAIN="arakaki.in"
CLOUDDNS_ZONE="istio"
#github
url_GIT="https://github.com/"
usr_GIT="evertonsa"
#slack specific
SLACK_URL_WEBHOOK="https://hooks.slack.com/services/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"
SLACK_CHANNEL="devops-sciensa"
SLACK_USER="flagger"

## do not modify bellow
#variable_completion
e_VPC="projects/C/global/networks/$VPC"
e_SBN="projects/$PROJECT_ID/regions/$REGION/subnetworks/$KUB_SBN"
#ip range for subnets
KUB_SBN_IP_RANGE="10.32.0.0/16"
VM_SBN_IP_RANGE="10.0.8.0/24"

############################################################################################################
## begin resources definition
############################################################################################################

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

# create GKE production ready cluster
gcloud beta container \
    --project $PROJECT_ID \
clusters create $CLUSTER_NAME \
    --region $REGION \
    --no-enable-basic-auth \
    --cluster-version $CLUSTER_VERSION \
    --machine-type "n1-standard-1" \
    --image-type "COS"  \
    --disk-type "pd-standard" \
    --disk-size "30" \
    --metadata disable-legacy-endpoints=true \
    --service-account $SA_EMAIL \
    --num-nodes "1" \
    --enable-stackdriver-kubernetes \
    --enable-ip-alias \
    --network $e_VPC \
    --subnetwork $e_SBN \
    --enable-intra-node-visibility \
    --default-max-pods-per-node "110" \
    --addons HorizontalPodAutoscaling,HttpLoadBalancing,Istio \
    --istio-config=auth=MTLS_PERMISSIVE \
    --enable-autoupgrade \
    --enable-autorepair \
    --maintenance-window "06:00" 

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

## Authenticate to new cluster
#gcloud beta container clusters get-credentials devops-k8s-gitops-001 --region us-central1 --project devops-trainee

# Install Helm
kubectl -n kube-system create sa tiller
kubectl create clusterrolebinding tiller-cluster-rule \
--clusterrole=cluster-admin \
--serviceaccount=kube-system:tiller
helm init --service-account tiller --wait

# cluster admin role binding

kubectl create clusterrolebinding "cluster-admin-$(whoami)" \
--clusterrole=cluster-admin \
--user="$(gcloud config get-value core/account)"

# create zone "istio" under Cloud DNS

gcloud dns managed-zones create \
--dns-name=$DOMAIN \
--description="Istio zone" "istio"

# watch dig +short NS $DOMAIN
# Configure nameservers on DNS

export GATEWAY_IP=$(kubectl -n istio-system get svc/istio-ingressgateway -ojson \
| jq -r .status.loadBalancer.ingress[0].ip)

#echo $GATEWAY_IP

# create necessary routes under CloudDNS, this is created using * wildcard
gcloud compute addresses create istio-gateway --addresses ${GATEWAY_IP} --region $REGION
gcloud dns record-sets transaction start --zone=$CLOUDDNS_ZONE
gcloud dns record-sets transaction add --zone=$CLOUDDNS_ZONE \
--name="${DOMAIN}" --ttl=300 --type=A ${GATEWAY_IP}
gcloud dns record-sets transaction add --zone=$CLOUDDNS_ZONE \
--name="www.${DOMAIN}" --ttl=300 --type=A ${GATEWAY_IP}
gcloud dns record-sets transaction add --zone=$CLOUDDNS_ZONE \
--name="*.${DOMAIN}" --ttl=300 --type=A ${GATEWAY_IP}
gcloud dns record-sets transaction execute --zone $CLOUDDNS_ZONE

# create and bind GCP SA to k8s SA
gcloud iam service-accounts create dns-admin \
--display-name=dns-admin \
--project=${PROJECT_ID}

gcloud iam service-accounts keys create ./gcp-dns-admin.json \
--iam-account=dns-admin@${PROJECT_ID}.iam.gserviceaccount.com \
--project=${PROJECT_ID}

gcloud projects add-iam-policy-binding ${PROJECT_ID} \
--member=serviceAccount:dns-admin@${PROJECT_ID}.iam.gserviceaccount.com \
--role=roles/dns.admin

kubectl create secret generic cert-manager-credentials \
--from-file=./gcp-dns-admin.json \
--namespace=istio-system

# install cert-manager for TLS with letsencrypt 
## it is extremely necessary to recreate Istio ingress gateway pods with "kubectl -n istio-system delete pods -l istio=ingressgateway"

CERT_REPO=https://raw.githubusercontent.com/jetstack/cert-manager
kubectl apply -f ${CERT_REPO}/release-0.7/deploy/manifests/00-crds.yaml
kubectl create namespace cert-manager
kubectl label namespace cert-manager certmanager.k8s.io/disable-validation=true
helm repo add jetstack https://charts.jetstack.io && \
helm repo update && \
helm upgrade -i cert-manager \
--namespace cert-manager \
--version v0.7.0 \
jetstack/cert-manager

#install flagger
REPO=https://raw.githubusercontent.com/weaveworks/flagger/master
kubectl apply -f ${REPO}/artifacts/gke/istio-gateway.yaml

## configuring certificates
# can be found under $REPO/certs
#issuer
# apiVersion: certmanager.k8s.io/v1alpha1
# kind: Issuer
# metadata:
#   name: letsencrypt-prod
#   namespace: istio-system
# spec:
#   acme:
#     server: https://acme-v02.api.letsencrypt.org/directory
#     email: eveuca@gmail.com
#     privateKeySecretRef:
#       name: letsencrypt-prod
#     dns01:
#       providers:
#       - name: cloud-dns
#         clouddns:
#           serviceAccountSecretRef:
#             name: cert-manager-credentials
#             key: gcp-dns-admin.json
#           project: devops-trainee

# apiVersion: certmanager.k8s.io/v1alpha1
# kind: Certificate
# metadata:
#   name: istio-gateway
#   namespace: istio-system
# spec:
#   secretName: istio-ingressgateway-certs
#   issuerRef:
#     name: letsencrypt-prod
#   commonName: "*.example.com"
#   acme:
#     config:
#     - dns01:
#         provider: cloud-dns
#       domains:
#       - "*.arakaki.in"
#       - "arakaki.in"

# See above "Recreate Istio ingress gateway pods"
#kubectl -n istio-system get pods -l istio=ingressgateway
#kubectl -n istio-system delete pods -l istio=ingressgateway


#Install Prometheus for telegraphy
## TODO: need to check version, 1.1.10-gke.0 is not working for this deploy
kubectl -n istio-system apply -f \
https://storage.googleapis.com/gke-release/istio/release/1.0.6-gke.3/patches/install-prometheus.yaml

#installing Flagger for canaryAnalysis
helm repo add flagger https://flagger.app
kubectl apply -f https://raw.githubusercontent.com/weaveworks/flagger/master/artifacts/flagger/crd.yaml

# upgrade flagger with Slack Webhook
helm upgrade -i flagger flagger/flagger \
--namespace=istio-system \
--set crd.create=false \
--set metricsServer=http://prometheus.istio-system:9090 \
--set slack.url=$SLACK_URL_WEBHOOK \
--set slack.channel=$SLACK_CHANNEL \
--set slack.user=$SLACK_USER

helm upgrade -i flagger-grafana flagger/grafana \
--namespace=istio-system \
--set url=http://prometheus.istio-system:9090 \
--set user=admin \
--set password=admin

## grafana virtual service
# apiVersion: networking.istio.io/v1alpha3
# kind: VirtualService
# metadata:
#   name: grafana
#   namespace: istio-system
# spec:
#   hosts:
#   - "grafana.arakaki.in"
#   gateways:
#   - public-gateway.istio-system.svc.cluster.local
#   http:
#   - route:
#     - destination:
#         host: flagger-grafana

# apiVersion: flagger.app/v1alpha3
# kind: Canary
# metadata:
#   name: podinfo
#   namespace: test
# spec:
#   # deployment reference
#   targetRef:
#     apiVersion: apps/v1
#     kind: Deployment
#     name: podinfo
#   # the maximum time in seconds for the canary deployment
#   # to make progress before it is rollback (default 600s)
#   progressDeadlineSeconds: 60
#   # HPA reference (optional)
#   autoscalerRef:
#     apiVersion: autoscaling/v2beta1
#     kind: HorizontalPodAutoscaler
#     name: podinfo
#   service:
#     # container port
#     port: 9898
#     # Istio gateways (optional)
#     gateways:
#     - public-gateway.istio-system.svc.cluster.local
#     # Istio virtual service host names (optional)
#     hosts:
#     - app.arakaki.in
#   canaryAnalysis:
#     # schedule interval (default 60s)
#     interval: 1m
#     # max number of failed metric checks before rollback
#     threshold: 5
#     # max traffic percentage routed to canary
#     # percentage (0-100)
#     maxWeight: 50
#     # canary increment step
#     # percentage (0-100)
#     stepWeight: 10
#     metrics:
#     - name: request-success-rate
#       # minimum req success rate (non 5xx responses)
#       # percentage (0-100)
#       threshold: 99
#       interval: 1m
#     - name: request-duration
#       # maximum req duration P99
#       # milliseconds
#       threshold: 500
#       interval: 30s
#     # testing (optional)
#     webhooks:
#       - name: acceptance-test
#         type: pre-rollout
#         url: http://flagger-loadtester.test/
#         timeout: 30s
#         metadata:
#           type: bash
#           cmd: "curl -sd 'test' http://podinfo-canary:9898/token | grep token"
#       - name: load-test
#         url: http://flagger-loadtester.test/
#         timeout: 5s
#         metadata:
#           cmd: "hey -z 1m -q 10 -c 2 http://podinfo-canary.test:9898/"