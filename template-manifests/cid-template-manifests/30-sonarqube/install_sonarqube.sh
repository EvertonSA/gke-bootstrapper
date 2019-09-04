export POSTGRES_PASSWORD=$(kubectl get secret --namespace cid database-psql-cid-postgresql -o jsonpath="{.data.postgresql-password}" | base64 --decode)


helm install --name sonarqube --namespace cid \
  --set service.type=ClusterIP \
  --set database.type=postgresql \
  --set postgresql.enabled=false \
  --set postgresql.postgresServer=database-psql-cid-postgresql.cid.svc.cluster.local \
  --set postgresql.postgresUser=postgres \
  --set postgresql.postgresPassword=${POSTGRES_PASSWORD} \
  stable/sonarqube