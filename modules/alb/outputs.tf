output "alb_dns_name" {
  value = aws_lb.alb.dns_name
}
output "target_group_arn" {
  value = aws_lb_target_group.tg.arn
}

output "listener_arn" {
  value = aws_lb_listener.http.arn
}

output "alb_zone_id" {
  value = aws_lb.alb.zone_id
}