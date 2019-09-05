# echo "--------------------------------------------------INSTALL REDIT--------------------------------------------------"
helm install --wait --timeout 600 --name cache-cid --namespace cid stable/redis
