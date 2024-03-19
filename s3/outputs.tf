output "s3_bucket_arn" {
  description = "The ARN for the S3 bucket created."
  value = aws_s3_bucket.s3_bucket.arn
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket created."
  value = aws_s3_bucket.s3_bucket.bucket
}