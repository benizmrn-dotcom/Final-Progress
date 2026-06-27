resource "aws_ecr_repository" "app" {
  name = "${var.env}-${var.project_name}"

  force_delete = true


  image_scanning_configuration {
    scan_on_push = true
  }
}
