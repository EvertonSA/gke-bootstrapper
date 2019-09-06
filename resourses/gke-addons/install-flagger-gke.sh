###################################################################
#Script Name	: install-flagger-gke.sh                                                                                  
#Description	: install flagger and configure it to manage istio gateway 
#                 and also install prometheus and grafana for canary analisys                                                                                  
#Args          	: no args needed, but env variables are a must 
#Author       	: Everton Seiei Arakaki                                                
#Email         	: eveuca@gmail.com                                           
###################################################################

#Install Prometheus for telegraphy
## TODO: need to check version, 1.1.10-gke.0 is not working for this deployment
kubectl -n istio-system apply -f \
https://storage.googleapis.com/gke-release/istio/release/1.0.6-gke.3/patches/install-prometheus.yaml

#installing Flagger for canaryAnalysis
helm repo add flagger https://flagger.app
kubectl apply -f https://raw.githubusercontent.com/weaveworks/flagger/master/artifacts/flagger/crd.yaml

# upgrade flagger with Slack Webhook
helm upgrade -i flagger flagger/flagger \
--namespace=istio-system \
--set crd.create=false \
--set metricsServer=http://prometheus.istio-system:9090 \
--set slack.url=$SLACK_URL_WEBHOOK \
--set slack.channel=$SLACK_CHANNEL \
--set slack.user=$SLACK_USER

helm upgrade -i flagger-grafana flagger/grafana \
--namespace=istio-system \
--set url=http://prometheus.istio-system:9090 \
--set user=admin \
--set password=admin