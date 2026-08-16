output "app_sg_id" {
  value = module.app.app_sg_id
}
output "app_target_group_arn" {
  value = module.app.app_target_group_arn
}

output "lb_dns_name" {
  value = module.app.lb_dns_name
}

output "lb_zone_id" {
  value = module.app.lb_zone_id
}
output "ecr_image_url" {
  value = module.ecr.ecr_image_url
}
output "certificate_arn" {
  value = module.frontend.certificate_arn
}
output "db_secret_arn" {
  value = module.rds.db_secret_arn
}
output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}

output "rds_subnet_ids" {
  value = module.vpc.rds_subnet_ids
}
