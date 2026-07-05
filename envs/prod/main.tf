module "vpc" {
  source = "../../modules/vpc"

  env  = var.env
  cidr = "10.0.0.0/16"
  azs = [
    "ap-northeast-1a",
    "ap-northeast-1c"
  ]
  public_subnets = [
    "10.0.0.0/24",
    "10.0.10.0/24"
  ]
  private_subnets = [
    "10.0.1.0/24",
    "10.0.11.0/24"

  ]

}

module "alb" {
  source = "../../modules/alb"

  env = var.env

  vpc_id = module.vpc.vpc_id

  public_subnets = module.vpc.public_subnets

  alb_sg_id = module.sg.alb_sg_id

  alb_certificate_arn = module.acm.alb_certificate_arn

}

module "sg" {
  source = "../../modules/sg"

  env = var.env

  vpc_id = module.vpc.vpc_id

}


module "acm" {
  source = "../../modules/acm"

  providers = {
    aws          = aws
    aws.virginia = aws.virginia
  }

  env            = var.env
  domain_name    = var.domain_name
  hosted_zone_id = var.hosted_zone_id
}


module "route53" {
  source = "../../modules/route53"

  hosted_zone_id = var.hosted_zone_id
  domain_name    = var.app_domain_name

  cloudfront_domain_name    = module.cloudfront.domain_name
  cloudfront_hosted_zone_id = module.cloudfront.hosted_zone_id
  alb_origin_domain_name    = var.alb_origin_domain_name
  alb_dns_name              = module.alb.alb_dns_name
  alb_zone_id               = module.alb.alb_zone_id
}

module "cloudfront" {
  source = "../../modules/cloudfront"

  env = var.env

  alb_dns_name           = module.alb.alb_dns_name
  web_acl_arn            = module.waf.web_acl_arn
  acm_certificate_arn    = module.acm.cloudfront_acm_arn
  app_domain_name        = var.app_domain_name
  alb_origin_domain_name = var.alb_origin_domain_name
}

module "waf" {
  source = "../../modules/waf"
  env    = var.env
  providers = {
    aws = aws.virginia
  }
  allowed_ip_addresses = var.allowed_ip_addresses
}

module "cicd" {
  env                     = var.env
  source                  = "../../cicd"
  subnets                 = module.vpc.private_subnets
  ecs_sg_id               = module.sg.ecs_sg_id
  project_name            = var.project_name
  github_repository_url   = "https://github.com/${var.github_owner}/${var.project_name}"
  codestar_connection_arn = "arn:aws:codeconnections:ap-northeast-1:447558491056:connection/ca94b535-8813-4e9f-8c7d-886d980de48b"
  REPOSITORY_URI          = aws_ecr_repository.app.repository_url
  service_name            = module.ecs.service_name
  cluster_name            = module.ecs.cluster_name
  branch                  = var.github_branch
}

data "aws_ec2_managed_prefix_list" "cloudfront" {
  name = "com.amazonaws.global.cloudfront.origin-facing"
}

module "rds" {
  source             = "../../modules/rds"
  env                = var.env
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnets
  project_name       = var.project_name
  rds_sg_id          = module.sg.rds_sg_id
}

module "ssm" {
  source = "../../modules/ssm"

  env = var.env

  db_host     = module.rds.endpoint
  db_username = module.rds.username
  db_password = var.db_password

  app_key = var.app_key

  mail_username     = var.mail_username
  mail_password     = var.mail_password
  mail_from_address = var.mail_from_address
  stripe_key        = var.stripe_key
  stripe_secret     = var.stripe_secret
}

module "ecs" {
  source = "../../modules/ecs"

  env                         = var.env
  vpc_id                      = module.vpc.vpc_id
  private_subnet_ids          = module.vpc.private_subnets
  ecs_task_execution_role_arn = module.iam.ecs_task_execution_role_arn
  ecs_task_role_arn           = module.iam.ecs_task_role_arn

  target_group_arn    = module.alb.target_group_arn
  ecs_security_groups = [module.sg.ecs_sg_id]

  app_image = aws_ecr_repository.app.repository_url
  app_url   = "https://benizmrnuehara.com"

  desired_count = 2

  db_database = module.rds.db_name
}

module "iam" {
  source = "../../modules/iam"

  env = var.env
}


module "monitoring" {
  source = "../../modules/monitoring"

  env         = var.env
  alert_email = var.alert_email

  ecs_cluster_name = module.ecs.cluster_name
  ecs_service_name = module.ecs.service_name
}
