# Sciensa k8s bootstrapper 

## Overwall architechture

## How to use this repo

REPO_URL=xxxx
git clone xxxx

cd xxxx


### fill variables under values.sh

| Parameter                | Description                                                                                                            | Example                                                                                                     |
|--------------------------|------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------|
| `PROJECT_ID`             | gcloud project id                                                                                                      | sandbox-251021                                                                                              |
| `CLUSTER_NAME`           | name of GKE cluster                                                                                                    | sciensa-kub-cluster-001                                                                                     |
| `REGION`                 | VPC region to host infra                                                                                               | OPTIONS = {"lowest_price":["us-central1", "us-west1", "us-east1"], "lowest_latency":["southamerica-east1"]} |
| `CLUSTER_VERSION`        | Kubernetes GKE version                                                                                                 | 1.13.7-gke.19                                                                                               |
| `VPC`                    | VPC name                                                                                                               | sciensa-vpc-001                                                                                             |
| `KUB_SBN`                | Kubernetes Subnet Name                                                                                                 | sciensa-subnet-kub                                                                                          |
| `VM_SBN`                 | VM Subnet Name                                                                                                         | sciensa-subnet-vm                                                                                           |
| `OWNER_EMAIL`            | owner email of the GCP account                                                                                         | everton.arakaki@soaexpert.com.br                                                                            |
| `SA_EMAIL`               | Use apiadmin if possible. GCP resource service account name formatted as <SANAME>@<projectid>.iam.gserviceaccount.com. | apiadmin@sandbox-251021.iam.gserviceaccount.com                                                             |
| `DOMAIN`                 | Domain name for the Kubernetes Gateway                                                                                 | evertonarakaki.tk                                                                                           |
| `CLOUDDNS_ZONE`          | CloudDNS Zone Name for Domain. There is no need to change it.                                                          | istio                                                                                                       |
| `PROMETHEUS_SSD_SIZE`    | Prometheus disk size. Default is 50GB, and in free quota, you can only have 100GB pd-ssd per region.                   | 50                                                                                                          |
| `ELASTICSEARCH_SSD_SIZE` | Elasticsearch disk size. Default is 50GB, and in free quota, you can only have 100GB pd-ssd per region.                | 50                                                                                                          |
| `SLACK_URL_WEBHOOK`      | https://lmgtfy.com/?q=how+to+get+slack+webhook+url                                                                     |                                                                                                             |
| `SLACK_CHANNEL`          | Slack channel                                                                                                          | projecto-cliente-nuevo                                                                                      |
| `SLACK_USER`             | Slack user                                                                                                             | flagger                                                                                                     |

### Run main provisioner script

To provision the cluster and other necessary resources, use the bellow script. 

`cd resources`
`./create_kubernetes_gcp.sh`

This will create the following components

............

TO BE DONE

prometheus backend:  http://prometheus-service:8080

lembrar de falar de disco, tamanho de disco preço de disco


## Operators manual

Shutdown cluster:
gcloud container clusters resize sciensa-kub-cluster-001 --num-nodes=0 --region=us-central1 --node-pool=default-pool
gcloud container clusters resize sciensa-kub-cluster-001 --num-nodes=0 --region=us-central1 --node-pool=pool-horizontal-autoscaling

Turn on cluster:
gcloud container clusters resize sciensa-kub-cluster-001 --num-nodes=1 --region=us-central1 --node-pool=default-pool