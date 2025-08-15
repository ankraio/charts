# Ankra Helm Charts Repository

This repository contains Helm charts for Ankra's infrastructure and monitoring components.

## Repository Structure

```
charts/
├── monitoring-stack/         # Comprehensive monitoring stack
│   ├── Chart.yaml
│   ├── values.yaml
│   └── templates/
├── cloudflare-operator/      # Cloudflare Operator chart
│   ├── Chart.yaml
│   ├── values.yaml
│   └── templates/
packages/                     # Packaged charts (.tgz files)
index.yaml                    # Repository index
Makefile                      # Build automation
```

## Usage

### Using the Makefile

The Makefile provides automation for packaging charts and generating the repository index:

```bash
# Package all charts and generate index
make all

# Individual commands
make clean                    # Clean up packages and index
make deps                     # Update chart dependencies
make package                  # Package charts to packages/
make index                    # Generate index.yaml
make lint                     # Lint charts
make test                     # Test charts (dry-run)
make version                  # Show current chart versions
make help                     # Show all available commands

# Git operations
make git-add                  # Add files to git
make git-commit               # Commit changes
make git-tag                  # Create git tag
make release                  # Full release with git operations

# Local testing
make serve                    # Start local HTTP server for testing
```

### Manual Usage

If you prefer to run commands manually:

```bash
# Update dependencies
cd charts/monitoring-stack
helm dependency update
cd ../..

# Package charts
mkdir -p packages
helm package charts/monitoring-stack/ --destination packages/

# Generate index
helm repo index packages --url https://ankraio.github.io/charts
mv packages/index.yaml .
```

### Using the Repository

To use this Helm repository:

```bash
# Add the repository
helm repo add ankra https://ankraio.github.io/charts

# Update repository index
helm repo update

# Search for charts
helm search repo ankra

# Install the monitoring stack
helm install my-monitoring ankra/ankra-monitoring-stack

# Install the Cloudflare operator
helm install cloudflare-op ankra/cloudflare-operator

# Install with custom values
helm install my-monitoring ankra/ankra-monitoring-stack -f my-values.yaml

# Upgrade installations
helm upgrade my-monitoring ankra/ankra-monitoring-stack
helm upgrade cloudflare-op ankra/cloudflare-operator
```

## Charts

### ankra-monitoring-stack

A comprehensive monitoring stack umbrella chart that includes:

- **Prometheus** - Metrics collection and alerting
- **Grafana** - Visualization and dashboards
- **Loki** - Log aggregation
- **Tempo** - Distributed tracing
- **Alloy** - Telemetry collection
- **Fluent Bit** - Log processing
- **Ingress NGINX** - Ingress controller
- **Cert Manager** - Certificate management

### cloudflare-operator

A Helm chart for deploying the Cloudflare Operator, which provides:

- **Cloudflare Tunnel management** - Manage Cloudflare Tunnels as Kubernetes resources
- **DNS record management** - Automatically manage DNS records
- **Custom Resources** - CloudflareTunnel and related CRDs
- **Kubernetes native** - Full integration with Kubernetes APIs

## Development

### Prerequisites

- Helm 3.x
- kubectl
- make

### Contributing

1. Make changes to charts in the `charts/` directory
2. Test your changes: `make lint && make test`
3. Package and generate index: `make all`
4. Commit and create a release: `make release`

### Version Control

The Makefile handles version control integration:

- `packages/` directory is ignored in git (contains generated files)
- `index.yaml` is committed to git (required for GitHub Pages)
- Chart source files are version controlled
- Git tags are created for releases

## GitHub Pages Setup

This repository uses GitHub Actions to automatically build and deploy charts to GitHub Pages.

### Initial Setup Required

**⚠️ First-time setup:** You need to enable GitHub Pages manually. See [SETUP.md](SETUP.md) for detailed instructions.

### Quick Setup
1. Go to your repository Settings → Pages
2. Set Source to "GitHub Actions"
3. The workflows will handle the rest automatically

### Automatic Deployment

The repository uses GitHub Actions to automatically:
1. Build and package charts on every push to `main`/`master`
2. Generate the `index.yaml` file
3. Deploy to GitHub Pages at `https://ankraio.github.io/charts`

### Setup Instructions

1. **Enable GitHub Pages:**
   - Go to your repository settings
   - Navigate to "Pages" section
   - Set source to "GitHub Actions"

2. **The workflows will automatically:**
   - Install Helm and dependencies
   - Run `make all` to build everything
   - Deploy to GitHub Pages

3. **Repository URL:** `https://ankraio.github.io/charts`
4. **Charts are served from the root directory**
5. **Package files (`.tgz`) are served from the `packages/` directory**

### Usage After Deployment

Once deployed, users can add your repository:

```bash
# Add the repository
helm repo add ankra https://ankraio.github.io/charts

# Update repository index
helm repo update

# Search for charts
helm search repo ankra

# Install the monitoring stack
helm install my-monitoring ankra/ankra-monitoring-stack

# Install with custom values
helm install my-monitoring ankra/ankra-monitoring-stack -f my-values.yaml

# Upgrade the installation
helm upgrade my-monitoring ankra/ankra-monitoring-stack
```

### File Structure for GitHub Pages

```
/ (served as https://ankraio.github.io/charts/)
├── index.yaml                           # Repository index (required)
├── packages/                            # Chart packages
│   ├── ankra-monitoring-stack-0.1.0.tgz
│   └── cloudflare-operator-0.1.0.tgz
├── charts/                              # Source charts
│   ├── monitoring-stack/
│   └── cloudflare-operator/
└── README.md                            # This file
```

## Quick Start

After deployment, users can:

```bash
# Add the repository
helm repo add ankra https://ankraio.github.io/charts
helm repo update

# List available charts
helm search repo ankra

# Install charts
helm install my-monitoring ankra/ankra-monitoring-stack
helm install my-cloudflare ankra/cloudflare-operator
```