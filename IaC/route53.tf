module "route53" {
  source  = "terraform-aws-modules/route53/aws"
  version = "4.1.0"
}

resource "aws_route53_zone" "primary" {
  name = "aayan-resume.com"
}
