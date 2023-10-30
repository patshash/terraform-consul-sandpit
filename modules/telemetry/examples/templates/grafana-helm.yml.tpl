service:
  type: LoadBalancer
adminUser: admin
adminPassword: ${admin_password}
datasources:
  datasources.yaml:
    apiVersion: 1
    datasources:
      - name: Prometheus
        type: prometheus
        url: http://${deployment_name}-prometheus-server
        access: proxy
        isDefault: true