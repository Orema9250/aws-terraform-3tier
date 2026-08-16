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


variable "app_sg_id" {
  description = "The id of web security group"
  type        = string
}

variable "private_dns_enabled" {
  description = "Enable dns for vpc endpoints"
  type        = bool
}