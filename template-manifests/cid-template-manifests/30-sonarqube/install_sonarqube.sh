helm install --name sonarqube --namespace cid \
  --set service.type=clusterIP \
  
  stable/sonarqube

helm install --name jenkins --namespace cid \
  --set master.adminUser=admin \
  --set master.adminPassword=admin \
  --set master.serviceType=clusterIP \
  --set master.slaveKubernetesNamespace=cid