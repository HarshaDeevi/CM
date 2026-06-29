# Cardmarket project

This is my interview assignment project.

I built a simple app, put it in Docker, deployed it to a local Kubernetes cluster, added CI/CD, and connected Argo CD for GitOps sync.

---

## Start here

Follow this order:

1. Step 1: Run app locally with Docker
2. Step 2: Deploy to Kubernetes
3. Step 3: Access Cardmarket service (K8s)
4. Step 4: Open Argo CD
5. Step 5: Trigger releases
6. Step 6: Verify final state

### Ports I use in this project

- `8080` = local Docker app
- `8082` = Kubernetes app via `kubectl port-forward`
- `8083` = Argo CD UI via `kubectl port-forward`

---

## Repository map

- App files:
  - [cardmarket/Dockerfile](cardmarket/Dockerfile)
  - [cardmarket/index.html](cardmarket/index.html)
  - [cardmarket/app.sh](cardmarket/app.sh)
- Kubernetes manifests:
  - [k8s/deployment.yaml](k8s/deployment.yaml)
  - [k8s/service.yaml](k8s/service.yaml)
  - [k8s/argocd.yaml](k8s/argocd.yaml)
- GitHub CI:
  - [.github/workflows/Build.yml](.github/workflows/Build.yml)
  - [.github/workflows/release.yml](.github/workflows/release.yml)
- GitLab CI:
  - [.gitlab-ci.yml](.gitlab-ci.yml)
  - [gitlab/.gitlab-ci.yml](gitlab/.gitlab-ci.yml)
- Release notes:
  - [CHANGELOG.md](CHANGELOG.md)

---

## Prerequisites

I used these tools on my laptop:

- Docker
- kind
- kubectl
- Git

---

## Step 1 - Run app locally with Docker

Build image:

```bash
docker build -t cardmarket:local ./cardmarket
```

Run container:

```bash
docker run -d --name cardmarket-local -p 8080:8080 cardmarket:local
```

Open:

- http://localhost:8080

Stop when done:

```bash
docker rm -f cardmarket-local
```

---

## Step 2 - Deploy to Kubernetes

Create local cluster (one time):

```bash
kind create cluster --name cardmarket-cluster
```

Apply manifests:

```bash
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

Check resources:

```bash
kubectl get deploy,pods,svc -n default
```

---

## Step 3 - Access Cardmarket service

### Option A (recommended): port-forward service

Use this when you want to test the Kubernetes deployment separately from local Docker.

```bash
kubectl port-forward svc/cardmarket -n default 8082:8080
```

Open:

- http://localhost:8082

### Option B: NodePort access

Service is configured with `nodePort: 30080` in [k8s/service.yaml](k8s/service.yaml).

---

## Step 4 - Set up and access Argo CD

Install Argo CD (one time):

```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

Apply Argo application:

```bash
kubectl apply -f k8s/argocd.yaml
```

Check app status:

```bash
kubectl get application argocd -n argocd
```

Port-forward Argo UI (choose a free local port):

```bash
kubectl port-forward svc/argocd-server -n argocd 8083:443
```

Open:

- https://localhost:8083

Get Argo admin password:

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o go-template='{{.data.password}}' | base64 --decode && echo
```

Login:

- username: `admin`
- password: output from command above

---

## Step 5 - Trigger releases (GitHub + GitLab)

### GitHub Actions release

```bash
git tag v1.0.6
git push origin v1.0.6
```

This triggers [release workflow](.github/workflows/release.yml) and pushes image to GHCR.

### GitLab CI release

```bash
git push gitlab v1.0.6
```

This triggers `release_image` job in [gitlab/.gitlab-ci.yml](gitlab/.gitlab-ci.yml).

---

## Step 6 - Verify final state

### Kubernetes checks

```bash
kubectl get deploy cardmarket -n default
kubectl get pods -n default -l app=cardmarket
kubectl get svc cardmarket -n default
```

### Deployed image check

```bash
kubectl get deploy cardmarket -n default -o jsonpath='{.spec.template.spec.containers[0].image}'; echo
```

### Argo CD checks

```bash
kubectl get application argocd -n argocd
kubectl get application argocd -n argocd -o jsonpath='{.spec.syncPolicy.automated}'; echo
```

Expected:

- App health = `Healthy`
- Sync status = `Synced`
- Auto sync enabled with `prune` and `selfHeal`

---

## Troubleshooting

### Port already in use during port-forward

If `8081` or `8082` is busy, switch to another local port:

```bash
kubectl port-forward svc/argocd-server -n argocd 8083:443
kubectl port-forward svc/cardmarket -n default 8084:8080
```

If Docker port `8080` is already allocated:

```bash
docker ps --filter ancestor=cardmarket:local
docker rm -f cardmarket-local
docker run -d --name cardmarket-local -p 8080:8080 cardmarket:local
```

### `ImagePullBackOff`

```bash
kubectl describe pod <pod-name> -n default
kubectl get deploy cardmarket -n default -o jsonpath='{.spec.template.spec.containers[0].image}'; echo
```

Then verify the same tag exists in GHCR.

### `CrashLoopBackOff`

```bash
kubectl describe pod <pod-name> -n default
kubectl logs <pod-name> -n default
```

---

## Final note

I implemented this project so that anyone can review it quickly: build, release, deploy, and verify each service with clear commands.
