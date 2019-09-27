curl -L https://git.io/getLatestIstio | sh -
mv istio-* istio
export PATH=$PWD/istio/bin:$PATH
kubectl apply -f ./istio/install/kubernetes/helm/istio/templates/crds.yaml
mkdir istio-gke-templates
helm template ./istio/install/kubernetes/helm/istio --name istio --namespace istio-system > istio-gke-templates/istio.yaml

kubectl create namespace istio-system
kubectl apply -f istio-gke-templates/istio.yaml