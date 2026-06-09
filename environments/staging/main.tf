data "aws_caller_identity" "current" {}

module "networking" {
  source      = "../../modules/networking"
  environment = var.environment
  cidr_block  = var.cidr_block
  aws_region  = var.aws_region
}

module "compute" {
  source        = "../../modules/compute"
  environment   = var.environment
  subnet_id     = module.networking.subnet_id
  vpc_id        = module.networking.vpc_id
  instance_type = var.instance_type
}

module "storage" {
  source      = "../../modules/storage"
  environment = var.environment
  bucket_name = var.bucket_name
  account_id  = data.aws_caller_identity.current.account_id
}
