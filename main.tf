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

# Buckets we ingest FROM. Deliberately a separate document and policy rather
# than extra resources on s3_policy above: that one covers the bucket this
# stack creates and owns, this one covers a bucket it does not. Keeping them
# apart means enabling ingest produces no diff at all on the primary grant,
# and the actions here can be narrowed later without touching it.
data "aws_iam_policy_document" "ingest_s3" {
  count = length(var.ingest_buckets) > 0 ? 1 : 0

  statement {
    sid    = "IngestBucketAccess"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListBucket"
    ]
    resources = flatten([
      for b in var.ingest_buckets : [
        "arn:aws:s3:::${b}",
        "arn:aws:s3:::${b}/*",
      ]
    ])
  }
}

# Cross-account S3 ingest: lets the platform assume a role that a content
# provider creates in THEIR AWS account, scoped by an external ID the platform
# issues. AWS's
# recommended pattern for third-party access.
#
# The wildcard grants the right to attempt, not to succeed: an assumption only
# works if the target role's trust policy names this role and the external ID
# matches, which is the provider's consent expressed in their own account. The
# explicit deny closes the self-escalation path - an explicit deny always wins,
# so this role can never assume anything in this account even if some role here
# trusts the account root broadly.
#
# Note the deny is forward-constraining: a future in-account role chaining need
# would hit it and require a deliberate carve-out by exact ARN.
data "aws_iam_policy_document" "s3_ingest_assume_role" {
  count = var.allow_s3_ingest_role_assumption ? 1 : 0

  statement {
    sid       = "AssumeContentProviderIngestRoles"
    effect    = "Allow"
    actions   = ["sts:AssumeRole"]
    resources = ["arn:aws:iam::*:role/*"]
  }

  statement {
    sid       = "NeverAssumeInThisAccount"
    effect    = "Deny"
    actions   = ["sts:AssumeRole"]
    resources = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/*"]
  }
}

#AUTO-INGEST POLICY
data "aws_iam_policy_document" "sas_service_account_autoingest" {
  count = var.allow_autoingest ? 1 : 0

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

  # Topics are named <bucket>-events, i.e. *-autoingest-events. The ":*" form
  # covers subscription ARNs (topic ARN plus ":<id>") in case Unsubscribe is
  # authorised against the subscription rather than the topic.
  statement {
    sid    = "AllowAppUserToManageAutoIngestSNSTopics"
    effect = "Allow"

    actions = [
      "sns:CreateTopic",
      "sns:TagResource",
      "sns:SetTopicAttributes",
      "sns:Subscribe",
      "sns:Unsubscribe",
      "sns:DeleteTopic",
    ]
    resources = [
      "arn:aws:sns:*:${data.aws_caller_identity.current.account_id}:${local.autoingest_s3_bucket_name}-events",
      "arn:aws:sns:*:${data.aws_caller_identity.current.account_id}:${local.autoingest_s3_bucket_name}-events:*",
    ]
  }

  statement {
    sid    = "AllowAppUserToCreateUsersAndUserAccessKeys"
    effect = "Allow"

    actions = [
      "iam:CreateUser",
      "iam:GetUser",
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

  # The datasource health check runs a logs query as well as a metrics one and
  # fails if either does, so without these the datasource stays ERROR on an
  # otherwise working role -- a missing allow this time, not the ingest deny.
  statement {
    sid    = "AllowReadingLogsFromCloudWatch"
    effect = "Allow"

    actions = [
      "logs:DescribeLogGroups",
      "logs:GetLogGroupFields",
      "logs:StartQuery",
      "logs:StopQuery",
      "logs:GetQueryResults",
      "logs:GetLogEvents",
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
          AWS = module.grafana_iam_assumable_role_with_oidc.iam_role_arn
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

# Grafana's own identity. Separate from the application's so it inherits none of
# its permissions -- it reads CloudWatch and nothing else. sc-25626 took the
# application's Postgres user away from Grafana for the same reason.
#
# The role grants only the hop to grafana_cloudwatch; that role holds the actual
# CloudWatch, EC2, tag and Performance Insights reads. Keeping the hop rather
# than attaching those directly is what lets the Helm chart stay as it is: its
# CloudWatch datasource is authType: assume_role and requires an assumeRoleArn.
module "grafana_iam_assumable_role_with_oidc" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "~> 5.0"

  create_role = true

  role_name        = "${local.name}-grafana"
  role_description = "IAM role for the Grafana Kubernetes service account"

  provider_url = var.oidc_issuer_url

  oidc_fully_qualified_subjects  = ["system:serviceaccount:${var.kubernetes_namespace}:${var.grafana_kubernetes_service_account}"]
  oidc_fully_qualified_audiences = ["sts.amazonaws.com"]

  tags = var.tags
}

data "aws_iam_policy_document" "grafana_assume_cloudwatch" {
  statement {
    sid       = "AssumeGrafanaCloudWatchRole"
    effect    = "Allow"
    actions   = ["sts:AssumeRole"]
    resources = [aws_iam_role.grafana_cloudwatch.arn]
  }
}

resource "aws_iam_policy" "grafana_assume_cloudwatch" {
  name_prefix = "${local.name}-grafana-assume-cloudwatch-"
  description = "Lets Grafana assume the role that reads CloudWatch"
  policy      = data.aws_iam_policy_document.grafana_assume_cloudwatch.json

  tags = var.tags
}

# Attached here rather than through the module's role_policy_arns: that input
# would make the Grafana role depend on this policy, the policy depends on
# grafana_cloudwatch, and grafana_cloudwatch's trust depends on the Grafana
# role. A cycle. The attachment runs after all three exist and breaks it.
resource "aws_iam_role_policy_attachment" "grafana_assume_cloudwatch" {
  role       = module.grafana_iam_assumable_role_with_oidc.iam_role_name
  policy_arn = aws_iam_policy.grafana_assume_cloudwatch.arn
}

module "iam_assumable_role_with_oidc" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "~> 5.0"

  create_role = true

  role_name        = "${local.name}-service-account-role"
  role_description = "IAM role for Kubernetes service account with S3 access"

  provider_url = var.oidc_issuer_url

  # Attachments are managed below as named resources instead. The upstream
  # module indexes role_policy_arns by position (count), so making one policy
  # conditional would shift the others and force them to be replaced.
  role_policy_arns = []

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

resource "aws_iam_policy" "ingest_s3" {
  count = length(var.ingest_buckets) > 0 ? 1 : 0

  name_prefix = "${local.name}-ingest-s3-policy"
  description = "S3 access for the buckets this environment ingests from"
  policy      = data.aws_iam_policy_document.ingest_s3[0].json

  tags = var.tags
}

resource "aws_iam_policy" "sas_service_account_autoingest" {
  count = var.allow_autoingest ? 1 : 0

  name_prefix = "${local.name}-sas-autoingest-policy"
  description = "SAS service account policy for autoingest with S3, SNS, and IAM permissions"
  policy      = data.aws_iam_policy_document.sas_service_account_autoingest[0].json

  tags = var.tags
}

resource "aws_iam_policy" "s3_ingest_assume_role" {
  count = var.allow_s3_ingest_role_assumption ? 1 : 0

  name_prefix = "${local.name}-s3-ingest-assume-role"
  description = "Lets the platform assume S3 ingest roles in other AWS accounts, never in this one"
  policy      = data.aws_iam_policy_document.s3_ingest_assume_role[0].json

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "s3_ingest_assume_role" {
  count      = var.allow_s3_ingest_role_assumption ? 1 : 0
  role       = module.iam_assumable_role_with_oidc.iam_role_name
  policy_arn = aws_iam_policy.s3_ingest_assume_role[0].arn
}

resource "aws_iam_role_policy_attachment" "s3_policy" {
  role       = module.iam_assumable_role_with_oidc.iam_role_name
  policy_arn = aws_iam_policy.s3_policy.arn
}

resource "aws_iam_role_policy_attachment" "sas_service_account_autoingest" {
  count      = var.allow_autoingest ? 1 : 0
  role       = module.iam_assumable_role_with_oidc.iam_role_name
  policy_arn = aws_iam_policy.sas_service_account_autoingest[0].arn
}

resource "aws_iam_role_policy_attachment" "ingest_s3" {
  count      = length(var.ingest_buckets) > 0 ? 1 : 0
  role       = module.iam_assumable_role_with_oidc.iam_role_name
  policy_arn = aws_iam_policy.ingest_s3[0].arn
}

# Adopt the attachments the role module used to create from role_policy_arns,
# whose order was [s3_policy, autoingest, ingest_s3...], so existing
# environments don't detach and reattach them. When allow_autoingest is false
# the autoingest attachment is moved and then destroyed: only detached.
moved {
  from = module.iam_assumable_role_with_oidc.aws_iam_role_policy_attachment.custom[0]
  to   = aws_iam_role_policy_attachment.s3_policy
}

moved {
  from = module.iam_assumable_role_with_oidc.aws_iam_role_policy_attachment.custom[1]
  to   = aws_iam_role_policy_attachment.sas_service_account_autoingest[0]
}

moved {
  from = module.iam_assumable_role_with_oidc.aws_iam_role_policy_attachment.custom[2]
  to   = aws_iam_role_policy_attachment.ingest_s3[0]
}

moved {
  from = aws_iam_policy.sas_service_account_autoingest
  to   = aws_iam_policy.sas_service_account_autoingest[0]
}
