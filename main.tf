# provider "aws" {
#   version = "~> 2.3"
# }

data "aws_ssm_parameter" "bigiq_server" {
  name = "/lab-parameters/f5/bigiq_server"
}

data "aws_ssm_parameter" "bigiq_username" {
  name = "/lab-parameters/f5/bigiq_username"
}

data "aws_ssm_parameter" "bigiq_password" {
  name = "/lab-parameters/f5/bigiq_password"
}

data "aws_ssm_parameter" "license_pool" {
  name = "/lab-parameters/f5/license_pool"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.63.0"

  name = "${terraform.workspace}-vpc"
  cidr = "10.128.0.0/16"

  azs             = ["us-west-1a"]
  private_subnets = ["10.128.20.0/24"]
  public_subnets  = ["10.128.10.0/24", "10.128.30.0/24"]

  enable_nat_gateway = true

  tags = {
    Terraform = "true"
    Lab_ID = terraform.workspace
  }
}

module "nlb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 5.0"

  name = "${terraform.workspace}-nlb"

  load_balancer_type = "network"

  vpc_id  = module.vpc.vpc_id
  subnets = [module.vpc.public_subnets[0]]

  target_groups = [
    {
      backend_protocol = "TCP"
      backend_port     = 80
      target_type      = "ip"
    }
  ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "TCP"
      target_group_index = 0
    }
  ]

  tags = {
    Terraform = "true"
    Lab_ID = terraform.workspace
  }
}

module "f5_ltm" {
  source               = "git@github.com:wwt/f5-ltm-tf-template.git"

  count = 2

  key_pair             = var.key_pair
  name_prefix          = "${terraform.workspace}-${count.index}-"

  vpc_id               = module.vpc.vpc_id
  management_subnet_id = module.vpc.public_subnets[1]
  external_subnet_id   = module.vpc.public_subnets[0]
  internal_subnet_id   = module.vpc.private_subnets[0]

  external_ips         = ["10.128.10.10${count.index}"]
  internal_ips         = ["10.128.20.10${count.index}"]
  management_ip        = "10.128.30.10${count.index}"
  include_public_ip    = true
  
  bigiq_server         = data.aws_ssm_parameter.bigiq_server.value
  bigiq_username       = data.aws_ssm_parameter.bigiq_username.value
  bigiq_password       = data.aws_ssm_parameter.bigiq_password.value
  license_pool         = data.aws_ssm_parameter.license_pool.value
  provisioned_modules  = ["\"ltm\": \"nominal\""]
}
