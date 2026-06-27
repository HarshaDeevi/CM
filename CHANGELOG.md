# Changelog

## [1.0.5] - 2026-06-27
- Added GitLab CI pipeline files (`.gitlab-ci.yml`, `gitlab/.gitlab-ci.yml`)
- Verified GHCR image publish and pull for `v1.0.5`

## [1.0.4] - 2026-06-26
- Updated deployment image to `ghcr.io/harshadeevi/cardmarket:v1.0.4`
- Synced Argo CD to latest deployment revision

## [1.0.3] - 2026-06-26
- Simplified release workflow using `docker/build-push-action`
- Published GitHub Release and GHCR image for `v1.0.3`

## [1.0.2] - 2026-06-26
- Added GitHub Release creation step in release workflow
- Updated Kubernetes Service to `NodePort` for kind compatibility
- Normalized GHCR image path to lowercase owner (`harshadeevi`)

## [1.0.1] - 2026-06-25
- Added first tag-based release flow (`v*`) for publishing
- Published initial GHCR image and release tag

## [1.0.0] - 2026-06-25
- Initial commit for Cardmarket shell app
- Added Dockerfile, Kubernetes deployment, and service manifest
- Added GitHub Actions CI workflow
