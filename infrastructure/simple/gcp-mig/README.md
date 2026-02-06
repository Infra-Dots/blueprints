# GCP MIG Blueprint

This blueprint provisions a robust 3-tier-like architecture on GCP:
- **Global Load Balancer**: Distributes traffic.
- **Managed Instance Group (MIG)**: Auto-scaling VM instances running a simple startup script (Apache).
- **Cloud SQL (PostgreSQL)**: Private database instance accessible only from the VPC.
- **Cloud NAT**: Allows private instances to access the internet (for updates/install packages).

## Usage
```bash
tofu init
tofu apply -var="project_id=your-project-id" -var="db_password=securepass"
```
