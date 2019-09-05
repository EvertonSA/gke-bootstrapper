###################################################################
#Script Name	: install-cert-manager.sh
#Description	: install cert manager
#Args          	: no args needed, but env variables are a must
#Author       	: Everton Seiei Arakaki
#Email         	: eveuca@gmail.com
###################################################################

CERT_REPO=https://raw.githubusercontent.com/jetstack/cert-manager
# apply custom resources definition, REALLY important
kubectl apply -f ${CERT_REPO}/release-0.10/deploy/manifests/00-crds.yaml

# create ns
kubectl create namespace cert-manager
kubectl label namespace cert-manager certmanager.k8s.io/disable-validation=true
helm repo add jetstack https://charts.jetstack.io
helm install --wait --name cert-manager --namespace cert-manager jetstack/cert-manager

#for .tk domains
kubectl patch deployment cert-manager -n cert-manager -p '{"spec":{"template":{"spec":{"containers":[{"name":"cert-manager","args":["--v=2","--cluster-resource-namespace=$(POD_NAMESPACE)","--leader-election-namespace=$(POD_NAMESPACE)","--dns01-recursive-nameservers=80.80.80.80:53","--dns01-recursive-nameservers=80.80.81.81:53"]}]}}}}'