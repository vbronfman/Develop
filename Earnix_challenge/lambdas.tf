provider "aws" {
  profile = "default"
  region  = "us-east-1"
 # region  = " ${var.region}"
}

data "archive_file" "create_dist_pkg" {
 # depends_on = ["null_resource.install_python_dependencies"]
  source_dir = "${path.cwd}/lambda_function/"
  output_path = var.output_path
  type = "zip"
}

# test function with aws lambda invoke --region=us-east-1 --function-name=aws_lambda_earnix_test  output.txt
resource "aws_lambda_function" "aws_lambda_earnix_test" {
  function_name = var.function_name
  description = "Earnix home test: lambda function..."
  handler = "lambda_function.lambda_handler"
  runtime = var.runtime 

  role = aws_iam_role.lambda_exec_role.arn
  memory_size = 128
  timeout = 300

  #depends_on = [null_resource.install_python_dependencies]
  source_code_hash = data.archive_file.create_dist_pkg.output_base64sha256
  filename = data.archive_file.create_dist_pkg.output_path
}

/* The special path_part value "{proxy+}" activates proxy behavior, which means that
 this resource will match any request path. Similarly, the aws_api_gateway_method block
  uses a http_method of "ANY", which allows any request method to be used. Taken together,
   this means that all incoming requests will match this resource.
*/
resource "aws_api_gateway_resource" "proxy" {
   rest_api_id = aws_api_gateway_rest_api.example.id
   parent_id   = aws_api_gateway_rest_api.example.root_resource_id
   path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy" {
   rest_api_id   = aws_api_gateway_rest_api.example.id
   resource_id   = aws_api_gateway_resource.proxy.id
   http_method   = "ANY"
   authorization = "NONE"
}

/*
By default any two AWS services have no access to one another, until access is explicitly granted. 
For Lambda functions, access is granted using the "aws_lambda_permission" resource
*/
resource "aws_lambda_permission" "apigw" {
   statement_id  = "AllowAPIGatewayInvoke"
   action        = "lambda:InvokeFunction"
   function_name = aws_lambda_function.aws_lambda_earnix_test.function_name
   principal     = "apigateway.amazonaws.com"

   # The "/*/*" portion grants access from any method on any resource
   # within the API Gateway REST API.
   source_arn = "${aws_api_gateway_rest_api.example.execution_arn}/*/*"
}









