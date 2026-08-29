variable "region" {
  description = "The region where all the resources will be created"
  type        = string
}

variable "vpc_id" {
  description = "The id for the vpc"
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

variable "public_subnet_ids" {
  description = "The ids of private subnets"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "The ids of private subnets"
  type        = list(string)
}


variable "aws_account_id" {
  description = "aws account id"
  type        = string
}

variable "db_secret_arn" {
  description = "The secret of database in secret manager"
  type        = string
}

variable "ecr_image" {
  description = "The ecr url"
  type        = string
}

variable "api_cert_arn" {
  description = "The certificcate arn of the acm"
  type        = string
}

variable "ecr_image_url" {
  type = string
}
variable "ecr_image_tag" {
  description = "Docker image tag to deploy"
  type        = string
}

variable "db_endpoint" {
  type = string
}

variable "db_port" {
  type = number
}

variable "db_name" {
  type = string
}