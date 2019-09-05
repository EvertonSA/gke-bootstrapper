#fist install postgress
echo "--------------------------------------------------INSTALL POSTGRES--------------------------------------------------"
helm install --wait --timeout 600 --name database-psql-cid -f ./pg-cid-values.yaml --namespace cid stable/postgresql
