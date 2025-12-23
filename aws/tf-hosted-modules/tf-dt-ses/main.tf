data "aws_region" "current" {}

resource "aws_ses_domain_identity" "ses_domain" {
  domain = var.domain
}

resource "aws_route53_record" "amazonses_verification_record" {
  zone_id = var.zone_id
  name    = "_amazonses.${var.domain}"
  type    = "TXT"
  ttl     = "1800"
  records = [join("", aws_ses_domain_identity.ses_domain[*].verification_token)]
}

resource "aws_ses_domain_dkim" "ses_domain_dkim" {
  domain = join("", aws_ses_domain_identity.ses_domain[*].domain)
}

resource "aws_route53_record" "amazonses_dkim_record" {
  count   = 3
  zone_id = var.zone_id
  name    = "${element(aws_ses_domain_dkim.ses_domain_dkim.dkim_tokens, count.index)}._domainkey.${var.domain}"
  type    = "CNAME"
  ttl     = "1800"
  records = ["${element(aws_ses_domain_dkim.ses_domain_dkim.dkim_tokens, count.index)}.dkim.amazonses.com"]
}

resource "aws_route53_record" "amazonses_spf_record" {
  zone_id = var.zone_id
  name    = length(var.custom_from_subdomain) > 0 ? join("", aws_ses_domain_mail_from.custom_mail_from[*].mail_from_domain) : join("", aws_ses_domain_identity.ses_domain[*].domain)
  type    = "TXT"
  ttl     = "3600"
  records = ["v=spf1 include:amazonses.com -all"]
}

resource "aws_ses_domain_mail_from" "custom_mail_from" {
  domain           = join("", aws_ses_domain_identity.ses_domain[*].domain)
  mail_from_domain = "${one(var.custom_from_subdomain)}.${join("", aws_ses_domain_identity.ses_domain[*].domain)}"
}

resource "aws_route53_record" "custom_mail_from_mx" {
  zone_id = var.zone_id
  name    = join("", aws_ses_domain_mail_from.custom_mail_from[*].mail_from_domain)
  type    = "MX"
  ttl     = "600"
  records = ["10 feedback-smtp.${join("", data.aws_region.current[*].name)}.amazonses.com"]
}

## iam user for sending emails via SES
resource "aws_iam_user" "ses_user" {
  name = var.iam_user_name
  tags = var.tags
}

resource "aws_iam_user_policy_attachment" "ses_send_email" {
  user       = aws_iam_user.ses_user.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSESFullAccess"
}

resource "random_password" "ses_smtp_password" {
  length  = 32
  special = true
}

resource "aws_secretsmanager_secret" "ses_credentials" {
  name = "${var.iam_user_name}-ses-credentials"
  tags = var.tags
}



resource "aws_secretsmanager_secret_version" "ses_credentials_version" {
  secret_id = aws_secretsmanager_secret.ses_credentials.id
  secret_string = jsonencode({
    iam_user_name = aws_iam_user.ses_user.name
    smtp_password = random_password.ses_smtp_password.result
    smtp_port     = tostring(587)
    smtp_domain   = join("", aws_ses_domain_identity.ses_domain[*].domain)
    smtp_address  = "email-smtp.${data.aws_region.current.name}.amazonaws.com"
  })
}


