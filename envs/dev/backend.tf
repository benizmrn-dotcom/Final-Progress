terraform {
  backend "s3" {
    bucket  = "beniuezm-unique-tfstate-bucket-name"
    key     = "dev/terraform.tfstate"
    region  = "ap-northeast-1"
    encrypt = true
  }
}