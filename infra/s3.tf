resource "aws_s3_bucket" "project_data" {
  bucket = "${var.project_name}-${var.environment}-${data.aws_caller_identity.current.account_id}"

  tags = {
    Name        = "${var.project_name}-${var.environment}-data"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

resource "aws_s3_bucket_versioning" "project_data_versioning" {
  bucket = aws_s3_bucket.project_data.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "project_data_encryption" {
  bucket = aws_s3_bucket.project_data.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "project_data_public_access" {
  bucket = aws_s3_bucket.project_data.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.project_data.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.finops_analyzer.arn
    events              = ["s3:ObjectCreated:*"]

    filter_prefix = "input/"
  }

  depends_on = [aws_lambda_permission.allow_s3_invoke]
}