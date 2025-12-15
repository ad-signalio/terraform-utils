
data "aws_iam_policy_document" "load_testing" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject"
    ]
    resources = [
      "arn:aws:s3:::hub-v1-sandbox-testing-assets-use-1/*",
      "arn:aws:s3:::hub-v1-sandbox-testing-assets/*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:ListBucket"
    ]
    resources = [
      "arn:aws:s3:::hub-v1-sandbox-testing-assets-use-1",
      "arn:aws:s3:::hub-v1-sandbox-testing-assets"
    ]
  }
}

resource "aws_iam_policy" "load_testing" {
  name_prefix = "${var.env_name}-extra-s3-access"
  description = "Extra S3 access for testing assets and autoingest"
  policy      = data.aws_iam_policy_document.load_testing.json

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = var.service_account_role_name
  policy_arn = aws_iam_policy.load_testing.arn
}
