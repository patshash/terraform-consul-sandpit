server:
  name: server
  extraFlags:
    - web.enable-remote-write-receiver
  service:
    type: LoadBalancer
alertmanager:
  enabled: false
kube-state-metrics:
  enabled: true
prometheus-node-exporter:
  enabled: true
prometheus-pushgateway:
  enabled: false