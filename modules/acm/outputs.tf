output "cloudfront_acm_arn" {
  value = aws_acm_certificate.cloudfront.arn
}

output "alb_certificate_arn" {
  value = aws_acm_certificate_validation.alb.certificate_arn
}