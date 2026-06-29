
# Cardmarket – Local Kubernetes + CI/CD + GitOps Demo

This repository is my solution for a DevOps-style interview task.

I built a simple containerized web app, deployed it to a local Kubernetes cluster, automated image releases, and wired GitOps reconciliation with Argo CD.

## What I implemented

1. Local Kubernetes cluster using kind
2. Custom Docker image for a static web app
3. Kubernetes deployment with 2 replicas + NodePort service
4. Automated CI/CD release flow with SemVer tags
5. GitOps sync with Argo CD
6. Changelog-based release tracking

## Project structure

- [cardmarket](cardmarket)
	- [cardmarket/Dockerfile](cardmarket/Dockerfile): BusyBox-based web container
	- [cardmarket/index.html](cardmarket/index.html): App content
	- [cardmarket/app.sh](cardmarket/app.sh): Shell helper script
- [k8s](k8s)
	- [k8s/deployment.yaml](k8s/deployment.yaml): `Deployment` (2 replicas)
	- [k8s/service.yaml](k8s/service.yaml): `Service` (`NodePort`, 30080)
	- [k8s/argocd.yaml](k8s/argocd.yaml): Argo CD `Application`
- GitHub CI/CD
	- [/.github/workflows/Build.yml](.github/workflows/Build.yml)
	- [/.github/workflows/release.yml](.github/workflows/release.yml)
- GitLab CI/CD
	- [/.gitlab-ci.yml](.gitlab-ci.yml) (entry include)
	- [gitlab/.gitlab-ci.yml](gitlab/.gitlab-ci.yml) (actual jobs)
- Release history
	- [CHANGELOG.md](CHANGELOG.md)

## Why these choices

- kind keeps everything local and reproducible
- BusyBox keeps the image lightweight and easy to explain
- Separate build and release workflows keep CI intent clear
- Argo CD gives continuous reconciliation from Git to cluster

## CI/CD behavior

### GitHub Actions

- `Build` workflow runs on push/PR to `main`
- `Release` workflow runs on tag push (`v*`)
- Release publishes image to GHCR and creates GitHub Release

### GitLab CI

- `build_image` runs on `main`
- `release_image` runs on tags
- Release pushes image to GHCR using:
	- `GHCR_USERNAME`
	- `GHCR_TOKEN`

## Release flow

1. Create a tag like `v1.0.5`
2. CI builds and pushes `ghcr.io/harshadeevi/cardmarket:v1.0.5`
3. Update deployment image in [k8s/deployment.yaml](k8s/deployment.yaml)
4. Argo CD detects Git change and syncs cluster

## Quick start (local run)

Build and test locally:

```bash
docker build -t cardmarket:local ./cardmarket
docker run --rm -p 8080:8080 cardmarket:local
```

Create cluster and deploy:

```bash
kind create cluster --name cardmarket-cluster
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
kubectl get deploy,pods,svc -n default
```

Access app:

```bash
kubectl port-forward svc/cardmarket -n default 8082:8080
```

Then open: http://localhost:8082

## Argo CD

Install and apply app config:

```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl apply -f k8s/argocd.yaml
kubectl get application argocd -n argocd
```

Healthy target state for demo:

- `SYNC STATUS`: `Synced`
- `HEALTH STATUS`: `Healthy`

## Troubleshooting notes

### `ImagePullBackOff`

- Check image in deployment:
	```bash
	kubectl get deploy cardmarket -n default -o jsonpath='{.spec.template.spec.containers[0].image}'
	```
- Confirm tag exists in GHCR
- Fix tag mismatch in [k8s/deployment.yaml](k8s/deployment.yaml)

### `CrashLoopBackOff`

- Inspect pod events/logs:
	```bash
	kubectl describe pod <pod-name> -n default
	kubectl logs <pod-name> -n default
	```
- Validate command/path/port settings

## One-line summary

This project delivers a complete local DevOps flow: build, release, deploy, and continuously reconcile Kubernetes state from Git.
