# Monitoring Stack Helm Chart

A comprehensive Kubernetes monitoring stack packaged as a Helm umbrella chart, featuring Grafana, Prometheus, Loki, Tempo, Fluent Bit, and supporting components.

## 🚀 Quick Start

```bash
# Install the monitoring stack
helm install monitoring-stack . -n monitoring --create-namespace

# Access Grafana (after port-forward)
kubectl port-forward -n monitoring svc/monitoring-grafana 3000:80
# Visit http://localhost:3000
# Login: admin / 7x!L8s@3j#q9Z$vM
```

## 📊 What's Included

| Component | Purpose | Default Port | Status |
|-----------|---------|--------------|--------|
| **Grafana** | Visualization & Dashboards | 3000 | ✅ Enabled |
| **Prometheus** | Metrics Collection | 9090 | ✅ Enabled |
| **Loki** | Log Aggregation | 3100 | ✅ Enabled |
| **Tempo** | Distributed Tracing | 3200/4317 | ✅ Enabled |
| **Fluent Bit** | Log Shipping | 2020 | ✅ Enabled |
| **Alloy** | Telemetry Collection | - | ✅ Enabled |
| **Ingress NGINX** | Ingress Controller | 80/443 | ❌ Disabled |
| **Cert-Manager** | TLS Certificate Management | - | ✅ Enabled |

## 🔧 Prerequisites

- **Kubernetes**: 1.19+
- **Helm**: 3.2.0+
- **Storage**: Default storage class available
- **Resources**: Minimum 4GB RAM, 2 CPU cores

## 📦 Installation

### 1. Deploy the Chart

```bash
# Basic installation
helm install monitoring-stack . -n monitoring --create-namespace

# With custom values
helm install monitoring-stack . -n monitoring --create-namespace -f my-values.yaml

# Upgrade existing installation
helm upgrade monitoring-stack . -n monitoring
```

### 2. Access Services

#### Grafana Dashboard
```bash
# Port forward to access Grafana
kubectl port-forward -n monitoring svc/monitoring-grafana 3000:80

# Open browser to http://localhost:3000
# Default credentials: admin / 7x!L8s@3j#q9Z$vM
```

#### Prometheus UI
```bash
# Port forward to access Prometheus
kubectl port-forward -n monitoring svc/monitoring-prometheus-server 9090:80

# Open browser to http://localhost:9090
```

#### Loki Logs
```bash
# Port forward to access Loki
kubectl port-forward -n monitoring svc/monitoring-loki 3100:3100

# Query logs via LogQL at http://localhost:3100
```

## 🎯 Pre-configured Features

### 📈 Grafana Dashboards
- **Node Exporter Full** (ID: 1860) - Comprehensive node monitoring
- **Auto-provisioned datasources** for Prometheus, Loki, and Tempo
- **Multi-tenant support** with Loki integration

### 🔍 Data Sources
- **Prometheus**: Metrics from all cluster components
- **Loki**: Multi-tenant log aggregation with orgId support
- **Tempo**: Distributed tracing via gRPC and HTTP

### 📝 Log Collection
- **Fluent Bit**: Automatically ships all pod logs to Loki
- **Structured metadata**: Kubernetes labels and annotations preserved
- **Multi-tenant routing**: Logs tagged with `orgId: 1`

## ⚙️ Configuration

### Key Configuration Options

```yaml
# Enable/disable components
grafana:
  enabled: true
prometheus:
  enabled: true
loki:
  enabled: true
tempo:
  enabled: true
fluent-bit:
  enabled: true

# Grafana access
grafana:
  adminPassword: "your-secure-password"
  ingress:
    enabled: true
    hosts:
      - monitor.yourdomain.com

# Storage configuration
prometheus:
  server:
    persistentVolume:
      size: 10Gi
      storageClass: "fast-ssd"

loki:
  singleBinary:
    persistence:
      size: 10Gi
      storageClass: "fast-ssd"
```

### Multi-tenancy Support

This chart includes pre-configured multi-tenant support:

```yaml
# Automatic org ID injection for Loki
fluent-bit:
  orgId: 1  # All logs tagged with tenant ID

grafana:
  datasources:
    datasources.yaml:
      datasources:
        - name: Loki
          type: loki
          jsonData:
            httpHeaderName1: X-Scope-OrgID
          secureJsonData:
            httpHeaderValue1: "1"
```

## 🔒 Security

### Default Credentials
- **Grafana Admin**: `admin` / `7x!L8s@3j#q9Z$vM`

### TLS/SSL Support
- **Cert-Manager**: Enabled for automatic certificate management
- **ClusterIssuer**: Configurable for Let's Encrypt integration
- **Ingress TLS**: Ready for HTTPS termination

