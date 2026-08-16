variable "region" {
  description = "The region where the resource will be created"
  type        = string
}
variable "bucket_name" {
  description = "The name of the bucket for frontend"
  type        = string
}
variable "domain_name" {
  description = "The domain name "
  type        = string
}
variable "aliases" {
  description = "The custom dommain name cloudfront should respond"
  type        = list(string)

}

variable "api_domain_name" {
  description = "The value of api domain name"
  type        = string
}

variable "lb_dns_name" {
  description = "The load balancer dns name"
  type        = string
}

variable "lb_zone_id" {
  description = "The load balancer hosted zone id"
  type        = string
}

