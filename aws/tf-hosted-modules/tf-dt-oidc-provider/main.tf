resource "aws_iam_openid_connect_provider" "provider" {
  url            = var.oidc_url
  client_id_list = ["sts.amazonaws.com"]
  tags           = var.tags
}
