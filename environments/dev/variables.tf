variable "environment" {
  type    = string
  default = "dev"
}
variable "aws_region" {
  type    = string
  default = "us-east-1"
}
variable "cidr_block" {
  type    = string
  default = "10.0.0.0/16"
}
variable "instance_type" {
  type    = string
  default = "t3.micro"
}
variable "bucket_name" {
  type    = string
  default = "enterprise-app"
}
variable "owner" {
  type    = string
  default = "Alexander Njoku"
  description = "Owner of the infrastructure"
}
