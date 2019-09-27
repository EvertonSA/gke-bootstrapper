###################################################################
#Script Name	: install-istio-gke.sh
#Description	: This file is to be loaded by the main provisioner script
#Args          	: no args needed, but need to be filled in before hand
#Author       	: Everton Seiei Arakaki
#Email         	: eveuca@gmail.com
###################################################################

# download istio
curl -L https://git.io/getLatestIstio | ISTIO_VERSION=${ISTIO_VERSION} sh -

# 
export PATH=$PWD/bin:$PATH
kubectl create namespace istio-system