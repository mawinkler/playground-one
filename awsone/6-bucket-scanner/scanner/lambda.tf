# #############################################################################
# Create S3 bucket
# #############################################################################
data "template_file" "pgo_scanner_lambda_policy" {
  template = file("${path.module}/policy.json")
}

resource "aws_lambda_function" "create_action_handler" {

  function_name = "${var.environment}-bucket-scanner-${random_string.random_suffix.result}"

  filename = local.lambda_function

  handler = local.lambda_handler
  runtime = local.lambda_runtime

  environment {
    variables = {
      REGION         = var.aws_region
      TM_AM_AUTH_KEY = var.api_key
      TM_V1_REGION   = var.vision_one_region
    }
  }

  source_code_hash = filebase64sha256(local.lambda_function)

  role = aws_iam_role.pgo_scanner_lambda_role.arn

  timeout     = local.lambda_timeout
  memory_size = local.lambda_memory_size

  tags = {
    Name          = "${var.environment}-bucket-scanner"
    Environment   = "${var.environment}"
    Product       = "playground-one"
    Configuration = "bucket-scanner"
  }
}
