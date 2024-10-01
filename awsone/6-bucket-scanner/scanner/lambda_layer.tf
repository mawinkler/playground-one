# #############################################################################
# Lambda Layer
# #############################################################################
resource "aws_lambda_layer_version" "lambda_layer" {
  layer_name = "${var.environment}-filesecurity-layer-${random_string.random_suffix.result}"
  filename   = local.lambda_layer

  compatible_runtimes      = ["python3.11"]
  compatible_architectures = ["arm64"]
}
