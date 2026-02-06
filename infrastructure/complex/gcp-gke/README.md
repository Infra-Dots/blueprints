# GCP GKE Cluster

This blueprint provisions a simple GKE Standard cluster.

## Resources
- **VPC**: Custom VPC with Pod/Service secondary IP ranges.
- **GKE Cluster**: VPC-native, Workload Identity enabled.
- **Node Pool**: Managed node pool (autoscaling enabled).
- **Addons**: ExternalDNS and Cert-Manager (managed via Helm + Workload Identity).

## Usage
```bash
tofu init
tofu apply -var="project_id=your-project-id"
```
Configure kubectl:
```bash
gcloud container clusters get-credentials <cluster_name> --region <region> --project <project_id>
```
