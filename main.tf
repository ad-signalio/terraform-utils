resource "kubernetes_storage_class_v1" "auto_ebs_gp2" {
  metadata {
    name = "auto-ebs-gp2"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }
  storage_provisioner = "ebs.csi.eks.amazonaws.com"
  volume_binding_mode = "WaitForFirstConsumer"
  parameters = {
    type      = "gp2"
    encrypted = "true"
  }
}