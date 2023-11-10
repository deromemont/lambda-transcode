resource "aws_cloudwatch_event_rule" "event_rule" {
  name        = "lambda-transcode-events"
 
  event_pattern = <<PATTERN
{
  "source": ["aws.s3"],
  "detail-type": ["Object Created"],
  "detail": {
    "bucket": {
      "name": ["${aws_s3_bucket.main.id}"]
    },
    "object": {
      "key": [{
        "prefix": "input/"
      }]
    }
  }
}
PATTERN
}

data "aws_iam_policy_document" "assume_role_event" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    actions = [
        "sts:AssumeRole"
    ]
  }
}

resource "aws_iam_role" "event_role" {
  name               = "event_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_event.json

  inline_policy {
    name = "iam_for_eventbus_inline_policy"

    policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "states:StartExecution"
            ],
            "Resource": [
                "${aws_sfn_state_machine.sfn_state_machine.arn}"
            ]
        }
    ]
}
EOF
    }
}

resource "aws_cloudwatch_event_target" "event_target" {
  arn  = aws_sfn_state_machine.sfn_state_machine.arn
  rule = aws_cloudwatch_event_rule.event_rule.name
  role_arn = aws_iam_role.event_role.arn
}

resource "aws_cloudwatch_event_rule" "main" {
  description   = "Object create events on bucket s3://${aws_s3_bucket.main.id}"
  event_pattern = <<EOF
{
  "detail-type": [
    "Object Created"
  ],
  "source": [
    "aws.s3"
  ],
  "detail": {
    "bucket": {
      "name": ["${aws_s3_bucket.main.id}"]
    }
  }
}
EOF
}