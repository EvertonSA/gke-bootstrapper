###################################################################
#Script Name	: install-helm-gke.sh                                                                                  
#Description	: install helm                                                                                  
#Args          	: no args needed, but env variables are a must 
#Author       	: Everton Seiei Arakaki                                                
#Email         	: eveuca@gmail.com                                           
###################################################################

# Install Helm
kubectl -n kube-system create sa tiller
kubectl create clusterrolebinding tiller-cluster-rule \
--clusterrole=cluster-admin \
--serviceaccount=kube-system:tiller
helm init --service-account tiller --wait
