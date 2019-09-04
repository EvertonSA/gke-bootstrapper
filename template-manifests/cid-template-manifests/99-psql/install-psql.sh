#fist install postgress
echo "--------------------------------------------------INSTALL POSTGRES--------------------------------------------------"
helm install --name database-container-registry -f ./pg-prod-values.yaml --namespace cid stable/postgresql
