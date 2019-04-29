variable "default_aws_tags" {
  description = "default aws tags"
  default = {}
}

variable "backend_s3_bucket_name" {
  description = "S3 bucket which contains remote state"
}