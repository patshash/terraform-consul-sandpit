server:
  name: server
  extraFlags:
    - web.enable-remote-write-receiver
  service:
    type: LoadBalancer
alertmanager:
  enabled: false
kube-state-metrics:
  enabled: false
prometheus-node-exporter:
  enabled: false
prometheus-pushgateway:
  enabled: false