# #############################################################################
# Locals
# #############################################################################
locals {
  lambda_function    = "${path.module}/scanner.zip"
  lambda_handler     = "scanner.lambda_handler"
  lambda_runtime     = "python3.11"
  lambda_timeout     = "300"
  lambda_memory_size = "4096"

  pgo_scanner_lambda_policy = templatefile("${path.module}/pgo_scanner_lambda_policy.tftpl", {
  })
}
