output "ingress_class_name" {
  description = "Name of the IngressClass, for the match chart's ingress.className."
  value       = kubernetes_ingress_class_v1.match_alb.metadata[0].name
}

output "inbound_cidrs" {
  description = "CIDRs the load balancer's security group will admit, the Snicket Labs support address included where snicket_labs_remote_lb_access adds it. Empty means no restriction was set and the controller's own 0.0.0.0/0 default applies."
  value       = local.inbound_cidrs
}
