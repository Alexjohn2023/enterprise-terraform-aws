variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}
variable "subnet_id" {
  description = "Subnet ID"
  type        = string
}
variable "vpc_id" {
  description = "VPC ID"
  type        = string
}
variable "environment" {
  description = "Environment name"
  type        = string
}
