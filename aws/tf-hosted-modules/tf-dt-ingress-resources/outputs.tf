output "ingress_class_name" {
  description = "Name of the IngressClass, for the match chart's ingress.className."
  value       = kubernetes_ingress_class_v1.match_alb.metadata[0].name
}
