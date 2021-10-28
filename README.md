# Traefik Enterprise Edition

## Introduction

This chart installs the Traefik EE on a Kubernetes cluster, an optional subchart of [Traefik Mesh](https://github.com/traefik/mesh-helm-chart) is also bundled.

## Installation

### Prerequisites

With the command `helm version`, make sure that you have:
- Helm v3 [installed](https://helm.sh/docs/intro/install/)

Add Traefik EE's chart repository to Helm:

```bash
helm repo add traefikee https://helm.traefik.io/traefikee
```

You can update the chart repository by running:

```bash
helm repo update
```

### Deploying Traefik EE

```bash
helm install traefikee traefikee/traefikee
```

### Specifications 

By default, Traefik EE will be installed into the `default` namespace. If you want to install the Traefik EE in a specific namespace, you need to run helm with the `--namespace` and `--create-namespace` arguments:
```bash
helm install traefikee traefikee/traefikee --namespace traefikee --create-namespace
```

Then just create the license key we provided:
```bash
kubectl create secret -n traefikee generic default --from-literal=license=xxxxxxx
```

### Launch unit tests

You need the helm-plugin: https://github.com/rancher/helm-unittest

Then:

```bash
helm unittest traefikee/
```

### Uninstall

```bash
helm uninstall traefikee
```
If Traefik EE was install in a specific namespace

```bash
helm uninstall traefikee --namespace traefikee
```
