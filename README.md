<a name="readme-top"></a>

<br/>

<div align="center" style="margin: 30px;">
<a href="https://traefik.io/traefik-enterprise/" target="_blank">
    <picture>
      <source media="(prefers-color-scheme: dark)" srcset="https://doc.traefik.io/traefik-enterprise/assets/images/logo-traefik-enterprise-logo--white.svg">
      <source media="(prefers-color-scheme: light)" srcset="https://doc.traefik.io/traefik-enterprise/assets/images/logo-traefik-enterprise-logo.svg">
      <img alt="Traefik Enterprise" src="https://doc.traefik.io/traefik-enterprise/assets/images/logo-traefik-enterprise-logo.svg" width="350" height="70" style="max-width: 100%;">
    </picture>
  </a>

<br />
<br />

<div align="center">
    <a href="https://traefik.io/traefik-enterprise/"> Website</a> |
    <a href="https://info.traefik.io/en/request-demo">Get a Demo</a> |
    <a href="https://doc.traefik.io/traefik-enterprise/">Documentation</a>
</div>
</div>

<br />

<div align="center"><strong>Traefik Enterprise Helm Chart</strong>

<br />
<br />
</div>

## Introduction

This chart installs Traefik Enterprise on a Kubernetes cluster.

### Prerequisites

- ![Kubernetes: >= 1.14.0-0](https://img.shields.io/static/v1?label=Kubernetes&message=%3E%3D+1.14.0-0&color=informational&logo=kubernetes)
- ![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

You can check your Helm version by running `helm version`.

## Installation

Please check the [detailed installation page](https://doc.traefik.io/traefik-enterprise/installing/kubernetes/helm/) in the Traefik Enterprise documentation.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Upgrading

Before you upgrade, make sure to check the [changelog](./traefikee/Changelog.md) and the [release notes](https://doc.traefik.io/traefik-enterprise/kb/release-notes/).

New major version indicates that there is an incompatible breaking change.

### 1. Upgrading CRDs (When it's needed)

With Helm v3, CRDs created by this chart can not be updated, please consult the [Helm documentation about CRDs](https://helm.sh/docs/chart_best_practices/custom_resource_definitions) for more information.

> Please read carefully release notes of this chart before upgrading CRDs!

```shell
kubectl apply --server-side --force-conflicts -k https://github.com/traefik/traefikee-helm-chart/traefikee/crds/
```

### 2. Upgrade the Helm chart

Update the Helm chart repository:

```shell
helm repo update
```

Validate the current versions of the chart and Traefik Enterprise:

```shell
helm search repo traefik/traefikee
```

Upgrade Traefik Enterprise:

```shell
helm upgrade traefikee traefik/traefikee
```

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Uninstall

```shell
helm uninstall traefikee
```

If Traefik Enterprise was installed in a specific namespace (for example `traefikee`)

```shell
helm uninstall traefikee --namespace traefikee
```

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## License

Distributed under the Apache v2 License.
See [LICENSE](./LICENSE) for more information.

<p align="right">(<a href="#readme-top">back to top</a>)</p>
