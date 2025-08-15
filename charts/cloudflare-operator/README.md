# cloudflare-operator Helm Chart

This Helm chart deploys the Cloudflare Operator to your Kubernetes cluster.


## Usage

1. **Create the Cloudflare credentials secret in the operator namespace:**
   ```sh
   kubectl -n cloudflare-operator-system create secret generic cloudflare-secrets \
     --from-literal=CLOUDFLARE_API_TOKEN=<YOUR_API_TOKEN> \
     --from-literal=CLOUDFLARE_API_KEY=<YOUR_GLOBAL_API_KEY>
   ```
   The secret name must match the value in your ClusterTunnel spec (default: `cloudflare-secrets`).

2. **Install the Helm chart:**
   ```sh
   helm install cloudflare-operator ./cloudflare-operator -n cloudflare-operator-system --create-namespace
   ```

## Configuration

See `values.yaml` for configurable parameters.


## Exposing Services via Cloudflare Tunnels

### 1. Install cert-manager (required for webhook TLS)
```sh
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/latest/download/cert-manager.yaml
```

### 2. Install CRDs & Operator
```sh
kubectl apply -k https://github.com/adyanth/cloudflare-operator/config/default
```
This installs the CRDs and the operator in the `cloudflare-operator-system` namespace.

### 3. Create webhook certificate (required for conversion webhooks)
```sh
kubectl apply -k https://github.com/adyanth/cloudflare-operator/config/certmanager
```
This will create a self-signed ClusterIssuer and a Certificate for the webhook. cert-manager will generate the required secret automatically.

### 4. Create Cloudflare Credentials Secret
```sh
kubectl -n cloudflare-operator-system create secret generic cloudflare-secrets \
  --from-literal=CLOUDFLARE_API_TOKEN=<YOUR_API_TOKEN>
```

or with key:
```sh
kubectl -n cloudflare-operator-system create secret generic cloudflare-secrets \
  --from-literal=CLOUDFLARE_API_KEY=<TOKEN> \
  --from-literal=CLOUDFLARE_EMAIL=<ACCOUNT_EMAIL>
```

The secret name must match the value in your ClusterTunnel spec (default: `cloudflare-secrets`).



### 5. Deploy a ClusterTunnel
See `examples/cluster-tunnel.yaml` for a template. Edit and apply:
```sh
kubectl apply -f examples/cluster-tunnel.yaml
```

### 6. Expose a Service with a TunnelBinding
See `examples/tunnel-binding.yaml` for a template. Edit and apply in your app namespace:
```sh
kubectl apply -f examples/tunnel-binding.yaml -n myapp
```

### 7. Verify
```sh
kubectl -n cloudflare-operator-system get clustertunnel cluster-tunnel
kubectl -n myapp get tunnelbinding myapp-tunnel
```

### 8. Access Your App
Once DNS propagates, browse to:
```
https://<service>.<namespace>.<your-domain>
```
TLS is handled by Cloudflare automatically.

## Resources
- Deployment
- Service
- ServiceAccount
- Role/RoleBinding
- ClusterRole/ClusterRoleBinding

## Uninstall

```sh
helm uninstall cloudflare-operator -n cloudflare-operator-system
```


## Troubleshooting
### Test API Token
Confirm your token works:
```
curl -s "https://api.cloudflare.com/client/v4/accounts" \
  -H "Authorization: Bearer jgxsJl6V2ywMZBxWbQ6kNluJMDFGdixpsnA0S9mj" | jq
```
Response
```
{
  "result": [
    {
      "id": "68be9d1f799cd3f539cbca989462c935",
      "name": "Ankra AB account",
      "type": "standard",
      "settings": {
        "enforce_twofactor": false,
        "api_access_enabled": null,
        "access_approval_expiry": null,
        "abuse_contact_email": null,
        "user_groups_ui_beta": false
      },
      "legacy_flags": {
        "enterprise_zone_quota": {
          "maximum": 0,
          "current": 0,
          "available": 0
        }
      },
      "created_on": "2014-03-19T13:10:50.311368Z"
    }
  ],
  "result_info": {
    "page": 1,
    "per_page": 20,
    "total_pages": 1,
    "count": 1,
    "total_count": 1
  },
  "success": true,
  "errors": [],
  "messages": []
}
```

### Test Global Key
```
export CF_EMAIL=example@ankra.io
export CF_KEY=023e105f4ecef8ad9ca31a8372d0c353

curl -H "X-Auth-Email: $CF_EMAIL" \
     -H "X-Auth-Key: $CF_KEY" \
     https://api.cloudflare.com/client/v4/accounts/$CF_ACC | jq .
```
Response:
```
{
  "result": {
    "id": "fedcba9876543210fedcba9876543210",
    "name": "Ankra AB account",
    "type": "standard",
    "settings": {
      "enforce_twofactor": false,
      "api_access_enabled": null,
      "access_approval_expiry": null,
      "abuse_contact_email": null,
      "user_groups_ui_beta": false
    },
    "legacy_flags": {
      "enterprise_zone_quota": {
        "maximum": 0,
        "current": 0,
        "available": 0
      }
    },
    "created_on": "2013-03-19T13:10:50.311368Z"
  },
  "success": true,
  "errors": [],
  "messages": []
}

```