### RBAC
- **Service Accounts**: Properly configured for all components
- **Cluster Roles**: Minimal required permissions
- **Pod Security**: Non-root containers where possible

## 📊 Monitoring Targets

### Automatically Monitored
- **Kubernetes API Server**
- **Kubelet & cAdvisor**
- **Node Exporter** (system metrics)
- **Kube State Metrics** (K8s object metrics)
- **All Pod Logs** (via Fluent Bit)

### Metrics Available
- CPU, Memory, Disk, Network usage
- Kubernetes resource states
- Application logs and traces
- Custom application metrics (via `/metrics` endpoints)

## 🚨 Alerting

### Prometheus Rules
The chart includes basic alerting rules for:
- High CPU/Memory usage
- Disk space warnings
- Pod crash loops
- Service availability

### Alert Manager
Configure external AlertManager for notifications:

```yaml
prometheus:
  alertmanager:
    enabled: true
    config:
      route:
        receiver: 'slack-notifications'
      receivers:
        - name: 'slack-notifications'
          slack_configs:
            - api_url: 'YOUR_SLACK_WEBHOOK'
              channel: '#alerts'
```

## 🔧 Troubleshooting

### Common Issues

#### 1. Grafana Login Issues
```bash
# Check Grafana pod logs
kubectl logs -n monitoring deployment/monitoring-grafana

# Reset admin password
kubectl patch secret -n monitoring monitoring-grafana \
  -p '{"data":{"admin-password":"'$(echo -n 'newpassword' | base64)'"}}'
```

#### 2. No Metrics in Prometheus
```bash
# Check Prometheus targets
kubectl port-forward -n monitoring svc/monitoring-prometheus-server 9090:80
# Visit http://localhost:9090/targets

# Check node-exporter pods
kubectl get pods -n monitoring -l app.kubernetes.io/name=prometheus-node-exporter
```

#### 3. Fluent Bit Not Shipping Logs
```bash
# Check Fluent Bit status
kubectl logs -n monitoring daemonset/monitoring-fluent-bit-loki

# Verify Loki endpoint
kubectl exec -n monitoring deployment/monitoring-fluent-bit-loki -- \
  curl -s http://monitoring-loki:3100/ready
```

#### 4. Storage Issues
```bash
# Check PVC status
kubectl get pvc -n monitoring

# Check storage class
kubectl get storageclass
```

### Health Checks

```bash
# Check all monitoring components
kubectl get pods -n monitoring

# Check service endpoints
kubectl get svc -n monitoring

# Check ingress (if enabled)
kubectl get ingress -n monitoring
```

## 🛠️ Customization

### Adding Custom Dashboards

```yaml
grafana:
  dashboards:
    default:
      my-custom-dashboard:
        gnetId: 12345  # Grafana.com dashboard ID
        revision: 1
        datasource: Prometheus
```

### Custom Prometheus Rules

```yaml
prometheus:
  serverFiles:
    alerting_rules.yml:
      groups:
        - name: custom.rules
          rules:
            - alert: HighErrorRate
              expr: rate(http_requests_total{status="500"}[5m]) > 0.1
              for: 5m
              annotations:
                summary: "High error rate detected"
```

### Environment-Specific Values

Create environment-specific value files:

```bash
# values-production.yaml
grafana:
  persistence:
    size: 50Gi
  resources:
    requests:
      memory: 1Gi
      cpu: 500m

prometheus:
  server:
    retention: 30d
    persistentVolume:
      size: 100Gi
```

## 📋 Values Reference

### Essential Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `grafana.enabled` | Enable Grafana | `true` |
| `grafana.adminPassword` | Grafana admin password | `7x!L8s@3j#q9Z$vM` |
| `prometheus.enabled` | Enable Prometheus | `true` |
| `loki.enabled` | Enable Loki | `true` |
| `tempo.enabled` | Enable Tempo | `true` |
| `fluent-bit.enabled` | Enable Fluent Bit | `true` |
| `fluent-bit.orgId` | Loki tenant ID | `1` |

### Storage Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `global.storageClass` | Default storage class | `""` |
| `grafana.persistence.size` | Grafana storage size | `5Gi` |
| `prometheus.server.persistentVolume.size` | Prometheus storage size | `10Gi` |
| `loki.singleBinary.persistence.size` | Loki storage size | `10Gi` |

### Resource Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `grafana.resources.requests.memory` | Grafana memory request | `256Mi` |
| `prometheus.server.resources.requests.memory` | Prometheus memory request | `512Mi` |
| `loki.loki.resources.requests.memory` | Loki memory request | `256Mi` |

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

- **Issues**: Report bugs and feature requests on GitHub
- **Documentation**: Check the individual component documentation
- **Community**: Join our Slack channel for discussions

---

**Happy Monitoring!** 🎉
