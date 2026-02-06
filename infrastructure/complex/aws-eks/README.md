# AWS EKS Cluster

This blueprint provisions a production-ready Amazon EKS (Elastic Kubernetes Service) cluster.

## Resources
- **VPC**: A dedicated VPC configured for EKS best practices (Private/Public subnets, NAT Gateway, Tagging).
- **EKS Control Plane**: Managed Kubernetes master nodes (Public endpoint enabled for easy access).
- **Managed Node Group**: Worker nodes scaling from 1 to 3 instances (t3.medium).

## Usage
1. Apply the blueprint using OpenTofu.
2. Configure `kubectl` using:
   ```bash
   aws eks update-kubeconfig --region <region> --name <cluster_name>
   ```
3. Deploy workloads via Helm or ArgoCD (see `blueprints/deploy-argocd` for CD setup).
