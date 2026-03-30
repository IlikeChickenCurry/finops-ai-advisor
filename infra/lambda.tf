data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/../app/lambda/handler.py"
  output_path = "${path.module}/lambda_function.zip"
}

resource "aws_lambda_permission" "allow_s3_invoke" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.finops_analyzer.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.project_data.arn
}

resource "aws_lambda_function" "finops_analyzer" {
  function_name = "${var.project_name}-${var.environment}-analyzer"

  runtime = "python3.11"
  handler = "handler.lambda_handler"

  role = aws_iam_role.lambda_role.arn

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  timeout          = 10

  environment {
    variables = {
      INPUT_BUCKET     = aws_s3_bucket.project_data.bucket
      INPUT_KEY        = var.input_key
      OUTPUT_KEY       = var.output_key
      ENABLE_BEDROCK   = var.enable_bedrock
      BEDROCK_MODEL_ID = var.bedrock_model_id
    }
  }

  tracing_config {
    mode = "Active"
  }

}