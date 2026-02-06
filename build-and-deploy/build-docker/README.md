# Docker Image Build and Publish

This blueprint shows an end-to-end workflow for building and publishing Docker images using:
* Docker Buildx for building multi-platform images
* GitHub Actions for the CI pipeline
* GitHub Container Registry (ghcr.io) or other Docker registries

## Features

- Builds Docker images on push to main branch
- Supports manual workflow dispatch with configurable repository
- Automatic tagging with branch, PR, semver, SHA, and custom tags
- Build caching for faster builds
- Multi-platform support via Docker Buildx

## Usage

### Automatic Build (on push to main)

The workflow automatically runs when code is pushed to the main branch. It will:
- Build the Docker image using the default Dockerfile in the repository root
- Tag the image with the commit SHA
- Push to the default repository (ghcr.io based on your GitHub repository)

### Manual Build

You can manually trigger the workflow and customize:
- **image_repository**: The Docker registry and repository (e.g., `ghcr.io/username/repo` or `docker.io/username/repo`)
- **image_tag**: Custom tag for the image (defaults to commit SHA)
- **dockerfile_path**: Path to Dockerfile (defaults to `Dockerfile` in root)
- **build_context**: Build context path (defaults to `.`)

## Configuration

### GitHub Container Registry (ghcr.io)

For GitHub Container Registry, the workflow uses `GITHUB_TOKEN` automatically. No additional setup is required.

### Other Docker Registries

To use other registries (Docker Hub, AWS ECR, etc.), you'll need to:
1. Add registry credentials as GitHub Secrets
2. Modify the login step to use the appropriate registry and credentials

## Next Steps

You can combine this blueprint with deployment workflows for Kubernetes, ECS, or other container orchestration platforms.


