# Sciensa ha-k8s-canary bootstrapper 

![Progressive Delivery GitOps Pipeline](https://raw.githubusercontent.com/weaveworks/flagger/master/docs/diagrams/flagger-gitops-istio.png)

Components:

* **Istio** service mesh
    * manages the traffic flows between microservices, enforcing access policies and aggregating telemetry data
* **Prometheus** monitoring system  
    * time series database that collects and stores the service mesh metrics
* **Helm Operator** CRD controller
    * automates Helm chart releases
* **Flagger** progressive delivery operator
    * automates the promotion of canary deployments using Istio routing for traffic shifting and Prometheus metrics for canary analysis

### Prerequisites

read file
```bash
resourses/bundled_cluster.sh
```

TO BE DONE