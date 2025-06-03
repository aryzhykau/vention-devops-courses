# API Gateway REST API
resource "aws_api_gateway_rest_api" "main" {
  count = var.enable_api_gateway && var.api_gateway_type == "REST" ? 1 : 0

  name = "${var.project_name}-${var.environment}-api"
  description = "API Gateway for Lambda integration"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = merge(var.tags, {
    Name        = "${var.project_name}-api"
    Environment = var.environment
  })
}

# API Gateway Resource
resource "aws_api_gateway_resource" "main" {
  count = var.enable_api_gateway && var.api_gateway_type == "REST" ? 1 : 0

  rest_api_id = aws_api_gateway_rest_api.main[0].id
  parent_id   = aws_api_gateway_rest_api.main[0].root_resource_id
  path_part   = "resource"
}

# API Gateway Method
resource "aws_api_gateway_method" "main" {
  count = var.enable_api_gateway && var.api_gateway_type == "REST" ? 1 : 0

  rest_api_id   = aws_api_gateway_rest_api.main[0].id
  resource_id   = aws_api_gateway_resource.main[0].id
  http_method   = "POST"
  authorization = "NONE"

  request_parameters = {
    "method.request.header.Content-Type" = true
  }
}

# API Gateway Integration
resource "aws_api_gateway_integration" "main" {
  count = var.enable_api_gateway && var.api_gateway_type == "REST" ? 1 : 0

  rest_api_id = aws_api_gateway_rest_api.main[0].id
  resource_id = aws_api_gateway_resource.main[0].id
  http_method = aws_api_gateway_method.main[0].http_method
  
  integration_http_method = "POST"
  type                   = "AWS_PROXY"
  uri                    = aws_lambda_function.api[0].invoke_arn
}

# CORS Configuration
resource "aws_api_gateway_method" "options" {
  count = var.enable_api_gateway && var.api_gateway_type == "REST" && var.enable_api_gateway_cors ? 1 : 0

  rest_api_id   = aws_api_gateway_rest_api.main[0].id
  resource_id   = aws_api_gateway_resource.main[0].id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "options" {
  count = var.enable_api_gateway && var.api_gateway_type == "REST" && var.enable_api_gateway_cors ? 1 : 0

  rest_api_id = aws_api_gateway_rest_api.main[0].id
  resource_id = aws_api_gateway_resource.main[0].id
  http_method = aws_api_gateway_method.options[0].http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "options" {
  count = var.enable_api_gateway && var.api_gateway_type == "REST" && var.enable_api_gateway_cors ? 1 : 0

  rest_api_id = aws_api_gateway_rest_api.main[0].id
  resource_id = aws_api_gateway_resource.main[0].id
  http_method = aws_api_gateway_method.options[0].http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration_response" "options" {
  count = var.enable_api_gateway && var.api_gateway_type == "REST" && var.enable_api_gateway_cors ? 1 : 0

  rest_api_id = aws_api_gateway_rest_api.main[0].id
  resource_id = aws_api_gateway_resource.main[0].id
  http_method = aws_api_gateway_method.options[0].http_method
  status_code = aws_api_gateway_method_response.options[0].status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}

# API Gateway Deployment
resource "aws_api_gateway_deployment" "main" {
  count = var.enable_api_gateway && var.api_gateway_type == "REST" ? 1 : 0

  rest_api_id = aws_api_gateway_rest_api.main[0].id
  depends_on  = [aws_api_gateway_integration.main]

  lifecycle {
    create_before_destroy = true
  }
}

# API Gateway Stage
resource "aws_api_gateway_stage" "main" {
  count = var.enable_api_gateway && var.api_gateway_type == "REST" ? 1 : 0

  deployment_id = aws_api_gateway_deployment.main[0].id
  rest_api_id   = aws_api_gateway_rest_api.main[0].id
  stage_name    = var.api_gateway_stage_name

  xray_tracing_enabled = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway[0].arn
    format = jsonencode({
      requestId               = "$context.requestId"
      sourceIp               = "$context.identity.sourceIp"
      requestTime            = "$context.requestTime"
      protocol              = "$context.protocol"
      httpMethod            = "$context.httpMethod"
      resourcePath          = "$context.resourcePath"
      routeKey              = "$context.routeKey"
      status                = "$context.status"
      responseLength        = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
    })
  }

  tags = merge(var.tags, {
    Name        = "${var.project_name}-stage"
    Environment = var.environment
  })
}

# CloudWatch Log Group for API Gateway
resource "aws_cloudwatch_log_group" "api_gateway" {
  count = var.enable_api_gateway && var.enable_api_gateway_logging ? 1 : 0

  name              = "/aws/apigateway/${var.project_name}-${var.environment}"
  retention_in_days = var.lambda_log_retention_days

  tags = merge(var.tags, {
    Name        = "${var.project_name}-api-logs"
    Environment = var.environment
  })
}

# API Gateway Method Settings
resource "aws_api_gateway_method_settings" "main" {
  count = var.enable_api_gateway && var.api_gateway_type == "REST" ? 1 : 0

  rest_api_id = aws_api_gateway_rest_api.main[0].id
  stage_name  = aws_api_gateway_stage.main[0].stage_name
  method_path = "*/*"

  settings {
    metrics_enabled        = true
    logging_level         = "INFO"
    data_trace_enabled    = true
    throttling_burst_limit = 5000
    throttling_rate_limit  = 10000
  }
}

# HTTP API (if selected)
resource "aws_apigatewayv2_api" "http" {
  count = var.enable_api_gateway && var.api_gateway_type == "HTTP" ? 1 : 0

  name          = "${var.project_name}-${var.environment}-http-api"
  protocol_type = "HTTP"
  
  cors_configuration {
    allow_headers = ["content-type", "x-amz-date", "authorization", "x-api-key", "x-amz-security-token"]
    allow_methods = ["GET", "POST", "PUT", "OPTIONS"]
    allow_origins = ["*"]
    max_age      = 300
  }

  tags = merge(var.tags, {
    Name        = "${var.project_name}-http-api"
    Environment = var.environment
  })
}

# HTTP API Stage
resource "aws_apigatewayv2_stage" "http" {
  count = var.enable_api_gateway && var.api_gateway_type == "HTTP" ? 1 : 0

  api_id = aws_apigatewayv2_api.http[0].id
  name   = var.api_gateway_stage_name
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway[0].arn
    format = jsonencode({
      requestId               = "$context.requestId"
      sourceIp               = "$context.identity.sourceIp"
      requestTime            = "$context.requestTime"
      protocol              = "$context.protocol"
      httpMethod            = "$context.httpMethod"
      resourcePath          = "$context.resourcePath"
      routeKey              = "$context.routeKey"
      status                = "$context.status"
      responseLength        = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
    })
  }

  tags = merge(var.tags, {
    Name        = "${var.project_name}-http-stage"
    Environment = var.environment
  })
}

# HTTP API Integration
resource "aws_apigatewayv2_integration" "http" {
  count = var.enable_api_gateway && var.api_gateway_type == "HTTP" ? 1 : 0

  api_id = aws_apigatewayv2_api.http[0].id

  integration_type   = "AWS_PROXY"
  integration_method = "POST"
  integration_uri    = aws_lambda_function.api[0].invoke_arn
}

# HTTP API Route
resource "aws_apigatewayv2_route" "http" {
  count = var.enable_api_gateway && var.api_gateway_type == "HTTP" ? 1 : 0

  api_id = aws_apigatewayv2_api.http[0].id
  route_key = "POST /resource"
  target    = "integrations/${aws_apigatewayv2_integration.http[0].id}"
} 