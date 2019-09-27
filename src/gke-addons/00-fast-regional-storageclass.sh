kubectl apply -f - <<EOF
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: fst-${REGION}-${ZONE_POSFIX_1}-${ZONE_POSFIX_2}
provisioner: kubernetes.io/gce-pd
allowVolumeExpansion: true
parameters:
  type: pd-ssd
  replication-type: regional-pd
  zones: ${REGION}-${ZONE_POSFIX_1},${REGION}-${ZONE_POSFIX_2}
EOF