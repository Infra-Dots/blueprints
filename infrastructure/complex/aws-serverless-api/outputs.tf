output "api_endpoint" {
  description = "API Gateway endpoint URL"
  value       = module.api_gateway.apigatewayv2_api_api_endpoint
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table"
  value       = module.dynamodb_table.dynamodb_table_id
}
