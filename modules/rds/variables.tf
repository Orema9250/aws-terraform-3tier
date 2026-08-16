variable "region" {
  type        = string
  description = "The region where the resources created"
}
variable "vpc_id" {
  type        = string
  description = "The id of the vpc"
}
variable "app_sg_id" {
  description = "The security group id for the app "
}
variable "database_subnet_ids" {
  description = "The subnet ids for the database instance"
  type        = list(string)
}
variable "allocated_storage" {
  description = "The allocated storage for database instance"
  type        = map(number)
  default = {
    "dev"   = 20
    "stage" = 30
    "prod"  = 40
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