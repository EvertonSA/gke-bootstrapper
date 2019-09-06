echo "--------------------------------------------------INSTALL GRAFANA--------------------------------------------------"

kubectl create configmap -n mon grafana-dashboard-1 --from-file=./tmp/grafana-dashboards/app-dash-min.json
kubectl label configmap -n mon grafana-dashboard-1 grafana_dashboard=1

kubectl create configmap -n mon grafana-dashboard-2 --from-file=./tmp/grafana-dashboards/cluster-dash-min.json
kubectl label configmap -n mon grafana-dashboard-2 grafana_dashboard=2

kubectl create configmap -n mon grafana-dashboard-3 --from-file=./tmp/grafana-dashboards/deploy-dash-min.json
kubectl label configmap -n mon grafana-dashboard-3 grafana_dashboard=3

kubectl create configmap -n mon grafana-dashboard-4 --from-file=./tmp/grafana-dashboards/node-dash-min.json
kubectl label configmap -n mon grafana-dashboard-4 grafana_dashboard=4


kubectl apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: grafana-datasource
  namespace: mon
  labels:
     grafana_datasource: '1'
type: Opaque
stringData:
  datasource.yaml: |-
    apiVersion: 1
    deleteDatasources:
      - name: Prometheus
        orgId: 1
    datasources:
      - name: Prometheus
        orgId: 1
        type: prometheus
        access: proxy
        url: http://prometheus-service:8080
        basicAuth: false
EOF

helm install --name grafana --namespace mon \
    --set sidecar.dashboards.enabled=true \
    --set sidecar.dashboards.provider.folder=GKE \
    --set sidecar.dashboards.provider.disableDelete=true \
    --set sidecar.dashboards.searchNamespace=mon \
    --set sidecar.datasources.enabled=true \
    --set sidecar.datasources.searchNamespace=mon \
    stable/grafana
