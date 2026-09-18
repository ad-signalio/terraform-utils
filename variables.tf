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

variable "scheme" {
  description = <<-DESC
    Whether the load balancer provisioned for Ingresses using this IngressClass
    is reachable from the internet ("internet-facing") or only from inside the
    VPC and whatever is peered or VPN'd to it ("internal").
  DESC
  type        = string
  default     = "internet-facing"
  validation {
    condition     = contains(["internet-facing", "internal"], var.scheme)
    error_message = "scheme must be \"internet-facing\" or \"internal\"."
  }
}

variable "inbound_cidrs" {
  description = <<-DESC
    CIDRs allowed to reach the load balancer. The controller writes these into
    the security group it creates for the load balancer, so this is how an
    internet-facing load balancer gets narrowed to known networks.

    Empty leaves the controller's own default in place, which is 0.0.0.0/0.
  DESC
  type        = list(string)
  default     = []
  validation {
    condition     = alltrue([for cidr in var.inbound_cidrs : can(cidrhost(cidr, 0))])
    error_message = "inbound_cidrs must all be valid CIDR blocks, e.g. 203.0.113.0/24 or 198.51.100.7/32."
  }
}

variable "snicket_labs_remote_lb_access" {
  description = <<-DESC
    Allow Snicket Labs support to reach the load balancer, by adding our egress
    proxy's address to inbound_cidrs.

    It takes effect only where it would change something: the load balancer has
    to be internet-facing, and inbound_cidrs has to be a real restriction
    already -- neither empty (the controller's own default is 0.0.0.0/0) nor
    open to 0.0.0.0/0 itself. So this does not put a hole in a deployment that
    did not narrow access in the first place.

    Set it to false only once another support route is agreed: with no way in,
    a failing environment cannot be diagnosed for the customer.
  DESC
  type        = bool
  default     = true
}
