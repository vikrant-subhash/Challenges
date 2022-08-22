module vpc {
  source = "../vpc"

  env_code     = var.env_code
  vpc_cidr     = var.vpc_cidr
  private_cidr = var.private_cidr
  public_cidr  = var.public_cidr
  privatedb_cidr = var.privatedb_cidr
}

module lb {
  source = "../lb"

  env_code          = var.env_code
  public_subnet_ids = module.vpc.public_subnet_ids
  vpc_id            = module.vpc.vpc_id

  depends_on = [
    module.vpc
  ]
}

module asg {
  source = "../asg"

  env_code           = var.env_code
  private_subnet_ids = module.vpc.private_subnet_ids
  vpc_id             = module.vpc.vpc_id
  load_balancer_sg   = module.lb.load_balancer_sg
  target_group_arn   = module.lb.target_group_arn

  depends_on = [
    module.lb
  ]
}
