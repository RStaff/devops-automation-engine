# GitLab Runner Helm Installation Guide

## Prerequisites
- Minikube running
- Helm installed
- Docker Desktop running
- GitLab project runner token

## Install Instructions

1. Add the GitLab Helm repo:
```bash
helm repo add gitlab https://charts.gitlab.io
helm repo update

