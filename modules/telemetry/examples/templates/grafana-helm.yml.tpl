service:
  type: LoadBalancer
adminUser: admin
adminPassword: ${admin_password}
# Provision kubernetes dashboards from https://github.com/dotdc/grafana-dashboards-kubernetes
dashboardProviders:
  dashboardproviders.yaml:
    apiVersion: 1
    providers:
    - name: 'grafana-dashboards-kubernetes'
      orgId: 1
      folder: 'Kubernetes'
      type: file
      disableDeletion: true
      editable: true
      options:
        path: /var/lib/grafana/dashboards/grafana-dashboards-kubernetes
dashboards:
  grafana-dashboards-kubernetes:
    k8s-system-api-server:
      url: https://raw.githubusercontent.com/dotdc/grafana-dashboards-kubernetes/master/dashboards/k8s-system-api-server.json
      token: ''
    k8s-system-coredns:
      url: https://raw.githubusercontent.com/dotdc/grafana-dashboards-kubernetes/master/dashboards/k8s-system-coredns.json
      token: ''
    k8s-views-global:
      url: https://raw.githubusercontent.com/dotdc/grafana-dashboards-kubernetes/master/dashboards/k8s-views-global.json
      token: ''
    k8s-views-namespaces:
      url: https://raw.githubusercontent.com/dotdc/grafana-dashboards-kubernetes/master/dashboards/k8s-views-namespaces.json
      token: ''
    k8s-views-nodes:
      url: https://raw.githubusercontent.com/dotdc/grafana-dashboards-kubernetes/master/dashboards/k8s-views-nodes.json
      token: ''
    k8s-views-pods:
      url: https://raw.githubusercontent.com/dotdc/grafana-dashboards-kubernetes/master/dashboards/k8s-views-pods.json
      token: ''
datasources:
  datasources.yaml:
    apiVersion: 1
    datasources:
      - name: Prometheus
        type: prometheus
        url: http://${deployment_name}-prometheus-server
        access: proxy
        isDefault: true