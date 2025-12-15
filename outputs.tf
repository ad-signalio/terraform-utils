output "vpc" {
  value = module.vpc.vpc_id
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "private_subnets_detail" {
  value = module.vpc.private_subnet_objects
}

output "vpc_cidr_block" {
  value = module.vpc.vpc_cidr_block
}