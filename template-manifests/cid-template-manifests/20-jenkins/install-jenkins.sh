helm install --name jenkins --namespace cid \
  --set master.adminUser=admin \
  --set master.serviceType=ClusterIP \
  --set master.slaveKubernetesNamespace=cid \
  stable/jenkins