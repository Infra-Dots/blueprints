provider "aws" {
  region = var.region
}

locals {
  name_prefix = var.project_name
}

################################################################################
# DynamoDB Table
################################################################################

module "dynamodb_table" {
  source  = "terraform-aws-modules/dynamodb-table/aws"
  version = "~> 5.5"

  name     = "${local.name_prefix}-table"
  hash_key = "id"

  attributes = [
    {
      name = "id"
      type = "S"
    }
  ]
  
  billing_mode = "PAY_PER_REQUEST"
}

################################################################################
# Lambda Function
################################################################################

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda/index.py"
  output_path = "${path.module}/lambda/lambda_function.zip"
}

module "lambda_function" {
  source = "terraform-aws-modules/lambda/aws"
  version = "~> 8.4"

  function_name = "${local.name_prefix}-function"
  description   = "Serverless API Handler"
  handler       = "index.lambda_handler"
  runtime       = "python3.9"

  create_package         = false
  local_existing_package = data.archive_file.lambda_zip.output_path

  environment_variables = {
    TABLE_NAME = module.dynamodb_table.dynamodb_table_id
  }

  attach_policy_json = true
  policy_json        = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem"
        ]
        Effect   = "Allow"
        Resource = module.dynamodb_table.dynamodb_table_arn
      }
    ]
  })
}

################################################################################
# API Gateway
################################################################################

module "api_gateway" {
  source = "terraform-aws-modules/apigateway-v2/aws"
  version = "~> 2.0"

  name          = "${local.name_prefix}-http-api"
  description   = "HTTP API Gateway"
  protocol_type = "HTTP"

  cors_configuration = {
    allow_headers = ["content-type", "x-amz-date", "authorization", "x-api-key", "x-amz-security-token", "x-amz-user-agent"]
    allow_methods = ["*"]
    allow_origins = ["*"]
  }

  create_api_domain_name = false # Simplification for blueprint

  integrations = {
    "GET /" = {
      lambda_arn             = module.lambda_function.lambda_function_arn
      payload_format_version = "2.0"
      timeout_milliseconds   = 12000
    }
  }
}

resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_function.lambda_function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${module.api_gateway.apigatewayv2_api_execution_arn}/*/*"
}
