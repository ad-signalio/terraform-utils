data "aws_region" "current" {}

data "aws_availability_zones" "available" {}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, var.availability_zone_count)

  cluster_name_prefix = var.env_name
}

resource "aws_eip" "this" {
  tags = merge({
    Name = "${var.env_name}-vpc-natgw"
  }, var.tags)
}


module "vpc" {
  source                               = "terraform-aws-modules/vpc/aws"
  version                              = "6.0.1"
  name                                 = var.env_name
  azs                                  = local.azs
  cidr                                 = var.cidr
  public_subnets                       = [for k, v in local.azs : cidrsubnet(var.cidr, 4, k)]                     # /20 subnets
  private_subnets                      = [for k, v in local.azs : cidrsubnet(var.cidr, 4, k + length(local.azs))] # next /20 subnets
  enable_flow_log                      = false
  create_flow_log_cloudwatch_log_group = false
  create_flow_log_cloudwatch_iam_role  = false
  flow_log_max_aggregation_interval    = 60
  enable_nat_gateway                   = true
  single_nat_gateway                   = true
  one_nat_gateway_per_az               = false
  enable_dns_hostnames                 = true
  reuse_nat_ips                        = true
  external_nat_ip_ids                  = [aws_eip.this.id]
  default_security_group_tags          = var.tags
  public_subnet_tags = merge({
    "subnet"                                             = var.env_name
    "public"                                             = "true"
    "kubernetes.io/cluster/${local.cluster_name_prefix}" = "shared"
    "kubernetes.io/role/elb"                             = "1"
  }, var.tags)
  private_subnet_tags = merge({
    "subnet"                                             = var.env_name
    "private"                                            = "true"
    "kubernetes.io/cluster/${local.cluster_name_prefix}" = "shared"
    "kubernetes.io/role/internal-elb"                    = "1"
    "karpenter.sh/discovery"                             = local.cluster_name_prefix
  }, var.tags)
  default_vpc_tags = var.tags
  vpc_tags         = var.tags
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id          = module.vpc.vpc_id
  service_name    = "com.amazonaws.${data.aws_region.current.region}.s3"
  route_table_ids = concat(module.vpc.private_route_table_ids, module.vpc.public_route_table_ids)
  tags            = var.tags
}
