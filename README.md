
# Interviews

## This repo contains tasks we request interviewees to complete

* This repository should be forked, candidates should work in their own forked versions.
Please don't open pull requests with solutions agains this repository.
* No tasks require the use of any paid services.
* For all of the following tasks please use your favourite tools.
* During the interview the interviewee guides us through
their solution. Explaining decisions and technical concepts as we go.
* Tasks can be solved in a very simplistic way or as complicated as you can imagine.
Both can be valid.

### k8s deployment

* please don't use cloud infra providers like AWS, GCP etc. The cluster should
be a local one.
  
1. Set up a kubernetes cluster ie. kind, minikube, k3s etc.
the one you like the most.
2. Build and release an app. This application should have a dockerfile created
by you and it should be built by you. This can be something very simple,
ie traefik/whoami, hashicorp/http-echo, your own if you have one.
Each release should happen automatically.
3. Create a deployment of this app.

* extras: IaC, GitOps, semver, changelog

### pipeline

This repo now includes GitHub Actions for build and release.

- `Build` workflow runs on `push` and `pull_request` to `main`.
- `Release` workflow runs when a tag like `v1.0.0` is pushed.
- The release workflow builds and pushes the Docker image to GitHub Container Registry (GHCR) and creates a GitHub release.

To trigger a release:

```bash
git tag v1.0.0
git push origin v1.0.0
```

### GitLab CI (also configured)

This repo also includes GitLab CI pipeline files:

- `.gitlab-ci.yml` (root include)
- `gitlab/.gitlab-ci.yml` (actual jobs)

Behavior:
- `build` job runs on `main`
- `release` job runs on tags like `v1.0.5`
- release pushes image to GHCR using CI variables:
	- `GHCR_USERNAME`
	- `GHCR_TOKEN`

To trigger a GitLab tag pipeline:

```bash
git tag v1.0.5
git push gitlab v1.0.5
```

## My Solution

I used kind as a local Kubernetes cluster.
The app is a small BusyBox-based static web app.
The Dockerfile is inside cardmarket/.
The Kubernetes deployment is inside k8s/deployment.yaml.
Releases are triggered by SemVer tags like v1.0.0.

### review

* please review [shellscript](shell/script.sh)

* please review [deployment](k8s/deployment.yaml)

## Troubleshooting (common Kubernetes errors)

### CrashLoopBackOff

Meaning:
- Container starts, crashes, then Kubernetes keeps restarting it.

Check:
```bash
kubectl get pods -n default
kubectl describe pod <pod-name> -n default
kubectl logs <pod-name> -n default
```

Typical fixes:
- fix startup command/entrypoint
- fix missing file or wrong path
- fix port mismatch between app and container/service

### ImagePullBackOff

Meaning:
- Kubernetes cannot pull the container image.

Check:
```bash
kubectl describe pod <pod-name> -n default
kubectl get deploy cardmarket -n default -o jsonpath='{.spec.template.spec.containers[0].image}'
```

Typical fixes:
- verify image tag exists in GHCR
- ensure image path is correct and lowercase owner is used
- update `k8s/deployment.yaml` to a valid image tag and push changes
