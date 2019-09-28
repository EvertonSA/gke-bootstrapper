###################################################################
#Script Name	: install-istio-gke.sh
#Description	: This file is to be loaded by the main provisioner script
#Args          	: no args needed, but need to be filled in before hand
#Author       	: Everton Seiei Arakaki
#Email         	: eveuca@gmail.com
###################################################################

# Istio namespace
kubectl create namespace istio-system

# istio init CRD
helm template ./gke-addons/istio-init \
  --name istio-init --namespace istio-system | kubectl apply -f -

# Istio objects
helm template ./gke-addons/istio \
  --name istio --namespace istio-system | kubectl apply -f -