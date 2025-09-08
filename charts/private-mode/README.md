# Private Mode

Private Mode enables organizations to manage and control access to their code repositories securely.

## Prerequisites

- Create a Baz access token
- Create a GitHub PAT with `contents:read` permission for the repositories you want to use it with

## Install

- Fill in the required fields in `values.yaml` file
- Run `helm install private-mode . --create-namespace --namespace [namespace name]`
- Expose the `private-mode` service

### Traefik

```yaml
apiVersion: traefik.io/v1alpha1
kind: IngressRoute
metadata:
  name: private-mode
  namespace: [namespace name]
spec:
  routes:
    - kind: Rule
      match: Host(`fss.example.com`) && (PathPrefix(`/git-repo`))
      priority: 100
      services:
        - kind: Service
          name: private-mode
          passHostHeader: true
          port: 3000
```
