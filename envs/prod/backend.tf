terraform {
  backend "s3" {
    bucket  = "beniuezm-unique-tfstate-bucket-name"
    key     = "prod/terraform.tfstate"
    region  = "ap-northeast-1"
    encrypt = true
  }
}