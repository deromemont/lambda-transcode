resource "aws_s3_bucket" "main" {
  bucket = "lambda-transcode-${data.aws_caller_identity.current.account_id}"
}

resource "aws_s3_bucket_notification" "main" {
  bucket      = aws_s3_bucket.main.id
  eventbridge = true
}