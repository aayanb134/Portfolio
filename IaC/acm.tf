resource "aws_acm_certificate" "main" {
  domain_name       = "aayan-resume.com"
  validation_method = "DNS"
}
