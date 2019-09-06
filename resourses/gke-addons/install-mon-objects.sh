kubectl apply -f ../template-manifests/mon-template-manifests/istio-sidecar
kubectl apply -f ../template-manifests/mon-template-manifests/00-alertmanager
kubectl apply -f ../template-manifests/mon-template-manifests/01-prometheus
kubectl apply -f ../template-manifests/mon-template-manifests/02-kube-state-metrics
kubectl apply -f ../template-manifests/mon-template-manifests/03-node-exporter
#kubectl apply -f ../template-manifests/mon-template-manifests/04-grafana