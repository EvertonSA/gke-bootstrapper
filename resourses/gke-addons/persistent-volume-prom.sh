kubectl apply -f - <<EOF
apiVersion: "v1"
kind: "PersistentVolume"
metadata:
  name: prom-fst-pv
  labels:
    pv-type: fst-pv
spec:
  capacity:
    storage: ${PROM_PV_SIZE}
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: fst-${REGION}-${ZONE_POSFIX_1}-${ZONE_POSFIX_2}
  gcePersistentDisk:
    fsType: ext4
    pdName: fst-volume
EOF

# ---
# apiVersion: "v1"
# kind: "PersistentVolume"
# metadata:
#   name: std-pv
#   labels:
#     pv-type: std-pv
# spec:
#   capacity:
#     storage: ${STD_PV_SIZE}
#   accessModes:
#     - ReadWriteOnce
#   persistentVolumeReclaimPolicy: Retain
#   storageClassName: std-${REGION}-${ZONE_POSFIX_1}-${ZONE_POSFIX_2}
#   gcePersistentDisk:
#     fsType: ext4
#     pdName: fst-volume