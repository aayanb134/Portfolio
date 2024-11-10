# resource "aws_acm_certificate" "main" {
#   domain_name       = "aayan-resume.com"
#   validation_method = "DNS"

#   lifecycle {
#     create_before_destroy = true
#   }
# }

# resource "aws_acm_certificate_validation" "main" {
#   certificate_arn         = aws_acm_certificate.main.arn
#   validation_record_fqdns = [for record in aws_route53_record.acm_validation : record.fqdn]
# }
provider "aws" {
  alias = "us-east-1"
}

module "acm" {
  source = "terraform-aws-modules/acm/aws"
  providers = {
    aws = aws.us-east-1
  }
  version = "5.1.1"

  domain_name       = "aayan-resume.com"
  zone_id           = aws_route53_zone.primary.id
  validation_method = "DNS"

  wait_for_validation = true

  tags = {
    Name = "aayan-resume.com"
  }
  depends_on = [aws_route53_zone.primary]
}

output "acm_certificate_arn" {
  description = "certificate arn"
  value       = module.acm.acm_certificate_arn
}
