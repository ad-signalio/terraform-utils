output "bucket_arn" {
  description = "ARNs of the bucket"
  value       = aws_s3_bucket.private_bucket.arn
}
output "bucket_name" {
  description = "Name of the ActiveStorage bucket, for the match chart's s3.primaryBucket. The chart wants the name, not the ARN."
  value       = aws_s3_bucket.private_bucket.bucket
}
