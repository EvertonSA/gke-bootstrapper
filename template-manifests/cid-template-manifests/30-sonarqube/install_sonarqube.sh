export POSTGRES_PASSWORD=$(kubectl get secret --namespace cid database-psql-cid-postgresql -o jsonpath="{.data.postgresql-password}" | base64 --decode)
echo ${POSTGRES_PASSWORD}

helm install --name cid --namespace cid \
  --set image.tag=6.7.7-community \
  --set service.type=ClusterIP \
  --set database.type=postgresql \
  --set postgresql.enabled=false \
  --set postgresql.postgresServer=database-psql-cid-postgresql.cid.svc.cluster.local \
  --set postgresql.postgresUser=postgres \
  --set postgresql.postgresDatabase=sonardb \
  --set postgresql.service.port=5432 \
  --set postgresql.postgresPassword=${POSTGRES_PASSWORD} \
  stable/sonarqube