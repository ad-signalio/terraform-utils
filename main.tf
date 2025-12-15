locals {
  role_name = var.iam_role_name != null ? var.iam_role_name : "${var.cluster_name}-${var.k8s_namespace}-${var.k8s_service_account_name}-irsa"
}


locals {
  oidc_issuer_url  = var.eks_cluster.cluster_oidc_issuer_url
  oidc_provider_id = var.eks_cluster.oidc_provider
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_provider_id}:sub"
      values   = ["system:serviceaccount:${var.k8s_namespace}:${var.k8s_service_account_name}"]
    }
  }
}

resource "aws_iam_role" "irsa_role" {
  name               = local.role_name
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  tags = {
    "eks-irsa" = "true"
  }
}

# Attach managed policies (if any) to the role
resource "aws_iam_role_policy_attachment" "managed" {
  for_each = { for arn in var.attach_policy_arns : arn => arn }

  role       = aws_iam_role.irsa_role.name
  policy_arn = each.value
}

# Optionally attach an inline role policy document
resource "aws_iam_role_policy" "inline" {
  count  = var.inline_role_policy != null ? 1 : 0
  name   = "${local.role_name}-inline-policy"
  role   = aws_iam_role.irsa_role.id
  policy = var.inline_role_policy
}

resource "aws_iam_policy" "deployment_policy" {
  name        = "${var.secret_naming_convention}-deployment-policy"
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

resource "aws_iam_role_policy_attachment" "deployment_policy_attachment" {
  role       = aws_iam_role.irsa_role.name
  policy_arn = aws_iam_policy.deployment_policy.arn
}
