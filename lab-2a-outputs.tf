### Lab 2A Outputs (CLI Grading Cheat Sheet)

### Explanation: These outputs provide the exact IDs and URLs you need to run your 
### professor's CLI verification tests and prove your defenses are operational.

output "lab2_deliverable_1_alb_dns" {
  description = "TEST 1A: Direct ALB access. Run 'curl -I' against this URL. It MUST return 403 Forbidden."
  value       = aws_lb.palpaking_alb01.dns_name
}

output "lab2_deliverable_1_cloudfront_url" {
  description = "TEST 1B: CloudFront access. Run 'curl -I' against this URL. It MUST return 200 OK."
  value       = "https://palpatinedesign.click"
}

output "lab2_deliverable_2_waf_id" {
  description = "TEST 2: The WAF ID. Plug this into your 'aws wafv2 get-web-acl' CLI command."
  value       = aws_wafv2_web_acl.cloudfront_waf.id
}

output "lab2_deliverable_2_cloudfront_id" {
  description = "TEST 2: The CloudFront ID. Plug this into your 'aws cloudfront get-distribution' CLI command."
  value       = aws_cloudfront_distribution.cdn.id
}

output "lab2_deliverable_3_urls" {
  description = "TEST 3: The domains to test with 'dig'. They should resolve to CloudFront IPs."
  value       = "palpatinedesign.click and www.palpatinedesign.click"
}