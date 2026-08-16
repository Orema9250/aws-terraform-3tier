variable "region" {
  description = "The region where all the resource will be created"
  type        = string
}

variable "cidr_block" {
  description = "The valuue of the cidr block for the VPC"
  type        = string
}

variable "availability_zone" {
  description = "The availability zone where subnets will be created"
  type        = list(string)
}

variable "map_public_ip_on_launch" {
  description = "The boolean value if there should be public ip on launch"
  type        = bool
}

variable "enable_dns_hostnames" {
  description = "The boolean vvalue to enable dns hostnames"
  type        = bool
}

variable "cidr_ipv4" {
  description = "The permission to allow traffic from in to  the vpc "
  type        = string
}

variable "device_name" {
  description = "The device for storage for launc template"
  type        = string
}

variable "ebs_volume_size" {
  description = "The size of ebs storage volume "
  type        = map(number)
  default = {
    dev   = 8
    stage = 10
    prod  = 12
  }
}
variable "instance_type" {
  description = "The type of instance for launch template"
  type        = map(string)
  default = {
    "dev"   = "t2.micro"
    "stage" = "t3.micro"
    "prod"  = "t3.medium"
  }
}

variable "image_id" {
  description = "The ami id for the instances"
  type        = string
}

variable "private_dns_enabled" {
  description = "Enable DNS for vpc endpoints"
  type        = bool
}
variable "user_id" {
  description = "user account id"
  type        = string
}
variable "allocated_storage" {
  description = "The allocated storage for database instance"
  type        = map(number)
  default = {
    "dev"   = 8
    "stage" = 10
    "prod"  = 12
  }
}
variable "storage_type" {
  description = "The type of storage for database instance"
  type        = string
}
variable "instance_class" {
  description = "The instance class for database instance"
  type        = map(string)
  default = {
    dev   = "db.t4g.micro"
    stage = "db.t4g.micro"
    prod  = "db.t4g.small"
  }
}
variable "engine_version" {
  description = "The engine for database instance"
  type        = string
}
variable "db_name" {
  description = "The database name for database instance"
  type        = string
}
variable "domain_name" {
  description = "Domain name"
  type        = string
}
variable "bucket_name" {
  description = "The name of the bucket for frontend"
  type        = string
}
variable "api_domain_name" {
  description = "The domain name of api"
  type        = string
}