locals {
  all_subnets_by_az = {
    for s in var.private_subnets : s.availability_zone => s.id
  }
  target_azs = slice(keys(local.all_subnets_by_az), 0, 2)
  efs_mount_subnets = {
    for az in local.target_azs : az => local.all_subnets_by_az[az]
  }
}

resource "aws_efs_file_system" "eks" {
  creation_token         = "${var.cluster_name_prefix}-"
  encrypted              = true
  throughput_mode        = "elastic"
  availability_zone_name = var.availability_zone_name
  tags                   = merge(var.tags, { Name = var.cluster_name_prefix })
}

resource "aws_efs_mount_target" "eks" {
  for_each = local.efs_mount_subnets

  file_system_id  = aws_efs_file_system.eks.id
  subnet_id       = each.value
  security_groups = var.vpc_security_group_ids
}