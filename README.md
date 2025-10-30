# Elasticsearch Helm Chart

A Helm chart for deploying Elasticsearch 9.x and Kibana on Kubernetes with flexible configuration options.

## Features

- Elasticsearch 9.x deployment with configurable cluster or single-node mode
- Optional Kibana deployment (enabled by default)
- Security enabled by default (Basic Authentication + TLS)
- Persistent storage with PersistentVolumeClaims
- Configurable resources, replicas, and storage
- Support for advanced customization
- Self-signed TLS certificates (can be overridden with custom certs)
- Pod anti-affinity for high availability

## Prerequisites

- Kubernetes 1.20+
- Helm 3.0+
- PersistentVolume provisioner support in the underlying infrastructure
- At least 2GB RAM per Elasticsearch node

## Installation

### Quick Start (Default Configuration)

Install with default settings (3-node cluster with Kibana, security enabled):

```bash
helm install my-elasticsearch .
```

### Custom Installation

Create a custom `values.yaml` file and install:

```bash
helm install my-elasticsearch . -f custom-values.yaml
```

### Install in a specific namespace

```bash
kubectl create namespace elastic
helm install my-elasticsearch . -n elastic
```

## Configuration

### Common Configurations

#### Single-Node Mode (Development)

```yaml
elasticsearch:
  clusterMode: false
  replicas: 1
  resources:
    requests:
      memory: "1Gi"
      cpu: "500m"
    limits:
      memory: "2Gi"
      cpu: "1000m"
```

#### Multi-Node Cluster (Production)

```yaml
elasticsearch:
  clusterMode: true
  replicas: 3
  resources:
    requests:
      memory: "2Gi"
      cpu: "1000m"
    limits:
      memory: "4Gi"
      cpu: "2000m"
  persistence:
    size: 100Gi
```

#### Disable Security (Not Recommended for Production)

```yaml
elasticsearch:
  security:
    enabled: false
```

#### Disable Kibana

```yaml
kibana:
  enabled: false
```

#### Custom Storage Class

```yaml
elasticsearch:
  persistence:
    storageClass: "fast-ssd"
    size: 50Gi
```

#### Enable Ingress for Kibana

```yaml
kibana:
  ingress:
    enabled: true
    className: "nginx"
    hosts:
      - host: kibana.example.com
        paths:
          - path: /
            pathType: Prefix
    tls:
      - secretName: kibana-tls
        hosts:
          - kibana.example.com
```

### Configuration Parameters

#### Elasticsearch Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `elasticsearch.clusterMode` | Enable cluster mode (true) or single-node (false) | `true` |
| `elasticsearch.replicas` | Number of Elasticsearch replicas | `3` |
| `elasticsearch.image.repository` | Elasticsearch image repository | `docker.elastic.co/elasticsearch/elasticsearch` |
| `elasticsearch.image.tag` | Elasticsearch image tag | `9.0.0` |
| `elasticsearch.resources.requests.memory` | Memory request | `2Gi` |
| `elasticsearch.resources.limits.memory` | Memory limit | `4Gi` |
| `elasticsearch.javaOpts` | JVM options | `-Xms1g -Xmx1g` |
| `elasticsearch.persistence.enabled` | Enable persistent storage | `true` |
| `elasticsearch.persistence.size` | PVC size | `30Gi` |
| `elasticsearch.persistence.storageClass` | Storage class | `""` (default) |
| `elasticsearch.security.enabled` | Enable security features | `true` |
| `elasticsearch.security.tls.enabled` | Enable TLS | `true` |
| `elasticsearch.security.password` | Elastic user password (auto-generated if not set) | `""` |
| `elasticsearch.service.type` | Service type | `ClusterIP` |
| `elasticsearch.affinity.podAntiAffinity` | Pod anti-affinity (soft/hard/none) | `soft` |

#### Kibana Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `kibana.enabled` | Enable Kibana deployment | `true` |
| `kibana.replicas` | Number of Kibana replicas | `1` |
| `kibana.image.repository` | Kibana image repository | `docker.elastic.co/kibana/kibana` |
| `kibana.image.tag` | Kibana image tag | `9.0.0` |
| `kibana.resources.requests.memory` | Memory request | `1Gi` |
| `kibana.resources.limits.memory` | Memory limit | `2Gi` |
| `kibana.service.type` | Service type | `ClusterIP` |

## Accessing Elasticsearch and Kibana

After installation, follow the instructions in the NOTES output to access Elasticsearch and Kibana.

### Get Elasticsearch Password

```bash
kubectl get secret my-elasticsearch-credentials -o jsonpath="{.data.password}" | base64 --decode
```

### Port Forward to Elasticsearch

```bash
kubectl port-forward svc/my-elasticsearch 9200:9200
```

Then access at `https://localhost:9200` (username: `elastic`)

### Port Forward to Kibana

```bash
kubectl port-forward svc/my-elasticsearch-kibana 5601:5601
```

Then access at `http://localhost:5601`

## Advanced Configuration

### Custom Elasticsearch Configuration

Add custom settings to `elasticsearch.yml`:

```yaml
elasticsearch:
  config:
    indices.memory.index_buffer_size: "30%"
    indices.queries.cache.size: "20%"
    node.roles: ["master", "data", "ingest"]
```

### Install Elasticsearch Plugins

```yaml
elasticsearch:
  plugins:
    - repository-s3
    - analysis-icu
```

### Additional Environment Variables

```yaml
elasticsearch:
  extraEnvVars:
    - name: CUSTOM_ENV_VAR
      value: "custom-value"
```

### Custom Kibana Configuration

```yaml
kibana:
  config:
    server.publicBaseUrl: "https://kibana.example.com"
    logging.quiet: true
```

## Upgrading

To upgrade the chart with a new version:

```bash
helm upgrade my-elasticsearch . -f custom-values.yaml
```

## Uninstallation

To uninstall/delete the deployment:

```bash
helm uninstall my-elasticsearch
```

**Note:** This will not delete the PersistentVolumeClaims. To delete them:

```bash
kubectl delete pvc -l app.kubernetes.io/instance=my-elasticsearch
```

## Troubleshooting

### Pods not starting

Check if the init container has successfully set `vm.max_map_count`:

```bash
kubectl logs <pod-name> -c configure-sysctl
```

If you see permission errors, ensure your cluster allows privileged init containers.

### Out of Memory Errors

Increase the memory limits and adjust JVM heap size:

```yaml
elasticsearch:
  resources:
    limits:
      memory: "8Gi"
  javaOpts: "-Xms4g -Xmx4g"  # Should be ~50% of memory limit
```

### Certificate Issues

If you encounter TLS certificate errors, you can disable TLS (not recommended for production):

```yaml
elasticsearch:
  security:
    tls:
      enabled: false
```

Or provide your own certificates by setting `useSelfSignedCerts: false` and mounting custom certificates.

## Security Considerations

- The chart generates a random password for the `elastic` user if not provided
- Self-signed TLS certificates are generated automatically
- For production use, consider:
  - Setting a strong custom password
  - Using proper TLS certificates from a trusted CA
  - Enabling network policies
  - Implementing RBAC policies
  - Using Pod Security Policies/Standards

## License

This Helm chart is provided as-is for use with Elasticsearch and Kibana.

## Support

For issues specific to this Helm chart, please open an issue in the repository.

For Elasticsearch and Kibana documentation, visit:
- [Elasticsearch Documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/index.html)
- [Kibana Documentation](https://www.elastic.co/guide/en/kibana/current/index.html)
