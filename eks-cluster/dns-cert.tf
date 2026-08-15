# eks-cluster/dns-cert.tf
#
# Creates a public ACM certificate for your domain, validated via DNS.
# Since your zone is already in Route 53, Terraform can create the
# validation CNAME records itself and wait for AWS to confirm them -
# no manual console steps needed.


data "aws_route53_zone" "main" {
  name         = var.zone_name
  private_zone = false
}

resource "aws_acm_certificate" "app" {
  domain_name       = var.domain_name
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.app.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }

  zone_id = data.aws_route53_zone.main.zone_id
  name    = each.value.name
  type    = each.value.type
  records = [each.value.record]
  ttl     = 60
}

# This resource doesn't create anything new - it just waits until AWS
# confirms the validation records above are live, so `terraform apply`
# doesn't finish until the cert is genuinely usable.
resource "aws_acm_certificate_validation" "app" {
  certificate_arn         = aws_acm_certificate.app.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

output "acm_certificate_arn" {
  description = "Validated ACM certificate ARN - paste this into k8s/ingress.yaml"
  value       = aws_acm_certificate_validation.app.certificate_arn
}