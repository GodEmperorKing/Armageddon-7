### WAFv2 Web ACL (Darth Malgus's Shield Generator)

### Explanation: Malgus does not leave the edge undefended. This Web Application Firewall (WAF)
### sits on CloudFront and inspects every incoming ship. If it detects rebel signatures 
### (SQL injection, bad bots), it blasts them out of the sky before they ever reach the ALB.
resource "aws_wafv2_web_acl" "cloudfront_waf" {
  name        = "malgus-cloudfront-waf01"
  description = "Malgus edge defense - Blocks Rebel Alliance traffic"
  scope       = "CLOUDFRONT" # Must be CLOUDFRONT for edge deployment

  default_action {
    allow {} # Let normal traffic land on Kashyyyk
  }

  ### Managed Rule: AWS Common Rule Set

  ### Explanation: AWS managed rules are like hiring Imperial commandos. 
  ### They already know the most common rebel attack patterns.
  rule {
    name     = "Imperial-Commandos-Common-Rule-Set"
    priority = 1

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    ### CRITICAL FOR YOUR PYTHON SCRIPT: This turns on the radar for the specific rule
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "ImperialCommandosBlocks"
      sampled_requests_enabled   = true
    }
  }

  ### WAF Radar (CloudWatch Metrics Integration)

  ### Explanation: THIS is what your Python script is reading! 
  ### It pushes the total number of blocked requests up to CloudWatch.
  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "MalgusTotalWAFBlocks"
    sampled_requests_enabled   = true
  }

  tags = {
    Name = "malgus-cloudfront-waf01"
  }
}