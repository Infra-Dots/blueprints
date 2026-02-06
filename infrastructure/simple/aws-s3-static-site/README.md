# AWS S3 Static Site

This blueprint provisions a secure static website hosting architecture using Amazon S3 and CloudFront.

## Resources
- **S3 Bucket**: Private bucket with versioning enabled.
- **CloudFront**: Global CDN with OAI (Origin Access Identity) to securely serve files from S3.
- **Bucket Policy**: Restricts access to only the CloudFront OAI.

## Usage
Simply apply this blueprint to get a functional CDN endpoint. Upload your `index.html` and assets to the created bucket.
