module "programadev-vpc" {
  source = "./modules/vpc"
  prefix = var.prefix
  quantity = var.quantity
}

module "programadev-eks" {
  source = "./modules/eks"
  vpc_id = module.programadev-vpc.vpc_id
  prefix = var.prefix
  cluster_name = var.cluster_name
  retention_days = var.retention_days
  subnet_ids = module.programadev-vpc.subnet_ids
  desired_size = var.desired_size
  min_size = var.min_size
  max_size = var.max_size
  aws-user-iam-auth = var.aws-user-iam-auth
}