# Sciensa k8s bootstrapper

## Overwall architechture

## How to use this repository
This section explain how to use this repository to bootstrap a production ready GKE cluster. Change values and script according to your needs, but keep in mind that the defaults are working properly and changes to scripts and YAML's might destroy the sinergy of the scripts.

### Clone the GCP bootstrapper repository

It is required t use Google Cloud Shell!!! 

```
REPO_URL="https://bitbucket.org/sciensa/gke-bootstrapper/"
git clone $REPO_URL
cd gke-bootstrapper
```
### Fill variables under resources/values.sh

| Parameter                | Description                                                                                                            | Example                                                                                                     |
|--------------------------|------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------|
| `PROJECT_ID`             | gcloud project id                                                                                                      | sandbox-251021                                                                                              |
| `CLUSTER_NAME`           | name of GKE cluster                                                                                                    | sciensa-kub-cluster-001                                                                                     |
| `REGION`                 | VPC region to host infra, OPTIONS = {"lowest_price":["us-central1", "us-west1", "us-east1"], "lowest_latency":["southamerica-east1"]}                                                                                              | us-central1  |
| `OWNER_EMAIL`            | owner email of the GCP account                                                                                         | everton.arakaki@soaexpert.com.br                                                                            |
| `SLACK_URL_WEBHOOK`      | https://lmgtfy.com/?q=how+to+get+slack+webhook+url                                                                     |                                                                                                             |
| `SLACK_CHANNEL`          | Slack channel                                                                                                          | sciensaflix                                                                                      |
| `SLACK_USER`             | Slack user                                                                                                             | flagger                                                                                                     |

### Run main provisioner script

To provision the cluster and other necessary resources, use the bellow script.
```
resources/create_kubernetes_gcp.sh
```

It might take 5-10 minutes for your infra to be running + all objects to be provisioned.


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
##### Configure Grafana

###### Edit Istio Virtual Service Grafana file
There is an example file under ```sciensa-kub-bootstrapper/resourses/tmp/istio-virtual-services/grafana-mon-vs.yaml```. Edit this file according to your domain info and apply using ```kubectl apply -f sciensa-kub-bootstrapper/resourses/tmp/istio-virtual-services/grafana-mon-vs.yaml ```. This will deploy a subdomain under the SLD and you can access it using `https://grafana-mon.<yourdomain>.<yourSLD>`.

###### Configure Grafana Datasource
Open your browser at `https://grafana-mon.<yourdomain>.<yourSLD>` and login as admin:admin. Change the default admin password and store safely (prefer to use Vault, but Keepass is also an option). Click `Add Datasource` > `Prometheus` and fill the following values:

| Parameter | Value                          |
|-----------|--------------------------------|
| Name      | prometheus.mon                 |
| HTTP.URL  | http://prometheus-service:8080 |

###### Import Grafana Dashboards
Under Grafana dashboard, click the `+` sign and select `Import` option. There is a lots of examples in `/sciensa-kub-bootstrapper/resourses/tmp/grafana-dashboards`. Import then using copy and paste and you are ready to go.

###### Configure Jenkins to deploy to Kubernetes

When creating a new pipeline, use `Setup Kubernetes CLI (kubectl)` plugin to deploy to the kubernetes cluster. You will need to configure a credential. See bellow how to configure the credential.

####### Create a ServiceAccount named `jenkins-dev-robot` in a given namespace.
```
kubectl -n dev create serviceaccount jenkins-dev-robot
kubectl -n ite create serviceaccount jenkins-ite-robot
kubectl -n prd create serviceaccount jenkins-prd-robot
```
####### The next line gives `jenkins-robot` administator permissions for this namespace.
```
kubectl -n dev create rolebinding jenkins-dev-robot-binding --clusterrole=cluster-admin --serviceaccount=jenkins-dev-robot
kubectl -n ite create rolebinding jenkins-ite-robot-binding --clusterrole=cluster-admin --serviceaccount=jenkins-ite-robot
kubectl -n prd create rolebinding jenkins-prd-robot-binding --clusterrole=cluster-admin --serviceaccount=jenkins-prd-robot
```
####### Get the name of the token that was automatically generated for the ServiceAccount `jenkins-robot`.
```
kubectl -n dev get serviceaccount jenkins-dev-robot -o go-template --template='{{range .secrets}}{{.name}}{{"\n"}}{{end}}'
kubectl -n ite get serviceaccount jenkins-ite-robot -o go-template --template='{{range .secrets}}{{.name}}{{"\n"}}{{end}}'
kubectl -n prd get serviceaccount jenkins-prd-robot -o go-template --template='{{range .secrets}}{{.name}}{{"\n"}}{{end}}'
```
####### Retrieve the token and decode it using base64.
```
kubectl -n <NAMESPACE> get secrets <SECRETNAME> -o go-template --template '{{index .data "token"}}' | base64 -D
```

On Jenkins, navigate in the folder you want to add the token in, or go on the main page. Then click on the "Credentials" item in the left menu and find or create the "Domain" you want. Finally, paste your token into a Secret text credential. The ID is the credentialsId you need to use in the plugin configuration.


### Building block - Create Harbor Container Registry

TODO: descrever e testar
```
```

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