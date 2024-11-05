# module "route53" {
#   source  = "terraform-aws-modules/route53/aws"
#   version = "4.1.0"
# }

# resource "aws_route53_zone" "primary" {
#   name = "aayan-resume.com"
# }

# resource "aws_route53_record" "acm_validation" {
#   for_each = { for option in aws_acm_certificate.main.domain_validation_options : option.domain_name => option }

#   zone_id = aws_route53_zone.primary.zone_id
#   name    = each.value.resource_record_name
#   type    = each.value.resource_record_type
#   ttl     = 60
#   records = [each.value.resource_record_value]

#   # depends_on = [aws_acm_certificate_validation.main]
# }

module "route53" {
  source  = "terraform-aws-modules/route53/aws"
  version = "4.1.0"
}

resource "aws_route53_zone" "primary" {
  name = "aayan-resume.com"
}
