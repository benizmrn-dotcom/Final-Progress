resource "aws_ssm_parameter" "db_host" {
  name      = "/myapp/${var.env}/DB_HOST"
  type      = "String"
  value     = var.db_host
  overwrite = true
}

resource "aws_ssm_parameter" "db_username" {
  name      = "/myapp/${var.env}/DB_USERNAME"
  type      = "String"
  value     = var.db_username
  overwrite = true
}

resource "aws_ssm_parameter" "db_password" {
  name      = "/myapp/${var.env}/DB_PASSWORD"
  type      = "SecureString"
  value     = var.db_password
  overwrite = true
}

resource "aws_ssm_parameter" "app_key" {
  name      = "/myapp/${var.env}/app_key"
  type      = "SecureString"
  value     = var.app_key
  overwrite = true
}

resource "aws_ssm_parameter" "mail_username" {
  name      = "/myapp/${var.env}/MAIL_USERNAME"
  type      = "SecureString"
  value     = var.mail_username
  overwrite = true
}

resource "aws_ssm_parameter" "mail_password" {
  name      = "/myapp/${var.env}/MAIL_PASSWORD"
  type      = "SecureString"
  value     = var.mail_password
  overwrite = true
}

resource "aws_ssm_parameter" "mail_from_address" {
  name      = "/myapp/${var.env}/MAIL_FROM_ADDRESS"
  type      = "String"
  value     = var.mail_from_address
  overwrite = true
}

resource "aws_ssm_parameter" "stripe_key" {
  name      = "/myapp/${var.env}/STRIPE_KEY"
  type      = "String"
  value     = var.stripe_key
  overwrite = true
}

resource "aws_ssm_parameter" "stripe_secret" {
  name      = "/myapp/${var.env}/STRIPE_SECRET"
  type      = "SecureString"
  value     = var.stripe_secret
  overwrite = true
}