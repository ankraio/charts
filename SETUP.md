# GitHub Pages Setup Guide

This guide will help you enable GitHub Pages for your Helm chart repository.

## Method 1: Enable GitHub Pages via Repository Settings (Recommended)

1. **Go to your repository on GitHub**
   - Navigate to `https://github.com/ankraio/charts`

2. **Access Settings**
   - Click on the "Settings" tab in your repository

3. **Navigate to Pages**
   - In the left sidebar, click on "Pages"

4. **Configure Source**
   - Under "Source", select "GitHub Actions"
   - This allows the workflow to deploy automatically

5. **Save Settings**
   - GitHub will provide you with the URL: `https://ankraio.github.io/charts`

## Method 2: Alternative Deployment (If Pages setup fails)

If you encounter issues with GitHub Pages, you can use the alternative workflow:

1. **Use the build workflow**
   - The `build.yml` workflow will automatically build and commit charts
   - It pushes the `packages/` directory and `index.yaml` to your repository

2. **Enable Pages from static files**
   - Go to Settings → Pages
   - Set Source to "Deploy from a branch"
   - Select branch: `master` (or `main`)
   - Select folder: `/ (root)`

## Method 3: Manual Setup

If automated setup doesn't work:

1. **Build locally**
   ```bash
   make all
   git add packages/ index.yaml
   git commit -m "Add built charts"
   git push
   ```

2. **Enable Pages**
   - Follow Method 1 or Method 2 above

## Troubleshooting

### Error: "Pages site failed"
- Make sure you have admin/maintainer access to the repository
- Verify the repository is public or has GitHub Pro/Team plan for private repos
- Try Method 2 as an alternative

### Error: "Not Found"
- The repository might not have Pages enabled yet
- Use Method 1 to manually enable it first
- Check repository permissions

## Verification

Once set up, test your repository:

```bash
# Add your repository
helm repo add ankra https://ankraio.github.io/charts

# List available charts  
helm search repo ankra

# You should see:
# NAME                            CHART VERSION   APP VERSION     DESCRIPTION
# ankra/ankra-monitoring-stack    0.1.0          1.0             Ankra's comprehensive monitoring stack...
# ankra/cloudflare-operator       0.1.0          1.0.0           A Helm chart for deploying the Cloudflare...
```

## Next Steps

After successful setup:
1. The GitHub Actions will automatically build and deploy on every push
2. Users can install charts using the commands above
3. You can add more charts by creating new directories in `charts/`
