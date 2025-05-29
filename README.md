# Avantgrid GitOps Architecture (Sample)

This is a simplified GitOps-ready folder structure representing a modern Kubernetes + IaC + Argo CD setup.

## Components

- **infra/**: mock infrastructure config (could be Terraform or Crossplane)
- **k8s-app/**: Kubernetes deployment and service YAMLs
- **argocd/**: Argo CD Application manifest to enable GitOps
- **monitoring/**: Prometheus alerting rules
