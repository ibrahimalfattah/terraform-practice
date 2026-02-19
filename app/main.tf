module "vpc" {
  source       = "../modules/vpc"
  project_name = var.project_name

  vpc_cidr = "10.10.0.0/16"

  public_subnet_cidrs  = ["10.10.1.0/24", "10.10.2.0/24"]
  private_subnet_cidrs = ["10.10.11.0/24", "10.10.12.0/24"]
}

module "sg" {
  source       = "../modules/security_group"
  project_name = var.project_name
  vpc_id       = module.vpc.vpc_id

  ssh_ingress_cidr = var.my_ip_cidr
}

module "ec2" {
  source       = "../modules/ec2"
  project_name = var.project_name

  subnet_id          = module.vpc.public_subnet_ids[0]
  security_group_ids = [module.sg.security_group_id]

  instance_type   = var.instance_type
  public_key_path = var.public_key_path
}
