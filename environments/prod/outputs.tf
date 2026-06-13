output "vpc_id" { value = module.networking.vpc_id }
output "instance_id" { value = module.compute.instance_id }
output "public_ip" { value = module.compute.public_ip }
output "bucket_id" { value = module.storage.bucket_id }
output "environment" { value = var.environment }
