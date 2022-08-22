module "base" {
  source = "../../modules/base"

  env_code       = var.env_code
  vpc_cidr       = var.vpc_cidr
  public_cidr    = var.public_cidr
  private_cidr   = var.private_cidr
  privatedb_cidr = var.privatedb_cidr
}