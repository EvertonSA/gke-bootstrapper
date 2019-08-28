# see https://vocon-it.com/2019/03/04/kubernetes-9-installing-elasticsearch-using-helm-charts/

# RELEASE=elasticsearch
# REPLICAS=1
# MIN_REPLICAS=1
# #helm ls --all ${RELEASE} && helm del --purge ${RELEASE}

# helm install stable/elasticsearch \
#       --set client.replicas=${MIN_REPLICAS} \
#       --set master.replicas=${REPLICAS} \
#       --set master.persistence.storageClass=fast \
#       --set master.persistence.size=8Gi \
#       --set data.replicas=${MIN_REPLICAS} \
#       --set data.persistence.storageClass=fast \
#       --set data.persistence.size=40Gi \
#       --set master.podDisruptionBudget.minAvailable=${MIN_REPLICAS} \
#       --set cluster.env.MINIMUM_MASTER_NODES=${MIN_REPLICAS} \
#       --set cluster.env.RECOVER_AFTER_MASTER_NODES=${MIN_REPLICAS} \
#       --set cluster.env.EXPECTED_MASTER_NODES=${MIN_REPLICAS} \
#       --namespace log

# helm repo add elastic https://helm.elastic.co
# helm template --name elasticsearch elastic/elasticsearch


# kubectl apply -f https://download.elastic.co/downloads/eck/0.9.0/all-in-one.yaml

# cat <<EOF | kubectl apply -f -
# apiVersion: elasticsearch.k8s.elastic.co/v1alpha1
# kind: Elasticsearch
# metadata:
#   name: quickstart
# spec:
#   version: 7.2.0
#   nodes:
#   - nodeCount: 2
#     config:
#       node.master: true
#       node.data: true
#       node.ingest: true
# EOF