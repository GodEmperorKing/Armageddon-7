### Bonus B - Route53 (Refactored for Lab 2A CloudFront)

locals {
  ### Explanation: Chewbacca needs a home planet—Route53 hosted zone is your DNS territory.
  chewbacca_zone_name = "palpatinedesign.click"

  ### Explanation: This is the app address that will growl at the galaxy.
  chewbacca_app_fqdn = "palpatinedesign.click"
}

### Hosted Zone (Data lookup)

### Explanation: Since AWS automatically claimed Kashyyyk (your domain) when you bought it, 
### we just need to read it using a data block instead of creating a new one.
data "aws_route53_zone" "chewbacca_zone01" {
  name         = local.chewbacca_zone_name
  private_zone = false
}

### ACM Certificate (TLS)

### Explanation: TLS is the diplomatic passport — browsers trust you, and palpaking stops growling at plaintext.
resource "aws_acm_certificate" "chewbacca_acm_cert01" {
  domain_name               = local.chewbacca_app_fqdn
  subject_alternative_names = ["www.${local.chewbacca_zone_name}"]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${local.name_prefix}-acm-cert01"
  }
}

### ACM DNS Validation Records

### Explanation: ACM asks “prove you own this planet”—DNS validation is Chewbacca roaring in the right place.
resource "aws_route53_record" "chewbacca_acm_validation_records01" {
  for_each = {
    for dvo in aws_acm_certificate.chewbacca_acm_cert01.domain_validation_options :
    dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }

  zone_id = data.aws_route53_zone.chewbacca_zone01.zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = 60
  records = [each.value.record]
}

### Explanation: This ties the “proof record” back to ACM—Chewbacca gets his green checkmark for TLS.
resource "aws_acm_certificate_validation" "chewbacca_acm_validation01_dns_bonus" {
  certificate_arn = aws_acm_certificate.chewbacca_acm_cert01.arn

  validation_record_fqdns = [
    for r in aws_route53_record.chewbacca_acm_validation_records01 : r.fqdn
  ]
}

### ALIAS Records (Point Domain -> CloudFront)

### Explanation: DNS now points to CloudFront — nobody should ever see the ALB again.
resource "aws_route53_record" "chewbacca_apex_to_cf01" {
  zone_id = data.aws_route53_zone.chewbacca_zone01.zone_id
  name    = "palpatinedesign.click"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.cdn.domain_name
    zone_id                = aws_cloudfront_distribution.cdn.hosted_zone_id
    evaluate_target_health = false
  }
}

# Explanation: app.chewbacca-growl.com also points to CloudFront — same doorway, different sign.
resource "aws_route53_record" "chewbacca_app_to_cf01" {
  zone_id = data.aws_route53_zone.chewbacca_zone01.zone_id
  name    = "www.palpatinedesign.click"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.cdn.domain_name
    zone_id                = aws_cloudfront_distribution.cdn.hosted_zone_id
    evaluate_target_health = false
  }
}