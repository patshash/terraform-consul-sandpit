splunk-operator:
  enabled: true
sva:
  s1:
    enabled: true
    standalones: 1
standalone:
  serviceTemplate:
    spec:
      type: LoadBalancer
  defaults:
    splunk:
      http_enableSSL: 1