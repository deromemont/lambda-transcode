data "archive_file" "lambda_layer" {
  type        = "zip"
  source_file = "ffmpeg"
  output_path = "lambda_layer_payload.zip"
}

resource "aws_lambda_layer_version" "lambda_layer" {
  filename   = "lambda_layer_payload.zip"
  layer_name = "ffmpeg6t"

  compatible_runtimes = ["python3.11"]
}