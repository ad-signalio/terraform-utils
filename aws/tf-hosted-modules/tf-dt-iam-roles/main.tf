locals {
  name                      = var.env_name
  bucketized_domain_name    = replace(var.domain_name, ".", "-")
  autoingest_s3_bucket_name = "*-autoingest"
}

data "aws_caller_identity" "current" {}


# S3 policy for the specific bucket
data "aws_iam_policy_document" "s3_policy" {
  statement {
    sid    = "S3BucketAccess"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListBucket"
    ]
    resources = [
      "arn:aws:s3:::${var.s3_bucket_name}",
      "arn:aws:s3:::${var.s3_bucket_name}/*"
    ]
  }
}

#AUTO-INGEST POLICY
data "aws_iam_policy_document" "sas_service_account_autoingest" {
  statement {
    sid    = "AllowAppUserToCreateAutoIngestS3BucketsButNotToDeleteThemOrTheirContent"
    effect = "Allow"

    actions = [
      "s3:CreateBucket",
      "s3:ListBucket",
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:GetBucketTagging",
      "s3:PutBucketTagging",
      "s3:PutBucketNotification",
      "s3:PutObjectAcl",
      "s3:AbortMultipartUpload",
      "s3:ListMultipartUploadParts",
      "s3:ListBucketMultipartUploads"
    ]

    resources = [
      "arn:aws:s3:::${local.autoingest_s3_bucket_name}",
      "arn:aws:s3:::${local.autoingest_s3_bucket_name}/*",
    ]
  }

  statement {
    sid    = "AllowAppUserToCreateAutoIngestSNS"
    effect = "Allow"

    actions = [
      "sns:*"
    ]
    resources = [
      "*",
    ]
  }

  statement {
    sid    = "AllowAppUserToCreateUsersAndUserAccessKeys"
    effect = "Allow"

    actions = [
      "iam:CreateUser",
      "iam:DeleteUser",
      "iam:CreateAccessKey",
      "iam:DeleteAccessKey",
      "iam:ListAccessKeys",
      "iam:UpdateAccessKey",
      "iam:TagUser",
      "iam:PutUserPolicy",
      "iam:ListUserPolicies",
      "iam:DeleteUserPolicy",
    ]
    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${local.autoingest_s3_bucket_name}",
    ]
  }
  statement {
    sid    = "AllowAppUserToGetUsers"
    effect = "Allow"

    actions = [
      "iam:ListUsers",
      "iam:GetUser",
    ]
    resources = [
      "*",
    ]
  }
}

data "aws_iam_policy_document" "grafana_cloudwatch" {
  statement {
    sid    = "AllowReadingMetricsFromCloudWatch"
    effect = "Allow"

    actions = [
      "CloudWatch:DescribeAlarmsForMetric",
      "CloudWatch:DescribeAlarmHistory",
      "CloudWatch:DescribeAlarms",
      "CloudWatch:ListMetrics",
      "CloudWatch:GetMetricData",
      "CloudWatch:GetInsightRuleReport",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "AllowReadingTagsInstancesRegionsFromEC2"
    effect = "Allow"

    actions = [
      "ec2:DescribeTags",
      "ec2:DescribeInstances",
      "ec2:DescribeRegions",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "AllowReadingResourcesForTags"
    effect = "Allow"

    actions = [
      "tag:GetResources",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "AllowReadingResourceMetricsFromPerformanceInsights"
    effect = "Allow"

    actions = [
      "pi:GetResourceMetrics",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "grafana_cloudwatch" {
  name_prefix = "${local.name}-grafana-cloudwatch-"
  description = "Policy to allow Grafana to read CloudWatch/EC2/PI/tag data"
  policy      = data.aws_iam_policy_document.grafana_cloudwatch.json

  tags = var.tags
}

resource "aws_iam_role" "grafana_cloudwatch" {
  name = "${local.name}-grafana-cloudwatch"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = module.iam_assumable_role_with_oidc.iam_role_arn
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "grafana_cloudwatch_attach" {
  role       = aws_iam_role.grafana_cloudwatch.name
  policy_arn = aws_iam_policy.grafana_cloudwatch.arn
}

resource "aws_iam_policy" "secrets_policy" {
  count       = var.allow_aws_secret_manager_access ? 1 : 0
  name        = "${var.secret_naming_convention}-secret-policy"
  description = "Policy for deployment to access specific secrets"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = [
          "arn:*:secretsmanager:*:*:secret:${var.secret_naming_convention}*",
          "arn:*:secretsmanager:*:*:secret:match-docker-secret*",
          "arn:*:secretsmanager:*:*:secret:match-honeybadger-secret*"
        ]
      }
    ]
  })
}

module "iam_assumable_role_with_oidc" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "~> 5.0"

  create_role = true

  role_name        = "${local.name}-service-account-role"
  role_description = "IAM role for Kubernetes service account with S3 access"

  provider_url = var.oidc_issuer_url

  role_policy_arns = [
    aws_iam_policy.s3_policy.arn,
    aws_iam_policy.sas_service_account_autoingest.arn,
  ]

  oidc_fully_qualified_subjects  = ["system:serviceaccount:${var.kubernetes_namespace}:${var.kubernetes_service_account}"]
  oidc_fully_qualified_audiences = ["sts.amazonaws.com"]

  tags = var.tags
}

resource "aws_iam_policy" "s3_policy" {
  name_prefix = "${local.name}-s3-policy"
  description = "S3 access policy for ${var.s3_bucket_name}"
  policy      = data.aws_iam_policy_document.s3_policy.json

  tags = var.tags
}

resource "aws_iam_policy" "sas_service_account_autoingest" {
  name_prefix = "${local.name}-sas-autoingest-policy"
  description = "SAS service account policy for autoingest with S3, SNS, and IAM permissions"
  policy      = data.aws_iam_policy_document.sas_service_account_autoingest.json

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "secrets_policy_attachment" {
  count      = var.allow_aws_secret_manager_access ? 1 : 0
  role       = module.iam_assumable_role_with_oidc.iam_role_name
  policy_arn = aws_iam_policy.secrets_policy[0].arn
}
