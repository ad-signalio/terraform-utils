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
