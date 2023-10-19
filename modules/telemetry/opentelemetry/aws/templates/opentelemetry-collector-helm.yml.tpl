nameOverride: "${name}"
mode: "daemonset"
presets:
  logsCollection:
    enabled: true
    includeCollectorLogs: true
  hostMetrics:
    enabled: false
  kubernetesAttributes:
    enabled: true
    extractAllPodLabels: true
    extractAllPodAnnotations: true
  kubeletMetrics:
    enabled: false
  kubernetesEvents:
    enabled: false
  clusterMetrics:
    enabled: false
config:
  exporters:
    splunk_hec:
      token: "${hec_token}"
      endpoint: "https://${hec_endpoint}:8088/services/collector"
      source: "otel"
      sourcetype: "otel"
      tls:
        insecure_skip_verify: true
  processors:
    resourcedetection:
      detectors:
        - system
  receivers:
    jaeger: null
    zipkin: null
  service:
    pipelines:
      logs:
        exporters:
          - splunk_hec
        processors:
          - memory_limiter
          - batch
          - resourcedetection
        receivers:
          - otlp
      metrics: null
      traces: null
