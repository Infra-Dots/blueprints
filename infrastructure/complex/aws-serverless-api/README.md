# AWS Serverless API

This blueprint provisions a serverless backend architecture consisting of API Gateway, Lambda, and DynamoDB.

## Architecture
1.  **API Gateway (HTTP API)**: Receives HTTP requests.
2.  **Lambda Function (Python)**: Processes requests and connects to the database.
3.  **DynamoDB Table**: NoSQL database for storage (visitor counter demo).

## Usage
Apply the blueprint and visit the `api_endpoint` URL outputted by Terraform.
Every visit will increment a counter in DynamoDB.

## Code
The Python source code is located in `lambda/index.py`.
