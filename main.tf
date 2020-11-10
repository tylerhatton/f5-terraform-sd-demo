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

module "f5_ltm" {
  source               = "git@github.com:wwt/f5-ltm-tf-template.git"

  key_pair             = var.key_pair
  name_prefix          = "${terraform.workspace}-"

  vpc_id               = module.vpc.vpc_id
  management_subnet_id = module.vpc.public_subnets[1]
  external_subnet_id   = module.vpc.public_subnets[0]
  internal_subnet_id   = module.vpc.private_subnets[0]

  external_ips         = ["10.128.10.101"]
  internal_ips         = ["10.128.20.101"]
  management_ip        = "10.128.30.101"
  include_public_ip    = true
  
  bigiq_server         = data.aws_ssm_parameter.bigiq_server.value
  bigiq_username       = data.aws_ssm_parameter.bigiq_username.value
  bigiq_password       = data.aws_ssm_parameter.bigiq_password.value
  license_pool         = data.aws_ssm_parameter.license_pool.value
  provisioned_modules  = ["\"ltm\": \"nominal\""]
}
