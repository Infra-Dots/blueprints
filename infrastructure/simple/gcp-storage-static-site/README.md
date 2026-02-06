# GCP Storage Static Site

This blueprint provisions a serverless static website hosting on GCP:
- **Cloud Storage Bucket**: Stores HTML/CSS/JS assets.
- **Cloud CDN**: Caches content specifically for high performance global delivery.
- **Global Load Balancer**: Serves the content via a single Anycast IP.

## Usage
```bash
tofu init
tofu apply -var="project_id=your-project-id"
```
After apply, upload your `index.html` to the output `bucket_name`.
