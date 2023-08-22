# Traefik Enterprise

## Introduction

This chart installs the Traefik Enterprise on a Kubernetes cluster, an optional subchart of [Traefik Mesh](https://github.com/traefik/mesh-helm-chart) is also bundled.

## Installation

Detailed in Traefik Enterprise [documentation](https://doc.traefik.io/traefik-enterprise/installing/kubernetes/helm/)

## Upgrading

One can check what has changed in this [Chart Changelog](./traefikee/Changelog.md) and in [Traefik Enterprise Release Notes](https://doc.traefik.io/traefik-enterprise/kb/release-notes/).

New major version indicates that there is an incompatible breaking change.

1. Upgrading CRDs (When it's needed)

With Helm v3, CRDs created by this chart can not be updated, cf the [Helm Documentation on CRDs](https://helm.sh/docs/chart_best_practices/custom_resource_definitions). Please read carefully release notes of this chart before upgrading CRDs.

```bash
kubectl apply --server-side --force-conflicts -k https://github.com/traefik/traefik-hub-helm-chart/traefik-hub/crds/
```

2. Upgrade chart

```bash
# Update repository
helm repo update
# See current Chart & Traefik Enterprise version
helm search repo traefik/traefikee
# Upgrade Traefik
helm upgrade traefikee traefik/traefikee
```

## Uninstall

```bash
helm uninstall traefikee
```
If Traefik Enterprise was installed in a specific namespace

```bash
helm uninstall traefikee --namespace traefikee
```
