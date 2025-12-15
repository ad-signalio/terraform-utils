output "bucket_arn" {
  description = "ARNs of the bucket"
  value       = aws_s3_bucket.private_bucket.arn
}