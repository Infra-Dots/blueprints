# GCP Serverless API

This blueprint provisions a serverless backend architecture on GCP:
- **API Gateway**: Managed entry point (proxy).
- **Cloud Functions (Gen 2)**: Python runtime handling requests.
- **Firestore (Native)**: NoSQL database for basic persistence.

## Usage
```bash
tofu init
tofu apply -var="project_id=your-project-id"
```
The `api_gateway_url` output will provide the endpoint. access `/hello` path.
