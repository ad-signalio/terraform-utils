variable "eks_cluster_name" {
  description = "The environment name (e.g., sbox-adsignal-shared-us1)"
  type        = string
}


variable "tags" {
  description = <<-DESC
    Tags for the AWS resources the ALB controller provisions for Ingresses using
    this IngressClass -- the load balancer, target groups and security groups.

    These cannot be tagged by terraform: the controller creates them, not us. Set
    on IngressClassParams rather than as an Ingress annotation because EKS Auto
    Mode's controller does not honour the standard alb.ingress.kubernetes.io
    annotations.
  DESC
  type        = map(string)
  default     = {}
}

variable "certificate_arns" {
  description = "ACM certificate ARNs for Ingresses using this IngressClass. Must be in the load balancer's own region. Takes precedence over certificate_domain."
  type        = list(string)
  default     = []
}

variable "certificate_domain" {
  description = "Instead of certificate_arns, look up an ISSUED certificate by domain -- e.g. \"*.example.com\". Resolved in the provider's region. Ignored if certificate_arns is set."
  type        = string
  default     = ""
}

variable "ssl_policy" {
  description = "SSL policy for the HTTPS listener, e.g. ELBSecurityPolicy-TLS13-1-2-2021-06. Left to the controller's default when empty."
  type        = string
  default     = ""
}
