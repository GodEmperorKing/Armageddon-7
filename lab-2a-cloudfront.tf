### 1. The CloudFront Distribution (The Master CDN)
resource "aws_cloudfront_distribution" "cdn" {
  enabled         = true
  is_ipv6_enabled = true
  comment         = "Lab 2A CloudFront Distribution"

  ### Attach the WAF we built earlier
  web_acl_id = aws_wafv2_web_acl.cloudfront_waf.arn

  ### Attach your new custom domain
  aliases = ["palpatinedesign.click", "www.palpatinedesign.click"]

  ### 2. Define the Origin (Point CloudFront to your new ALB)
  origin {
    domain_name = aws_lb.palpaking_alb01.dns_name
    origin_id   = "my-alb-origin"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }

    ### LOCK: Inject the Secret Chewbacca Header we made
    custom_header {
      name  = "X-Chewbacca-Growl"
      value = random_password.chewbacca_origin_header_value01.result
    }
  }

  ### 3. Default Cache Behavior
  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "my-alb-origin"

    viewer_protocol_policy = "redirect-to-https"

    ### Use default AWS Managed Caching Policy
    cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  ### 4. Attach the HTTPS Certificate from your professor's Route 53 code!
  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate_validation.chewbacca_acm_validation01_dns_bonus.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}