# Sciensa k8s bootstrapper 

## Overwall architechture

## How to use this repository
This section explain how to use this repository to bootstrap a production ready GKE cluster. Change values and script according to your needs, but keep in mind that the defaults are working properly and changes to scripts and YAML's might destroy the sinergy of the scripts.

### Clone the GCP bootstrapper repository 
```
REPO_URL="https://source.developers.google.com/p/devops-trainee/r/sciensa-kub-bootstrapper"
git clone $REPO_URL
cd sciensa-kub-bootstrapper
```
### Fill variables under resources/values.sh

| Parameter                | Description                                                                                                            | Example                                                                                                     |
|--------------------------|------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------|
| `PROJECT_ID`             | gcloud project id                                                                                                      | sandbox-251021                                                                                              |
| `CLUSTER_NAME`           | name of GKE cluster                                                                                                    | sciensa-kub-cluster-001                                                                                     |
| `REGION`                 | VPC region to host infra, OPTIONS = {"lowest_price":["us-central1", "us-west1", "us-east1"], "lowest_latency":["southamerica-east1"]}                                                                                              | us-central1  |
| `CLUSTER_VERSION`        | Kubernetes GKE version                                                                                                 | 1.13.7-gke.19                                                                                               |
| `VPC`                    | VPC name                                                                                                               | sciensa-vpc-001                                                                                             |
| `KUB_SBN`                | Kubernetes Subnet Name                                                                                                 | sciensa-subnet-kub                                                                                          |
| `VM_SBN`                 | VM Subnet Name                                                                                                         | sciensa-subnet-vm                                                                                           |
| `OWNER_EMAIL`            | owner email of the GCP account                                                                                         | everton.arakaki@soaexpert.com.br                                                                            |
| `SA_EMAIL`               | Use apiadmin if possible. GCP resource service account name formatted as <SANAME>@<projectid>.iam.gserviceaccount.com. | apiadmin@sandbox-251021.iam.gserviceaccount.com                                                             |
| `DOMAIN`                 | Domain name for the Kubernetes Gateway                                                                                 | evertonarakaki.tk                                                                                           |
| `CLOUDDNS_ZONE`          | CloudDNS Zone Name for Domain. There is no need to change it.                                                          | istio                                                                                                       |
| `SLACK_URL_WEBHOOK`      | https://lmgtfy.com/?q=how+to+get+slack+webhook+url                                                                     |                                                                                                             |
| `SLACK_CHANNEL`          | Slack channel                                                                                                          | projecto-cliente-nuevo                                                                                      |
| `SLACK_USER`             | Slack user                                                                                                             | flagger                                                                                                     |

### Run main provisioner script

If you use dot.tk or freenon.com domain names, make sure to uncomment line 20 at  file `resourses/gke-addons/install-cert-manager-gke.sh`. This will set cert-manager pods to use a different DNS (80.80.80.80 and 80.80.81.81).

To provision the cluster and other necessary resources, use the bellow script. 
```
resources/create_kubernetes_gcp.sh
```

### Create Ingress Gateway Letsencrypt certificate and configure DNS

#### Confige DNS
Under CloudDNS, go to the created zone and copy the nameservers created for your domain:

    ns-cloud-c1.googledomains.com.
    ns-cloud-c2.googledomains.com.
    ns-cloud-c3.googledomains.com.
    ns-cloud-c4.googledomains.com.

Edit your domain provider to use the nameservers gathered previusly. 

#### Gateway certificate
Edit file `resourses/tmp/ssl-certificates/10-istio-gateway-cert.yaml`, changing `commonName` and `domains` entries with your domain information:
```
apiVersion: certmanager.k8s.io/v1alpha1
kind: Certificate
metadata:
  name: istio-gateway
  namespace: istio-system
spec:
  secretName: istio-ingressgateway-certs
  issuerRef:
    name: letsencrypt-prod
  commonName: "*.YOURDOMAIN.COM"
  acme:
    config:
    - dns01:
        provider: cloud-dns
      domains:
      - "*.YOURDOMAIN.COM"
      - "YOURDOMAIN.COM"
```
This is a wildcarded certificate, meaning that all subdomains connections will be wrapped with TLS using one and only one certificate. 
use `kubectl -n istio-system get certificates` to check certificate progress, when the certificate is Ready, use `kubectl -n istio-system delete pods -l istio=ingressgateway` to kill the ingress pod and renew secrets. 

To debug possible errors, use: 
```
kubectl -n cert-manager get pods
kubectl -n cert-manager logs -f <cert-manager-xxxxxx-xxxxxxx>
```

