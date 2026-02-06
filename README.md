# InfraDots Blueprints
A collection of blueprints for building opinionated infrastructure solutions using OpenTofu.

## Available Blueprints

### AWS
| Type | Name | Path | Description |
|------|------|------|-------------|
| Simple | **Standard Web App** | [`infrastructure/simple/aws-asg`](infrastructure/simple/aws-asg) | ALB + Auto Scaling Group + RDS (Postgres) |
| Simple | **Static Website** | [`infrastructure/simple/aws-s3-static-site`](infrastructure/simple/aws-s3-static-site) | S3 Buckets + CloudFront (CDN) |
| Complex | **Kubernetes Cluster** | [`infrastructure/complex/aws-eks`](infrastructure/complex/aws-eks) | EKS + Managed Nodes + Addons (ExtDNS, CertMgr) |
| Complex | **Serverless API** | [`infrastructure/complex/aws-serverless-api`](infrastructure/complex/aws-serverless-api) | API Gateway + Lambda + DynamoDB |

### GCP
| Type | Name | Path | Description |
|------|------|------|-------------|
| Simple | **Standard Web App** | [`infrastructure/simple/gcp-mig`](infrastructure/simple/gcp-mig) | Global LB + MIG + Cloud SQL (Postgres) |
| Simple | **Static Website** | [`infrastructure/simple/gcp-storage-static-site`](infrastructure/simple/gcp-storage-static-site) | GCS Bucket + Cloud CDN |
| Complex | **Kubernetes Cluster** | [`infrastructure/complex/gcp-gke`](infrastructure/complex/gcp-gke) | GKE Standard + Workload Identity + Addons |
| Complex | **Serverless API** | [`infrastructure/complex/gcp-serverless-api`](infrastructure/complex/gcp-serverless-api) | API Gateway + Cloud Functions + Firestore |

## IaC Bootstrap
| Name | Path | Description |
|------|------|-------------|
| **Simple Bootstrap** | [`iac-bootstrap/simple`](iac-bootstrap/simple) | Single environment OpenTofu bootstrap |
| **Multi-Env Bootstrap** | [`iac-bootstrap/multi-env`](iac-bootstrap/multi-env) | Multi-environment bootstrap with OIDC |

## Build & Deploy
| Name | Path | Description |
|------|------|-------------|
| **Build Docker** | [`build-and-deploy/build-docker`](build-and-deploy/build-docker) | Docker image build workflows |
| **Build Packer (AWS)** | [`build-and-deploy/build-packer-aws`](build-and-deploy/build-packer-aws) | AMI creation using Packer |
| **Deploy ArgoCD** | [`build-and-deploy/deploy-argocd`](build-and-deploy/deploy-argocd) | GitOps deployment via ArgoCD |
| **Deploy Image (AWS)** | [`build-and-deploy/deploy-image-aws`](build-and-deploy/deploy-image-aws) | Deploy container image to AWS |
