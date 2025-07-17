# Makefile for Helm Chart Repository
# This Makefile handles packaging, versioning, and index generation for Helm charts

# Variables
CHARTS_DIR = charts
PACKAGES_DIR = packages
REPO_URL = https://ankraio.github.io/charts

# Default target
.PHONY: all
all: clean package index

# Clean up previous packages
.PHONY: clean
clean:
	@echo "Cleaning up previous packages..."
	@rm -rf $(PACKAGES_DIR)
	@rm -f index.yaml

# Create packages directory
$(PACKAGES_DIR):
	@echo "Creating packages directory..."
	@mkdir -p $(PACKAGES_DIR)

# Update chart dependencies
.PHONY: deps
deps:
	@echo "Updating chart dependencies..."
	@for chart in $(CHARTS_DIR)/*/; do \
		if [ -f "$$chart/Chart.yaml" ]; then \
			echo "Updating dependencies for $$chart..."; \
			cd "$$chart" && helm dependency update && cd ../..; \
		fi; \
	done

# Package all charts
.PHONY: package
package: $(PACKAGES_DIR) deps
	@echo "Packaging charts..."
	@for chart in $(CHARTS_DIR)/*/; do \
		if [ -f "$$chart/Chart.yaml" ]; then \
			echo "Packaging $$chart..."; \
			helm package "$$chart" --destination $(PACKAGES_DIR); \
		fi; \
	done

# Generate repository index
.PHONY: index
index: package
	@echo "Generating repository index..."
	@helm repo index $(PACKAGES_DIR) --url $(REPO_URL)
	@mv $(PACKAGES_DIR)/index.yaml .
	@echo "Repository index generated successfully!"

# Lint charts
.PHONY: lint
lint:
	@echo "Linting charts..."
	@for chart in $(CHARTS_DIR)/*/; do \
		if [ -f "$$chart/Chart.yaml" ]; then \
			echo "Linting $$chart..."; \
			helm lint "$$chart"; \
		fi; \
	done

# Test charts (dry-run install)
.PHONY: test
test: package
	@echo "Testing charts..."
	@for chart in $(PACKAGES_DIR)/*.tgz; do \
		if [ -f "$$chart" ]; then \
			echo "Testing $$chart..."; \
			helm install --dry-run --debug test-release "$$chart"; \
		fi; \
	done

# Git operations for version control
.PHONY: git-add
git-add:
	@echo "Adding files to git..."
	@git add $(PACKAGES_DIR)/ index.yaml $(CHARTS_DIR)/*/Chart.yaml

.PHONY: git-commit
git-commit:
	@echo "Committing changes..."
	@read -p "Enter commit message: " msg; \
	git commit -m "$$msg"

.PHONY: git-tag
git-tag:
	@echo "Creating git tag..."
	@read -p "Enter tag version (e.g., v1.0.0): " tag; \
	git tag -a "$$tag" -m "Release $$tag"

# Full release with git operations
.PHONY: release
release: all git-add git-commit git-tag
	@echo "Full release completed!"

# Show current chart versions
.PHONY: version
version:
	@echo "Current chart versions:"
	@for chart in $(CHARTS_DIR)/*/; do \
		if [ -f "$$chart/Chart.yaml" ]; then \
			chart_name=$$(basename "$$chart"); \
			version=$$(grep '^version:' "$$chart/Chart.yaml" | awk '{print $$2}'); \
			echo "  $$chart_name: $$version"; \
		fi; \
	done

# Show help
.PHONY: help
help:
	@echo "Available targets:"
	@echo "  all               - Clean, package, and generate index"
	@echo "  clean             - Remove packages directory and index.yaml"
	@echo "  deps              - Update chart dependencies"
	@echo "  package           - Package all charts into packages directory"
	@echo "  index             - Generate repository index"
	@echo "  lint              - Lint all charts"
	@echo "  test              - Test charts with dry-run install"
	@echo "  release           - Full release with git operations"
	@echo "  version           - Show current chart versions"
	@echo "  help              - Show this help message"

# List packaged charts
.PHONY: list
list:
	@echo "Packaged charts:"
	@if [ -d "$(PACKAGES_DIR)" ]; then \
		ls -la $(PACKAGES_DIR)/*.tgz 2>/dev/null || echo "No packages found"; \
	else \
		echo "No packages directory found"; \
	fi

# Serve local repository (for testing)
.PHONY: serve
serve:
	@echo "Starting local chart repository server..."
	@echo "Repository will be available at: http://localhost:8080"
	@echo "Add it with: helm repo add local http://localhost:8080"
	@python3 -m http.server 8080
