#fist install postgress
echo "--------------------------------------------------INSTALL POSTGRES--------------------------------------------------"
helm install --wait --timeout 600 --name database-psql-cid -f $1 --namespace cid stable/postgresql
