provider "aws" {
  region = var.region
}



terraform {
  backend "s3" {
    bucket       = "my-terraform-state1234-bucket"
    key          = "orema/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
  }
}


module "vpc" {
  source                  = "./modules/vpc"
  region                  = var.region
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = var.map_public_ip_on_launch
  enable_dns_hostnames    = var.enable_dns_hostnames
  cidr_block              = var.cidr_block
  private_dns_enabled     = var.private_dns_enabled
  app_sg_id               = module.app.app_sg_id
}

module "app" {
  source             = "./modules/app"
  region             = var.region
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  ebs_volume_size    = var.ebs_volume_size
  device_name        = var.device_name
  instance_type      = var.instance_type
  image_id           = var.image_id
  aws_account_id     = var.aws_account_id
  db_secret_arn      = module.rds.db_secret_arn
  ecr_image          = module.ecr.ecr_image_url
  public_subnet_ids  = module.vpc.public_subnet_ids
  api_cert_arn       = module.frontend.certificate_arn
  ecr_image_url      = module.ecr.ecr_image_url
  ecr_image_tag      = var.ecr_image_tag
}

module "rds" {
  source              = "./modules/rds"
  vpc_id              = module.vpc.vpc_id
  database_subnet_ids = module.vpc.rds_subnet_ids
  app_sg_id           = module.app.app_sg_id
  instance_class      = var.instance_class
  db_name             = var.db_name
  allocated_storage   = var.allocated_storage
  region              = var.region
  storage_type        = var.storage_type
  engine_version      = var.engine_version
}

module "frontend" {
  source          = "./modules/frontend"
  bucket_name     = var.bucket_name
  region          = var.region
  aliases         = [var.domain_name]
  domain_name     = var.domain_name
  api_domain_name = var.api_domain_name
  lb_dns_name     = module.app.lb_dns_name
  lb_zone_id      = module.app.lb_zone_id
}

module "ecr" {
  source = "./modules/ecr"
  region = var.region
}
