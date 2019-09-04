# echo "--------------------------------------------------Get redis and psql secrets--------------------------------------------------"
export POSTGRES_PASSWORD=$(kubectl get secret --namespace cid database-container-registry-postgresql -o jsonpath="{.data.postgresql-password}" | base64 --decode)
export REDIS_PASSWORD=$(kubectl get secret --namespace cid cache-container-registry-redis -o jsonpath="{.data.redis-password}" | base64 --decode)

echo "--------------------------------------------------INSTALL KUBED--------------------------------------------------"
helm repo add appscode https://charts.appscode.com/stable/
helm repo update

helm install appscode/kubed --name kubed --version 0.10.0 --namespace kube-system --wait \
  --set apiserver.enabled=false \
  --set config.clusterName=$CLUSTER_NAME

kubectl label namespace cid app=kubed

kubectl annotate secret istio-ingressgateway-certs -n istio-system kubed.appscode.com/sync="app=kubed"

echo "--------------------------------------------------INSTALL CR ISTIO GATEWAY --------------------------------------------------"

cat << EOF | kubectl apply -f -
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: harbor-gateway
  namespace: cid
spec:
  selector:
    istio: ingressgateway
  servers:
  - port:
      number: 80
      name: http-harbor
      protocol: HTTP
    hosts:
    - harbor.${DOMAIN}
  - port:
      number: 443
      name: https-harbor
      protocol: HTTPS
    hosts:
    - harbor.${DOMAIN}
    - notary.${DOMAIN}
    tls:
      mode: PASSTHROUGH
---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: harbor-http-virtual-service
  namespace: cid
spec:
  hosts:
  - harbor.${DOMAIN}
  gateways:
  - harbor-gateway
  http:
  - match:
    - port: 80
    route:
    - destination:
        host: harbor.cid.svc.cluster.local
        port:
          number: 80
---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: harbor-https-virtual-service
  namespace: cid
spec:
  hosts:
  - harbor.${DOMAIN}
  gateways:
  - harbor-gateway
  tls:
  - match:
    - port: 443
      sniHosts:
      - harbor.${DOMAIN}
    route:
    - destination:
        host: harbor.cid.svc.cluster.local
        port:
          number: 443
---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: harbor-notary-virtual-service
  namespace: cid
spec:
  hosts:
  - notary.${DOMAIN}
  gateways:
  - harbor-gateway
  tls:
  - match:
    - port: 443
      sniHosts:
      - notary.${DOMAIN}
    route:
    - destination:
        host: harbor.cid.svc.cluster.local
        port:
          number: 4443
EOF

echo "--------------------------------------------------INSTALL HARBOR--------------------------------------------------"
helm repo add harbor https://helm.goharbor.io
helm install --name harbor --namespace cid \
    --version v1.1.2 \
    --set expose.type=clusterIP \
    --set expose.tls.enabled=true \
    --set expose.tls.secretName=istio-ingressgateway-certs \
    --set persistence.enabled=true \
    --set imagePullPolicy=Always \
    --set externalURL=https://harbor.${DOMAIN} \
    --set harborAdminPassword=admin \
    --set database.type=external \
    --set database.external.host=database-psql-cid-postgresql.cid.svc.cluster.local \
    --set database.external.username=postgres\
    --set database.external.password=$POSTGRES_PASSWORD \
    --set redis.type=external \
    --set redis.external.host=cache-cid-redis-master.cid.svc.cluster.local \
    --set redis.external.password=$REDIS_PASSWORD \
    harbor/harbor
