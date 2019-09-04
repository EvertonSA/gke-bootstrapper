export POSTGRES_PASSWORD=$(kubectl get secret --namespace cid database-psql-cid-postgresql -o jsonpath="{.data.postgresql-password}" | base64 --decode)


helm install --name sonarqube --namespace cid \
  --set service.type=clusterIP \
  --postgresql.enabled=false \
  --postgresql.postgresServer=database-psql-cid-postgresql.cid.svc.cluster.local \
  --postgresql.postgresUser=postgres \
  --postgresql.postgresPassword=${POSTGRES_PASSWORD} \
  stable/sonarqube