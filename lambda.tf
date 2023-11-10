data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = [
        "sts:AssumeRole"
    ]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  inline_policy {
    name = "iam_for_lambda_inline_policy"

    policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowEFSAccess",
            "Effect": "Allow",
            "Action": [
                "elasticfilesystem:ClientMount",
                "elasticfilesystem:ClientWrite",
                "elasticfilesystem:DescribeMountTargets",
                "ec2:DescribeNetworkInterfaces",
                "ec2:CreateNetworkInterface",
                "ec2:DeleteNetworkInterface",
                "ec2:DescribeInstances",
                "ec2:AttachNetworkInterface"
            ],
            "Resource": "*"
        },
        {
            "Sid": "AllAccess",
            "Action": "s3:*",
            "Effect": "Allow",
            "Resource": [
                "arn:aws:s3:::${aws_s3_bucket.main.id}",
                "arn:aws:s3:::${aws_s3_bucket.main.id}/*"
            ]
        }
    ]
}
EOF
    }
}

data "archive_file" "s3toefs" {
  type        = "zip"
  source_file = "lambda/s3toefs.py"
  output_path = "s3toefs.zip"
}

resource "aws_lambda_function" "s3toefs" {
  filename      = "s3toefs.zip"
  function_name = "lambda-transcode-s3toefs"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "s3toefs.lambda_handler"
  source_code_hash = data.archive_file.s3toefs.output_base64sha256
  runtime = "python3.11"
  layers = [aws_lambda_layer_version.lambda_layer.arn]
  timeout = 900

  file_system_config {
    arn = aws_efs_access_point.main.arn
    local_mount_path = "/mnt/efs"
  }

  vpc_config {
    subnet_ids         = [aws_subnet.main.id]
    security_group_ids = [data.aws_security_group.main.id]
  }

  depends_on = [aws_efs_mount_target.main]
}

data "archive_file" "split" {
  type        = "zip"
  source_file = "lambda/split.py"
  output_path = "split.zip"
}

resource "aws_lambda_function" "split" {
  filename      = "split.zip"
  function_name = "lambda-transcode-split"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "split.lambda_handler"
  source_code_hash = data.archive_file.split.output_base64sha256
  runtime = "python3.11"
  layers = [aws_lambda_layer_version.lambda_layer.arn]
  timeout = 900

  file_system_config {
    arn = aws_efs_access_point.main.arn
    local_mount_path = "/mnt/efs"
  }

  vpc_config {
    subnet_ids         = [aws_subnet.main.id]
    security_group_ids = [data.aws_security_group.main.id]
  }

  depends_on = [aws_efs_mount_target.main]
}

data "archive_file" "encode" {
  type        = "zip"
  source_file = "lambda/encode.py"
  output_path = "encode.zip"
}

resource "aws_lambda_function" "encode" {
  filename      = "encode.zip"
  function_name = "lambda-transcode-encode"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "encode.lambda_handler"
  source_code_hash = data.archive_file.encode.output_base64sha256
  runtime = "python3.11"
  layers = [aws_lambda_layer_version.lambda_layer.arn]
  timeout = 900

  file_system_config {
    arn = aws_efs_access_point.main.arn
    local_mount_path = "/mnt/efs"
  }

  vpc_config {
    subnet_ids         = [aws_subnet.main.id]
    security_group_ids = [data.aws_security_group.main.id]
  }

  depends_on = [aws_efs_mount_target.main]
}

data "archive_file" "concat" {
  type        = "zip"
  source_file = "lambda/concat.py"
  output_path = "concat.zip"
}

resource "aws_lambda_function" "concat" {
  filename      = "concat.zip"
  function_name = "lambda-transcode-concat"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "concat.lambda_handler"
  source_code_hash = data.archive_file.concat.output_base64sha256
  runtime = "python3.11"
  layers = [aws_lambda_layer_version.lambda_layer.arn]
  timeout = 900

  file_system_config {
    arn = aws_efs_access_point.main.arn
    local_mount_path = "/mnt/efs"
  }

  vpc_config {
    subnet_ids         = [aws_subnet.main.id]
    security_group_ids = [data.aws_security_group.main.id]
  }

  depends_on = [aws_efs_mount_target.main]
}

data "archive_file" "copytos3" {
  type        = "zip"
  source_file = "lambda/copytos3.py"
  output_path = "copytos3.zip"
}

resource "aws_lambda_function" "copytos3" {
  filename      = "copytos3.zip"
  function_name = "lambda-transcode-copytos3"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "copytos3.lambda_handler"
  source_code_hash = data.archive_file.copytos3.output_base64sha256
  runtime = "python3.11"
  layers = [aws_lambda_layer_version.lambda_layer.arn]
  timeout = 900

  file_system_config {
    arn = aws_efs_access_point.main.arn
    local_mount_path = "/mnt/efs"
  }

  vpc_config {
    subnet_ids         = [aws_subnet.main.id]
    security_group_ids = [data.aws_security_group.main.id]
  }

  depends_on = [aws_efs_mount_target.main]
}
