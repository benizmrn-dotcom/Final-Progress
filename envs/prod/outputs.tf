output "cloudfront_domain_name" {
  value = module.cloudfront.domain_name
}

output "ecr_url" {
  value = aws_ecr_repository.app.repository_url
}