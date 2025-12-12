resource "aws_efs_file_system" "eks" {
  creation_token = "${var.cluster_name_prefix}-"
  tags = merge(
    var.tags,
    {
      Name = var.cluster_name_prefix
    }
  )
  encrypted              = true
  availability_zone_name = var.availability_zone_name
  throughput_mode        = "elastic"
}

resource "aws_efs_mount_target" "eks" {
  subnet_id       = var.private_subnet
  file_system_id  = aws_efs_file_system.eks.id
  security_groups = [var.node_security_group_id]
}