#fist install postgress
echo "--------------------------------------------------INSTALL POSTGRES--------------------------------------------------"
helm install --name database-psql-cid -f ./pg-cid-values.yaml --namespace cid stable/postgresql
