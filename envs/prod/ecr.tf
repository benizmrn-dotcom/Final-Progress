resource "aws_ecr_repository" "app" {
  name         = "nagoyameshi"
  force_delete = true


  image_scanning_configuration {
    scan_on_push = true
  }
}
