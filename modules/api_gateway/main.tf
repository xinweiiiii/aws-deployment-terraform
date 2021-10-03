resource "aws_api_gateway_rest_api" "api" {
 name = "api-gateway"
 description = "Proxy to handle requests to WMS APIs"
}
resource "aws_api_gateway_resource" "fulfilment" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  parent_id   = "${aws_api_gateway_rest_api.api.root_resource_id}"
  path_part   = "{proxy+}"
}
resource "aws_api_gateway_method" "method" {
  rest_api_id   = "${aws_api_gateway_rest_api.api.id}"
  resource_id   = "${aws_api_gateway_resource.fulfilment.id}"
  http_method   = "ANY"
  authorization = "NONE"
  request_parameters = {
    "method.request.path.proxy" = true
  }
}
resource "aws_api_gateway_integration" "integration" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  resource_id = "${aws_api_gateway_resource.fulfilment.id}"
  http_method = "${aws_api_gateway_method.method.http_method}"
  integration_http_method = "ANY"
  type                    = "HTTP_PROXY"
  uri                     = "http://${var.ALB_DNS}/{proxy}"
 
  request_parameters =  {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }
}

resource "aws_api_gateway_domain_name" "domain" {
  domain_name = "api.wms.engineer"
  certificate_arn = "arn:aws:acm:us-east-1:972988805757:certificate/69041e46-17b9-4bfc-a017-18252ab85b75"

}
resource "aws_api_gateway_base_path_mapping" "base_path_mapping" {
  api_id      = "${aws_api_gateway_rest_api.api.id}"
  stage_name    = "api"
  domain_name = "${aws_api_gateway_domain_name.domain.domain_name}"
}

resource "aws_api_gateway_deployment" "api" {
  rest_api_id = aws_api_gateway_rest_api.api.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.api.body))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "api" {
  deployment_id = aws_api_gateway_deployment.api.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
  stage_name    = "api"
}
