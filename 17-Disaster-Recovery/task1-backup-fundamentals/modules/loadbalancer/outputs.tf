output "alb_dns_name" {
  description = "ALB DNS name"
  value       = aws_lb.app_alb.dns_name
}

output "alb_arn" {
  description = "ALB ARN"
  value       = aws_lb.app_alb.arn
}

output "alb_listener_arn" {
  description = "ALB listener ARN"
  value       = aws_lb_listener.http.arn
}

output "target_group_arn" {
  value = aws_lb_target_group.app_tg.arn
}
