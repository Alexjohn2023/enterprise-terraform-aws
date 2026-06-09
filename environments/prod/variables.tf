variable "environment" {
  type    = string
  default = "prod"
}
variable "aws_region" {
  type    = string
  default = "us-east-1"
}
variable "cidr_block" {
  type    = string
  default = "10.2.0.0/16"
}
variable "instance_type" {
  type    = string
  default = "t3.medium"
}
variable "bucket_name" {
  type    = string
  default = "enterprise-app"
}