### Create Kubernetes Namespaces
```
cd ../
kubectl apply -f template-manifests/00-namespaces
```
ouput:
```
namespace/cid created
namespace/dev created
namespace/ite created
namespace/log created
namespace/mon created
namespace/prd created
```
### Create Monitoring Objects

```
source ./resourses/values.sh
kubectl apply -f template-manifests/mon-template-manifests/istio-sidecar
template-manifests/mon-template-manifests/00-alertmanager/00-alertmanager-configmap.sh
kubectl apply -f template-manifests/mon-template-manifests/00-alertmanager
template-manifests/mon-template-manifests/01-prometheus/03-prometheus-storage.sh
kubectl apply -f template-manifests/mon-template-manifests/01-prometheus
kubectl apply -f template-manifests/mon-template-manifests/02-kube-state-metrics
kubectl apply -f template-manifests/mon-template-manifests/03-node-exporter
kubectl apply -f template-manifests/mon-template-manifests/04-grafana
```

Watch under Google Kubernetes Engine Workload dashboard if the objects are correctly created. 

##### Configure Grafana

###### Edit Istio Virtual Service Grafana file
There is an example file under ```sciensa-kub-bootstrapper/resourses/tmp/istio-virtual-services/grafana-mon-vs.yaml```. Edit this file according to your domain info and apply using ```kubectl apply -f sciensa-kub-bootstrapper/resourses/tmp/istio-virtual-services/grafana-mon-vs.yaml ```. This will deploy a subdomain under the SLD and you can access it using `https://grafana-mon.<yourdomain>.<yourSLD>`.
###### Configure Grafana DS
Open your browser at `https://grafana-mon.<yourdomain>.<yourSLD>` and login as admin:admin. Change the default admin password and store safely (prefer to use Vault, but Keepass is also an option). Click `Add Datasource` > `Prometheus` and fill the following values:

| Parameter | Value                          |
|-----------|--------------------------------|
| Name      | prometheus.mon                 |
| HTTP.URL  | http://prometheus-service:8080 |

###### Import Grafana Dashboards
Under Grafana dashboard, click the `+` sign and select `Import` option. There is a lots of examples in `/sciensa-kub-bootstrapper/resourses/tmp/grafana-dashboards`. Import then using copy and paste and you are ready to go.

### Create Logging Objects
```
kubectl apply -f template-manifests/log-template-manifests/istio-sidecar
kubectl apply -f template-manifests/log-template-manifests/00-elasticsearch
kubectl apply -f template-manifests/log-template-manifests/10-fluentd
kubectl apply -f template-manifests/log-template-manifests/20-kibana
```

### Create CI/CD (CID) Objects
```

```

for harbor, only!!! this is beta, TODO: add persistent storage 
links: https://ruzickap.github.io/k8s-knative-gitlab-harbor/part-04/
```
export CLUSTER_NAME="sciensa-kub-cluster-001"
export DOMAIN="evertonarakaki.tk"
template-manifests/cid-template-manifests/00-harbor/install-harbor-container-registry.sh
```

export DOMAIN="evertonarakaki.tk"
export CLUSTER_NAME="sciensa-kub-cluster-001"


## Operators manual

Shutdown cluster:
```
gcloud container clusters resize sciensa-kub-cluster-001 --num-nodes=0 --region=us-central1 --node-pool=default-pool
gcloud container clusters resize sciensa-kub-cluster-001 --num-nodes=0 --region=us-central1 --node-pool=pool-horizontal-autoscaling
```

Turn on cluster:
```
gcloud container clusters resize sciensa-kub-cluster-001 --num-nodes=1 --region=us-central1 --node-pool=default-pool
gcloud container clusters resize sciensa-kub-cluster-001 --num-nodes=1 --region=us-central1 --node-pool=pool-horizontal-autoscaling
```

Interesting alias:
```
alias klog="kubectl -n log"
alias kmon="kubectl -n mon"
alias kcid="kubectl -n cid"
alias kdev="kubectl -n dev"
alias kite="kubectl -n ite"
alias kprd="kubectl -n prd"
```

Force Deployment/Statefulset update without deleting
```
kmon patch deployments prometheus-deployment -p  "{\"spec\":{\"template\":{\"metadata\":{\"annotations\":{\"dummy-date\":\"`date +'%s'`\"}}}}}"
```

Reset Grafana admin password to admin:
```
kmon get pods
kmon exec -it <grafana-pod> -c grafana -- /bin/bash
grafana-cli admin reset-admin-password admin
```

https://gist.github.com/pydevops/cffbd3c694d599c6ca18342d3625af97