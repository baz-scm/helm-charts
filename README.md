<div align="center">

# Baz Helm Charts

![Baz Logo](https://avatars.githubusercontent.com/u/140384842?s=200&v=4)

This repository contains Helm charts for deploying Baz services to Kubernetes. The primary chart currently available is **Private Mode**, which packages the filesystem service used to broker secure, private repository access.

<div align="left">

## Overview

The chart renders a minimal, production-ready stack that wires storage, identity, and networking for the service:

- **ServiceAccount** (optional): created when `serviceAccount.name` is not provided, allowing you to supply your own account if additional permissions (such as secret access) are required.
- **Deployment**: a single container running the Baz Private Mode image with configurable replica count, resource requests/limits, and security contexts. Probes (startup, liveness, readiness) are enabled on port 3000 to ensure healthy rollouts.
- **PersistentVolumeClaim** (optional): provisioned when both `storage.size` and `storage.class` are set, mounting at `/data` to persist cloned repositories—recommended for large repositories (5GB+).
- **Secrets volume** (optional): mounted at `/mnt/secrets-store` when `secretsVolume` is defined, enabling integration with CSI Secret Store or other secret providers.
- **Service**: a ClusterIP service (customizable via `service.type` and `service.port`) that fronts the Deployment on port 3000 for internal or externally exposed traffic.

## Configuration

Key values in `charts/private-mode/values.yaml` include:

- **Image**: `image.repository` (required) and `image.tag` (required) control the container image; `image.pullSecrets` lets you reference private registries.
- **Access credentials**: `githubPat` and `privateModeKey` must be supplied (directly or via the `secretKeyRef` secret) for GitHub content access and Baz authentication.
- **GHES support**: For GitHub Enterprise Server deployments, set `githubHost` to your GHES hostname (e.g. `github.acme.corp`). Defaults to `github.com` if not set.
- **Environment & logging**: `env` sets the deployment environment label, while `log` configures the Rust logger levels.
- **Scheduling**: `nodeGroup` allows targeting specific nodes; pod-level annotations and labels can be added via `podAnnotations` and `podLabels`.
- **Security**: `podSecurityContext` and `containerSecurityContext` allow tailoring runtime privileges; filesystem group defaults are set to match the container user.

## Installing the chart

1) Populate the required values in `charts/private-mode/values.yaml`:

```yaml
image:
  repository: <your-registry>/<image>
  tag: <version>
githubPat: <token or empty if using secretKeyRef>
githubHost: github.acme.corp  # optional, for GHES deployments
privateModeKey: <key or empty if using secretKeyRef>
secretKeyRef:
  name: <existing-secret-with-github_pat-and-private_mode_key>
storage:
  size: 10Gi    # optional, enables PVC
  class: gp3    # optional, enables PVC
```

2) Install with Helm, creating a namespace if needed:

```bash
helm install private-mode charts/private-mode \
  --create-namespace \
  --namespace <namespace>
```

3) Expose the service using your ingress controller of choice. For Traefik, use an `IngressRoute` similar to:

```yaml
apiVersion: traefik.io/v1alpha1
kind: IngressRoute
metadata:
  name: private-mode
  namespace: <namespace>
spec:
  routes:
    - kind: Rule
      match: Host(`fss.example.com`) && PathPrefix(`/git-repo`)
      services:
        - kind: Service
          name: private-mode
          port: 3000
          passHostHeader: true
```

For a deeper look at chart defaults and template structure, see [charts/private-mode/README.md](charts/private-mode/README.md).
