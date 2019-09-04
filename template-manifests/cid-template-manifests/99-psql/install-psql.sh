#fist install postgress
echo "--------------------------------------------------INSTALL POSTGRES--------------------------------------------------"
helm install --name database-psql-cid -f ./pg-prod-values.yaml --namespace cid stable/postgresql
