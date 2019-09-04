kubectl apply -f - <<EOF
kind: ConfigMap
apiVersion: v1
metadata:
  name: alertmanager
  namespace: mon
data:
  config.yml: |-
    global:
      resolve_timeout: 5m
      slack_api_url: '${SLACK_URL_WEBHOOK}'
    templates:
    - '/etc/alertmanager-templates/*.tmpl'
    route:
      group_by: ['alertname', 'cluster', 'service']
      group_wait: 10s
      group_interval: 1m
      repeat_interval: 5m
      receiver: default
      routes:
      - match:
          team: devops
        receiver: devops
        continue: true
      - match:
          team: dev
        receiver: dev
        continue: true
    receivers:
    - name: 'default'
    - name: 'devops'
      slack_configs:
      - channel: '${SLACK_CHANNEL}'
        send_resolved: true
    - name: 'dev'
      slack_configs:
      - channel: '${SLACK_CHANNEL}'
        send_resolved: true
EOF