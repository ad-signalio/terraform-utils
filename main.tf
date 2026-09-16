resource "aws_s3_bucket" "private_bucket" {
  bucket = "${var.env_name}-primary"
  tags   = var.tags
}

resource "aws_s3_bucket_cors_configuration" "private_bucket" {
  bucket = aws_s3_bucket.private_bucket.id
  cors_rule {
    allowed_methods = ["PUT", "GET"]
    allowed_headers = ["*"]
    allowed_origins = var.app_url

    expose_headers = [
      "Origin",
      "Content-Type",
      "Content-MD5",
      "Content-Disposition"
    ]
    max_age_seconds = 3600
  }
}

resource "aws_s3_bucket_public_access_block" "public_access_block" {
  bucket                  = aws_s3_bucket.private_bucket.id
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}
