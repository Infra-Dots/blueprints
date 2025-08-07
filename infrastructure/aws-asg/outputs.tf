output "alb_dns_name" {
  value = aws_lb.this.dns_name
}

output "certificate_arn" {
  value = aws_acm_certificate.cert.arn
}
