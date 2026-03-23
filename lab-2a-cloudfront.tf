### 1. The CloudFront Distribution (The Master CDN)
resource "aws_cloudfront_distribution" "cdn" {
  enabled         = true
  is_ipv6_enabled = true
  comment         = "Lab 2A CloudFront Distribution"

  ### Attach the WAF to the Distribution
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

    ### LOCK: Inject the Secret Chewbacca Header into ALL requests to the Origin (ALB)
    custom_header {
      name  = "X-Chewbacca-Growl"
      value = random_password.chewbacca_origin_header_value01.result
    }
  }

  ### 3. Default Cache Behavior (Now strictly API / No Cache!)
  default_cache_behavior {
    target_origin_id       = "my-alb-origin"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods         = ["GET", "HEAD"]

    ### Attaching the API Policies
    cache_policy_id          = aws_cloudfront_cache_policy.chewbacca_cache_api_disabled01.id
    origin_request_policy_id = aws_cloudfront_origin_request_policy.chewbacca_orp_api01.id
  }

  ### 4. Static Traffic Cop (The exception to the rule)
  ordered_cache_behavior {
    path_pattern           = "/static/*"
    target_origin_id       = "my-alb-origin"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]

    ### Attaching the Static Policies AND the Response Headers challenge
    cache_policy_id            = aws_cloudfront_cache_policy.chewbacca_cache_static01.id
    origin_request_policy_id   = aws_cloudfront_origin_request_policy.chewbacca_orp_static01.id
    response_headers_policy_id = aws_cloudfront_response_headers_policy.chewbacca_rsp_static01.id
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  ### 5. Attached this HTTPS Certificate from professor's Route 53 code!
  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate_validation.chewbacca_acm_validation01_dns_bonus.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}